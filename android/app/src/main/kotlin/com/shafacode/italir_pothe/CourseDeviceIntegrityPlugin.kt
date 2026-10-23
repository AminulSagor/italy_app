package com.shafacode.italir_pothe

import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import com.google.android.play.core.integrity.StandardIntegrityManager
import com.google.android.play.core.integrity.IntegrityManagerFactory
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.MessageDigest
import java.security.Signature
import java.security.spec.ECGenParameterSpec

class CourseDeviceIntegrityPlugin(
    private val context: Context,
    messenger: BinaryMessenger,
) {
    private val channel = MethodChannel(messenger, CHANNEL_NAME)
    private val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }

    fun register() {
        channel.setMethodCallHandler(::handle)
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getIdentity" -> runCatching { identity(namespace(call)) }.fold(result::success) {
                result.error("DEVICE_KEY_ERROR", it.message, null)
            }
            "createProof" -> createProof(call, result)
            else -> result.notImplemented()
        }
    }

    private fun createProof(call: MethodCall, result: MethodChannel.Result) {
        val clientDataBase64 = call.argument<String>("clientDataBase64")
        val keyNamespace = runCatching { namespace(call) }.getOrElse {
            result.error("INVALID_ARGUMENTS", it.message, null)
            return
        }
        val cloudProjectNumber = call.argument<Number>("cloudProjectNumber")?.toLong()
        if (clientDataBase64.isNullOrBlank() || cloudProjectNumber == null || cloudProjectNumber <= 0) {
            result.error("INVALID_ARGUMENTS", "Client data and the existing Google Cloud project number are required.", null)
            return
        }

        val clientData = runCatching { Base64.decode(clientDataBase64, Base64.DEFAULT) }
            .getOrElse {
                result.error("INVALID_CLIENT_DATA", "The backend client data is invalid.", null)
                return
            }
        val requestHash = base64Url(sha256(clientData))
        val alias = keyAlias(keyNamespace)
        val signed = runCatching { sign(alias, clientData) }.getOrElse {
            result.error("DEVICE_SIGNATURE_ERROR", it.message, null)
            return
        }
        val manager = IntegrityManagerFactory.createStandard(context)
        val prepareRequest = StandardIntegrityManager.PrepareIntegrityTokenRequest.builder()
            .setCloudProjectNumber(cloudProjectNumber)
            .build()

        manager.prepareIntegrityToken(prepareRequest)
            .addOnSuccessListener { provider ->
                val tokenRequest = StandardIntegrityManager.StandardIntegrityTokenRequest.builder()
                    .setRequestHash(requestHash)
                    .build()
                provider.request(tokenRequest)
                    .addOnSuccessListener { token ->
                        result.success(identity(keyNamespace) + mapOf(
                            "attestationToken" to token.token(),
                            "signatureBase64" to Base64.encodeToString(signed, Base64.NO_WRAP),
                        ))
                    }
                    .addOnFailureListener { error ->
                        result.error("PLAY_INTEGRITY_REQUEST_FAILED", error.message, null)
                    }
            }
            .addOnFailureListener { error ->
                result.error("PLAY_INTEGRITY_PREPARE_FAILED", error.message, null)
            }
    }

    private fun identity(keyNamespace: String): Map<String, String> {
        val alias = keyAlias(keyNamespace)
        ensureKey(alias)
        val certificate = keyStore.getCertificate(alias)
        val publicKey = certificate.publicKey.encoded
        return mapOf(
            "platform" to "android",
            "deviceKeyId" to base64Url(sha256(publicKey)),
            "deviceLabel" to listOf(Build.MANUFACTURER, Build.MODEL)
                .filter { it.isNotBlank() }
                .joinToString(" ")
                .ifBlank { "Android device" },
            "publicKeyPem" to pem(publicKey),
        )
    }

    private fun ensureKey(alias: String) {
        if (keyStore.containsAlias(alias)) return
        val generator = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, "AndroidKeyStore")
        val parameters = KeyGenParameterSpec.Builder(
            alias,
            KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY,
        )
            .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
            .setDigests(KeyProperties.DIGEST_SHA256)
            .setUserAuthenticationRequired(false)
            .build()
        generator.initialize(parameters)
        generator.generateKeyPair()
    }

    private fun sign(alias: String, data: ByteArray): ByteArray {
        ensureKey(alias)
        val signature = Signature.getInstance("SHA256withECDSA")
        signature.initSign(keyStore.getKey(alias, null) as java.security.PrivateKey)
        signature.update(data)
        return signature.sign()
    }

    private fun sha256(data: ByteArray): ByteArray = MessageDigest.getInstance("SHA-256").digest(data)

    private fun namespace(call: MethodCall): String =
        call.argument<String>("keyNamespace")?.trim()?.takeIf { it.isNotEmpty() }
            ?: throw IllegalArgumentException("A signed-in user key namespace is required.")

    private fun keyAlias(namespace: String): String =
        "$KEY_ALIAS_PREFIX${base64Url(sha256(namespace.toByteArray(Charsets.UTF_8))).take(32)}"

    private fun base64Url(data: ByteArray): String = Base64.encodeToString(
        data,
        Base64.URL_SAFE or Base64.NO_WRAP or Base64.NO_PADDING,
    )

    private fun pem(data: ByteArray): String {
        val encoded = Base64.encodeToString(data, Base64.NO_WRAP)
        return "-----BEGIN PUBLIC KEY-----\n" +
            encoded.chunked(64).joinToString("\n") +
            "\n-----END PUBLIC KEY-----\n"
    }

    companion object {
        private const val CHANNEL_NAME = "italir_pothe/course_device_integrity"
        private const val KEY_ALIAS_PREFIX = "italir_pothe_course_access_v1_"
    }
}

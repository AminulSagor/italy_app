import CryptoKit
import DeviceCheck
import Flutter
import UIKit

final class CourseDeviceAttestationPlugin {
  private static let channelName = "italir_pothe/course_device_integrity"
  private static let keyIdDefaultsKeyPrefix = "course_device_app_attest_key_id_v1_"

  private let channel: FlutterMethodChannel
  private let service = DCAppAttestService.shared

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: Self.channelName, binaryMessenger: messenger)
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
  }

  func dispose() {
    channel.setMethodCallHandler(nil)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard service.isSupported else {
      result(FlutterError(code: "APP_ATTEST_UNSUPPORTED", message: "App Attest is unavailable on this device.", details: nil))
      return
    }
    switch call.method {
    case "getIdentity":
      guard let namespace = namespace(call) else {
        result(flutterErrorMessage("INVALID_ARGUMENTS", "A signed-in user key namespace is required.")); return
      }
      ensureKey(namespace: namespace) { response in response.fold(onSuccess: { result(self.identity($0)) }, onFailure: { result(self.flutterError($0)) }) }
    case "createProof":
      createProof(call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func createProof(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard
      let arguments = call.arguments as? [String: Any],
      let encoded = arguments["clientDataBase64"] as? String,
      let clientData = Data(base64Encoded: encoded),
      let requiresAttestation = arguments["requiresAttestation"] as? Bool,
      let namespace = arguments["keyNamespace"] as? String,
      !namespace.isEmpty
    else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Valid backend client data is required.", details: nil))
      return
    }
    let clientDataHash = Data(SHA256.hash(data: clientData))
    ensureKey(namespace: namespace) { response in
      response.fold(onSuccess: { keyId in
        if requiresAttestation {
          self.service.attestKey(keyId, clientDataHash: clientDataHash) { object, error in
            if let error {
              result(self.appAttestOperationError(error, namespace: namespace)); return
            }
            guard let object else { result(self.flutterErrorMessage("APP_ATTEST_EMPTY", "App Attest returned no attestation.")); return }
            result(self.identity(keyId).merging(["attestationToken": object.base64EncodedString()]) { _, new in new })
          }
        } else {
          self.service.generateAssertion(keyId, clientDataHash: clientDataHash) { assertion, error in
            if let error {
              result(self.appAttestOperationError(error, namespace: namespace)); return
            }
            guard let assertion else { result(self.flutterErrorMessage("APP_ATTEST_EMPTY", "App Attest returned no assertion.")); return }
            result(self.identity(keyId).merging(["assertionBase64": assertion.base64EncodedString()]) { _, new in new })
          }
        }
      }, onFailure: { result(self.flutterError($0)) })
    }
  }

  private func ensureKey(namespace: String, completion: @escaping (Result<String, Error>) -> Void) {
    let defaultsKey = keyIdDefaultsKey(namespace)
    if let keyId = UserDefaults.standard.string(forKey: defaultsKey), !keyId.isEmpty {
      completion(.success(keyId))
      return
    }
    service.generateKey { keyId, error in
      if let error { completion(.failure(error)); return }
      guard let keyId else {
        completion(.failure(NSError(domain: "CourseDeviceAttestation", code: 1, userInfo: [NSLocalizedDescriptionKey: "App Attest returned no key identifier."])))
        return
      }
      UserDefaults.standard.set(keyId, forKey: defaultsKey)
      completion(.success(keyId))
    }
  }

  private func namespace(_ call: FlutterMethodCall) -> String? {
    guard let arguments = call.arguments as? [String: Any] else { return nil }
    return (arguments["keyNamespace"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func identity(_ keyId: String) -> [String: String] {
    let label = UIDevice.current.name.trimmingCharacters(in: .whitespacesAndNewlines)
    return [
      "platform": "ios",
      "deviceKeyId": keyId,
      "deviceLabel": label.isEmpty ? "iOS device" : label,
    ]
  }

  private func flutterError(_ error: Error) -> FlutterError {
    FlutterError(code: "APP_ATTEST_FAILED", message: error.localizedDescription, details: nil)
  }

  private func appAttestOperationError(_ error: Error, namespace: String) -> FlutterError {
    let nsError = error as NSError
    if nsError.domain == DCErrorDomain && nsError.code == DCError.invalidKey.rawValue {
      // App Attest keys do not survive every restore/reinstall scenario. Forget
      // only the rejected local identifier so the next explicit retry creates
      // and attests a fresh key; verification is never bypassed.
      UserDefaults.standard.removeObject(forKey: keyIdDefaultsKey(namespace))
      return flutterErrorMessage(
        "APP_ATTEST_INVALID_KEY",
        "This device's App Attest key is no longer valid. Please retry device verification."
      )
    }
    return flutterError(error)
  }

  private func keyIdDefaultsKey(_ namespace: String) -> String {
    Self.keyIdDefaultsKeyPrefix + Data(SHA256.hash(data: Data(namespace.utf8))).base64EncodedString()
      .replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: "+", with: "-")
      .replacingOccurrences(of: "=", with: "")
  }

  private func flutterErrorMessage(_ code: String, _ message: String) -> FlutterError {
    FlutterError(code: code, message: message, details: nil)
  }
}

private extension Result {
  func fold(onSuccess: (Success) -> Void, onFailure: (Failure) -> Void) {
    switch self { case .success(let value): onSuccess(value); case .failure(let error): onFailure(error) }
  }
}

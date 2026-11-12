import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:italir_pothe/core/models/rewarded_ads_models.dart';
import 'package:italir_pothe/core/services/rewarded_ads/rewarded_ads_service.dart';

void main() {
  Map<String, dynamic> configuration() => <String, dynamic>{
    'adsEnabled': true,
    'isAdFree': false,
    'dailyChallenge': <String, dynamic>{'remaining': 3, 'xp': 10},
    'calls': <String, dynamic>{
      'limitEnabled': false,
      'freeRemaining': 1,
      'credits': 0,
    },
  };

  Dio mockDio(
    Future<Response<dynamic>> Function(RequestOptions options) responder,
  ) {
    final Dio dio = Dio(BaseOptions(baseUrl: 'https://staging.invalid'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest:
            (RequestOptions options, RequestInterceptorHandler handler) async {
              try {
                handler.resolve(await responder(options));
              } on DioException catch (error) {
                handler.reject(error);
              }
            },
      ),
    );
    return dio;
  }

  test(
    'debug confirmation succeeds through complete-test on staging',
    () async {
      late final Dio dio;
      dio = mockDio((RequestOptions options) async {
        if (options.path.endsWith('/complete-test')) {
          return Response<Map<String, dynamic>>(
            requestOptions: options,
            statusCode: 201,
            data: <String, dynamic>{'granted': true},
          );
        }
        return Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: 200,
          data: configuration(),
        );
      });
      final RewardedAdsService service = RewardedAdsService(
        dio: dio,
        releaseModeOverride: false,
      );

      expect(
        await service.confirmRewardForTesting('session-1'),
        RewardedVerificationResult.granted,
      );
    },
  );

  test('debug confirmation against production handles 403 safely', () async {
    late final Dio dio;
    dio = mockDio((RequestOptions options) async {
      throw DioException(
        requestOptions: options,
        response: Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: 403,
          data: <String, dynamic>{
            'statusCode': 403,
            'message': 'Development reward confirmation is disabled.',
          },
        ),
        type: DioExceptionType.badResponse,
      );
    });
    final RewardedAdsService service = RewardedAdsService(
      dio: dio,
      releaseModeOverride: false,
    );

    expect(
      await service.confirmRewardForTesting('session-1'),
      RewardedVerificationResult.rejected,
    );
  });

  test(
    'release polling accepts a delayed SSV grant without another ad',
    () async {
      int polls = 0;
      late final Dio dio;
      dio = mockDio((RequestOptions options) async {
        if (options.path == '/rewarded-ads/config') {
          return Response<Map<String, dynamic>>(
            requestOptions: options,
            statusCode: 200,
            data: configuration(),
          );
        }
        polls += 1;
        return Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: 200,
          data: <String, dynamic>{
            'status': polls >= 3 ? 'granted' : 'pending',
            'granted': polls >= 3,
          },
        );
      });
      final RewardedAdsService service = RewardedAdsService(
        dio: dio,
        releaseModeOverride: true,
        delay: (_) async {},
      );

      expect(
        await service.pollSessionForTesting('session-1', attempts: 3),
        RewardedVerificationResult.granted,
      );
      expect(polls, 3);
    },
  );

  test('release polling reports pending without granting access', () async {
    final Dio dio = mockDio((RequestOptions options) async {
      return Response<Map<String, dynamic>>(
        requestOptions: options,
        statusCode: 200,
        data: <String, dynamic>{'status': 'pending', 'granted': false},
      );
    });
    final RewardedAdsService service = RewardedAdsService(
      dio: dio,
      releaseModeOverride: true,
      delay: (_) async {},
    );

    expect(
      await service.pollSessionForTesting('session-1', attempts: 2),
      RewardedVerificationResult.pending,
    );
  });
}

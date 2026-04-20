import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import '../config/app_env.dart';

class KakaoAuthService {
  const KakaoAuthService();

  Future<String> signIn() async {
    if (!AppEnv.hasKakaoNativeAppKey) {
      throw const KakaoAuthException(
        '카카오 네이티브 앱 키가 설정되지 않았어요. 빌드 시 KAKAO_NATIVE_APP_KEY를 넣어주세요.',
      );
    }

    OAuthToken token;
    if (await isKakaoTalkInstalled()) {
      try {
        token = await UserApi.instance.loginWithKakaoTalk();
      } catch (_) {
        token = await UserApi.instance.loginWithKakaoAccount();
      }
    } else {
      token = await UserApi.instance.loginWithKakaoAccount();
    }

    return token.accessToken;
  }
}

class KakaoAuthException implements Exception {
  const KakaoAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

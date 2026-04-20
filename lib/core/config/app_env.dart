class AppEnv {
  static const kakaoNativeAppKey = String.fromEnvironment('KAKAO_NATIVE_APP_KEY');

  static const apiBaseUrl = String.fromEnvironment('VINMA_API_BASE_URL');

  static bool get hasKakaoNativeAppKey => kakaoNativeAppKey.isNotEmpty;
}

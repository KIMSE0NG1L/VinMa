import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'core/config/app_env.dart';
import 'src/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppEnv.hasKakaoNativeAppKey) {
    KakaoSdk.init(nativeAppKey: AppEnv.kakaoNativeAppKey);
  }
  runApp(const ProviderScope(child: VinMaApp()));
}

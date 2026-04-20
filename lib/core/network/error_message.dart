import 'dart:async';
import 'dart:io';

String toUserMessage(
  Object error, {
  String fallback = '문제가 발생했습니다. 잠시 후 다시 시도해 주세요.',
}) {
  if (error is TimeoutException) {
    return '응답이 늦어지고 있어요. 네트워크 상태를 확인한 뒤 다시 시도해 주세요.';
  }

  if (error is SocketException) {
    return '서버에 연결하지 못했어요. 서버와 인터넷 연결 상태를 확인해 주세요.';
  }

  if (error is HttpException) {
    final message = error.message;

    if (message.contains('API 401')) {
      if (message.contains('KAKAO_AUTH_FAILED')) {
        return '카카오 로그인 확인에 실패했어요. 잠시 후 다시 시도해 주세요.';
      }
      return '로그인이 만료되었어요. 다시 로그인해 주세요.';
    }

    if (message.contains('API 403')) {
      return '이 작업을 진행할 권한이 없어요.';
    }

    if (message.contains('API 404')) {
      return '요청한 정보를 찾지 못했어요.';
    }

    if (message.contains('API 409')) {
      if (message.contains('ALREADY_LIKED')) {
        return '이미 관심을 남긴 상품이에요.';
      }
      if (message.contains('ALREADY_PASSED')) {
        return '이미 패스한 상품이에요.';
      }
      return '이미 처리된 요청이에요.';
    }

    if (message.contains('API 500')) {
      return '서버에 일시적인 문제가 있어요. 잠시 후 다시 시도해 주세요.';
    }

    if (message.contains('Upload 400')) {
      return '사진 업로드 요청이 올바르지 않아요. 사진을 다시 골라 주세요.';
    }

    if (message.contains('Upload 413')) {
      return '사진 용량이 너무 커요. 조금 더 작은 사진으로 다시 시도해 주세요.';
    }

    if (message.contains('Upload 500')) {
      return '사진 업로드에 실패했어요. 잠시 후 다시 시도해 주세요.';
    }

    return fallback;
  }

  final message = error.toString();
  if (message.contains('카카오')) {
    return message;
  }

  return fallback;
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../../core/config/app_env.dart';
import '../domain/order_summary.dart';
import '../domain/product.dart';
import '../domain/user_profile.dart';
import '../domain/wardrobe_item.dart';

class UnauthorizedException implements Exception {
  const UnauthorizedException();
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.profile,
    required this.isNewUser,
  });

  final String token;
  final UserProfile profile;
  final bool isNewUser;
}

class MarketApiClient {
  MarketApiClient({HttpClient? httpClient})
    : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  static String get defaultBaseUrl {
    if (AppEnv.apiBaseUrl.isNotEmpty) {
      return AppEnv.apiBaseUrl;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }

    return 'http://127.0.0.1:8080';
  }

  final String _baseUrl = defaultBaseUrl;

  Future<List<Product>> fetchProducts({
    String? search,
    String? category,
    String? brand,
    String? hashtag,
    List<String>? sizes,
    List<String>? conditions,
    String sort = 'newest',
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse('$_baseUrl/products').replace(
      queryParameters: {
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (category != null && category.trim().isNotEmpty && category != '전체')
          'category': category.trim(),
        if (brand != null && brand.trim().isNotEmpty) 'brand': brand.trim(),
        if (hashtag != null && hashtag.trim().isNotEmpty)
          'hashtag': hashtag.trim(),
        if (sizes != null && sizes.isNotEmpty) 'size': sizes.join(','),
        if (conditions != null && conditions.isNotEmpty) 'condition': conditions.join(','),
        'sort': sort,
        'page': '$page',
        'limit': '$limit',
      },
    );

    final response = await _request('GET', uri);
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    final products = (decoded['products'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
    return products;
  }

  Future<Product> createProduct({
    required String name,
    required int basePrice,
    required String brand,
    required String size,
    required String category,
    required String condition,
    required String description,
    List<String> hashtags = const [],
    List<String> imageUrls = const [],
    int? floorPrice,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl/products');
    final preparedImageUrls = await _prepareImageUrls(
      imageUrls,
      bearerToken: token,
    );
    final primaryImage = preparedImageUrls.isNotEmpty
        ? preparedImageUrls.first
        : null;
    final body = <String, dynamic>{
      'name': name,
      'basePrice': basePrice,
      'brand': brand,
      'size': size,
      'category': category,
      'condition': condition,
      'description': description,
      'hashtags': hashtags,
    };
    if (primaryImage != null && primaryImage.isNotEmpty) {
      body['imageUrl'] = primaryImage;
    }
    if (preparedImageUrls.isNotEmpty) {
      body['imageUrls'] = preparedImageUrls;
    }
    if (floorPrice != null) {
      body['floorPrice'] = floorPrice;
    }
    final response = await _request(
      'POST',
      uri,
      bearerToken: token,
      body: body,
    );
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    return Product.fromJson(decoded['product'] as Map<String, dynamic>);
  }

  Future<Product> likeProduct(String id, {String? token}) async {
    final uri = Uri.parse('$_baseUrl/products/$id/like');
    final response = await _request('POST', uri, bearerToken: token);
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    return Product.fromJson(decoded['product'] as Map<String, dynamic>);
  }

  Future<Product> passProduct(String id, {String? token}) async {
    final uri = Uri.parse('$_baseUrl/products/$id/pass');
    final response = await _request('POST', uri, bearerToken: token);
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    return Product.fromJson(decoded['product'] as Map<String, dynamic>);
  }

  Future<Product> relistProduct(String id, {String? token}) async {
    final uri = Uri.parse('$_baseUrl/products/$id/relist');
    final response = await _request('POST', uri, bearerToken: token);
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    return Product.fromJson(decoded['product'] as Map<String, dynamic>);
  }

  Future<void> deleteProduct(String id, {String? token}) async {
    final uri = Uri.parse('$_baseUrl/products/$id');
    await _request('DELETE', uri, bearerToken: token);
  }

  Future<String> createOrder({
    required List<String> productIds,
    required String receiverName,
    required String phone,
    required String address,
    String? message,
    String? token,
  }) async {
    final uri = Uri.parse('$_baseUrl/orders');
    final response = await _request(
      'POST',
      uri,
      bearerToken: token,
      body: {
        'productIds': productIds,
        'receiverName': receiverName,
        'phone': phone,
        'address': address,
        if (message != null && message.isNotEmpty) 'message': message,
      },
    );
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    final order = decoded['order'] as Map<String, dynamic>;
    return order['id'] as String;
  }

  Future<AuthSession> devLogin({
    required String email,
    String? nickname,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/dev-login');
    final response = await _request(
      'POST',
      uri,
      body: {
        'email': email,
        if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
      },
    );
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    return AuthSession(
      token: decoded['token'] as String,
      profile: UserProfile.fromJson(decoded['user'] as Map<String, dynamic>),
      isNewUser: decoded['isNewUser'] as bool? ?? false,
    );
  }

  Future<AuthSession> authenticateWithKakao(String accessToken) async {
    final uri = Uri.parse('$_baseUrl/auth/kakao');
    final response = await _request(
      'POST',
      uri,
      body: {'accessToken': accessToken},
    );
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    return AuthSession(
      token: decoded['token'] as String,
      profile: UserProfile.fromJson(decoded['user'] as Map<String, dynamic>),
      isNewUser: decoded['isNewUser'] as bool? ?? false,
    );
  }

  Future<UserProfile> fetchMyProfile(String token) async {
    final uri = Uri.parse('$_baseUrl/profile/me');
    final response = await _request('GET', uri, bearerToken: token);
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    return UserProfile.fromJson(decoded['profile'] as Map<String, dynamic>);
  }

  Future<UserProfile> updateMyProfile({
    required String token,
    required UserProfile profile,
  }) async {
    final uri = Uri.parse('$_baseUrl/profile/me');
    final body = <String, dynamic>{
      if (profile.nickname.trim().isNotEmpty) 'nickname': profile.nickname.trim(),
      if (profile.gender.trim().isNotEmpty) 'gender': profile.gender.trim(),
      if (profile.shoeSize.trim().isNotEmpty) 'shoeSize': profile.shoeSize.trim(),
      if (profile.topSize.trim().isNotEmpty) 'topSize': profile.topSize.trim(),
      if (profile.bottomSize.trim().isNotEmpty) 'bottomSize': profile.bottomSize.trim(),
      if (profile.heightCm.trim().isNotEmpty) 'heightCm': profile.heightCm.trim(),
      if (profile.region.trim().isNotEmpty) 'region': profile.region.trim(),
      'preferredCategories': profile.preferredCategories
          .map((category) => category.trim())
          .where((category) => category.isNotEmpty)
          .toList(),
    };
    final response = await _request(
      'PATCH',
      uri,
      bearerToken: token,
      body: body,
    );
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    return UserProfile.fromJson(decoded['profile'] as Map<String, dynamic>);
  }

  Future<void> deleteMyAccount(String token) async {
    final uri = Uri.parse('$_baseUrl/profile/me');
    await _request('DELETE', uri, bearerToken: token);
  }

  Future<List<WardrobeItem>> fetchWardrobe(String token) async {
    final uri = Uri.parse('$_baseUrl/wardrobe');
    final response = await _request('GET', uri, bearerToken: token);
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    return ((decoded['items'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(WardrobeItem.fromJson)
        .toList();
  }

  Future<List<OrderSummary>> fetchOrders(String token) async {
    final uri = Uri.parse('$_baseUrl/orders');
    final response = await _request('GET', uri, bearerToken: token);
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    return ((decoded['orders'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(OrderSummary.fromJson)
        .toList();
  }

  Future<List<Product>> fetchMyProducts(String token) async {
    final uri = Uri.parse('$_baseUrl/products/me');
    final response = await _request('GET', uri, bearerToken: token);
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    return ((decoded['products'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }

  Future<OrderTrackingData> fetchOrderTracking(String orderId) async {
    final uri = Uri.parse('$_baseUrl/orders/$orderId/tracking');
    final response = await _request('GET', uri);
    final decoded = jsonDecode(response) as Map<String, dynamic>;
    return OrderTrackingData.fromJson(decoded);
  }

  Future<String> _request(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
    String? bearerToken,
  }) async {
    final request = await _httpClient
        .openUrl(method, uri)
        .timeout(const Duration(seconds: 10));
    request.headers.contentType = ContentType.json;
    if (uri.host.contains('ngrok-free.dev') ||
        uri.host.contains('ngrok-free.app')) {
      request.headers.set('ngrok-skip-browser-warning', 'true');
    }
    if (bearerToken != null && bearerToken.isNotEmpty) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $bearerToken',
      );
    }
    if (body != null) {
      request.write(jsonEncode(body));
    } else if (method == 'POST' || method == 'PATCH' || method == 'PUT') {
      request.write('{}');
    }

    final response = await request.close().timeout(const Duration(seconds: 20));
    final text = await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 20));
    if (response.statusCode == 401) {
      throw const UnauthorizedException();
    }
    if (response.statusCode >= 400) {
      throw HttpException('API ${response.statusCode}: $text', uri: uri);
    }

    return text;
  }

  Future<List<String>> _prepareImageUrls(
    List<String> imageUrls, {
    String? bearerToken,
  }) async {
    if (imageUrls.isEmpty) {
      return const [];
    }

    final localUris = imageUrls
        .where((url) => url.startsWith('file://'))
        .toList();
    if (localUris.isEmpty) {
      return imageUrls;
    }

    final uploadedUrls = await _uploadProductImages(
      localUris,
      bearerToken: bearerToken,
    );
    final remoteUrls = imageUrls
        .where((url) => !url.startsWith('file://'))
        .toList();
    return [...uploadedUrls, ...remoteUrls];
  }

  Future<List<String>> _uploadProductImages(
    List<String> imageUris, {
    String? bearerToken,
  }) async {
    final uri = Uri.parse('$_baseUrl/uploads/product-images');
    final request = await _httpClient
        .openUrl('POST', uri)
        .timeout(const Duration(seconds: 10));
    final boundary =
        'vinma-boundary-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(1 << 32)}';

    request.headers.set(
      HttpHeaders.contentTypeHeader,
      'multipart/form-data; boundary=$boundary',
    );
    if (uri.host.contains('ngrok-free.dev') ||
        uri.host.contains('ngrok-free.app')) {
      request.headers.set('ngrok-skip-browser-warning', 'true');
    }
    if (bearerToken != null && bearerToken.isNotEmpty) {
      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $bearerToken',
      );
    }

    for (final imageUri in imageUris) {
      final file = File(Uri.parse(imageUri).toFilePath());
      final filename = file.uri.pathSegments.isNotEmpty
          ? file.uri.pathSegments.last
          : 'image.jpg';
      final bytes = await file.readAsBytes();

      request.write('--$boundary\r\n');
      request.write(
        'Content-Disposition: form-data; name="images"; filename="$filename"\r\n',
      );
      request.write(
        'Content-Type: ${_guessImageContentType(filename)}\r\n\r\n',
      );
      request.add(bytes);
      request.write('\r\n');
    }

    request.write('--$boundary--\r\n');

    final response = await request.close().timeout(const Duration(seconds: 30));
    final text = await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 30));
    if (response.statusCode >= 400) {
      throw HttpException('Upload ${response.statusCode}: $text', uri: uri);
    }

    final decoded = jsonDecode(text) as Map<String, dynamic>;
    return ((decoded['images'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((image) => image['url'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
  }

  String _guessImageContentType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.endsWith('.png')) {
      return 'image/png';
    }
    if (lower.endsWith('.webp')) {
      return 'image/webp';
    }
    if (lower.endsWith('.gif')) {
      return 'image/gif';
    }
    if (lower.endsWith('.heic')) {
      return 'image/heic';
    }
    if (lower.endsWith('.heif')) {
      return 'image/heif';
    }
    return 'image/jpeg';
  }
}

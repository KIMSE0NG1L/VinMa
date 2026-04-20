import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/filter_options.dart';
import '../domain/product.dart';
import 'market_api_client.dart';

final marketApiClientProvider = Provider<MarketApiClient>((ref) {
  return MarketApiClient();
});

final marketProductsProvider =
    AsyncNotifierProvider<MarketProductsNotifier, List<Product>>(
      MarketProductsNotifier.new,
    );

class MarketProductsNotifier extends AsyncNotifier<List<Product>> {
  MarketApiClient get _api => ref.read(marketApiClientProvider);
  MarketQuery _currentQuery = const MarketQuery();
  final Map<MarketQuery, List<Product>> _cache = {};
  final Set<String> _pendingLikeIds = {};
  final Set<String> _pendingPassIds = {};
  Future<List<Product>>? _pendingRequest;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  @override
  Future<List<Product>> build() async {
    _currentPage = 1;
    _hasMore = true;
    final products = await _api.fetchProducts(page: 1);
    _hasMore = products.isNotEmpty;
    _cache[_currentQuery] = products;
    return products;
  }

  Future<void> refreshProducts({
    String? search,
    String? category,
    FilterOptions? filters,
  }) async {
    final query = MarketQuery(
      search: search?.trim() ?? '',
      category: category ?? '',
      brand: filters != null && filters.brands.length == 1
          ? filters.brands.first
          : '',
      sort: _mapSort(filters?.sortOption ?? SortOption.latest),
      maxPrice: filters?.maxPrice ?? 3000000,
      sizes: filters?.sizes.toList() ?? const [],
      conditions: filters?.conditions.toList() ?? const [],
    );

    if (query == _currentQuery && state is AsyncData<List<Product>>) {
      return;
    }

    _currentQuery = query;
    _currentPage = 1;
    _hasMore = true;

    final cached = _cache[query];
    if (cached != null) {
      state = AsyncData(cached);
      return;
    }

    final previous = state.asData?.value;
    if (previous == null) {
      state = const AsyncLoading();
    } else {
      state = AsyncData(previous);
    }

    final request = _fetchProducts(query, page: 1);
    _pendingRequest = request;
    state = await AsyncValue.guard(() async {
      final products = await request;
      if (_pendingRequest != request) {
        return state.asData?.value ?? products;
      }
      _hasMore = products.isNotEmpty;
      _cache[query] = products;
      return products;
    });
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;
    final current = state.asData?.value;
    if (current == null) return;

    _isLoadingMore = true;
    try {
      final nextPage = _currentPage + 1;
      final more = await _fetchProducts(_currentQuery, page: nextPage);
      if (more.isEmpty) {
        _hasMore = false;
        return;
      }
      _currentPage = nextPage;
      final next = [...current, ...more];
      state = AsyncData(next);
      _cache[_currentQuery] = next;
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> likeProduct(String id, {String? token}) async {
    if (_pendingLikeIds.contains(id)) {
      return;
    }
    final current = state.asData?.value;
    if (current == null) {
      return;
    }

    _pendingLikeIds.add(id);
    try {
      final updated = await _api.likeProduct(id, token: token);
      final next = [
        for (final product in current)
          if (product.id == id)
            updated.copyWith(isLiked: true)
          else
            product,
      ];
      state = AsyncData(next);
      _cache[_currentQuery] = next;
    } finally {
      _pendingLikeIds.remove(id);
    }
  }

  Future<void> passProduct(String id, {String? token}) async {
    if (_pendingPassIds.contains(id)) {
      return;
    }
    final current = state.asData?.value;
    if (current == null) {
      return;
    }

    _pendingPassIds.add(id);
    try {
      final updated = await _api.passProduct(id, token: token);
      final next = [
        for (final product in current)
          if (product.id == id) updated else product,
      ];
      state = AsyncData(next);
      _cache[_currentQuery] = next;
    } finally {
      _pendingPassIds.remove(id);
    }
  }

  Future<Product> relistProduct(String id, {String? token}) async {
    final created = await _api.relistProduct(id, token: token);
    final current = state.asData?.value ?? const <Product>[];
    final next = [created, ...current];
    state = AsyncData(next);
    _cache[_currentQuery] = next;
    return created;
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
    final created = await _api.createProduct(
      name: name,
      basePrice: basePrice,
      brand: brand,
      size: size,
      category: category,
      condition: condition,
      description: description,
      hashtags: hashtags,
      imageUrls: imageUrls,
      floorPrice: floorPrice,
      token: token,
    );

    final current = state.asData?.value ?? const <Product>[];
    final next = [created, ...current];
    state = AsyncData(next);
    _cache[_currentQuery] = next;
    return created;
  }

  Future<String> createOrder({
    required List<String> productIds,
    required String receiverName,
    required String phone,
    required String address,
    String? message,
    String? token,
  }) {
    return _api.createOrder(
      productIds: productIds,
      receiverName: receiverName,
      phone: phone,
      address: address,
      message: message,
      token: token,
    );
  }

  List<Product> _applyClientFilters(List<Product> products, FilterOptions? filters) {
    if (filters == null) return products;

    return products.where((product) {
      return product.price <= filters.maxPrice;
    }).toList();
  }

  Future<List<Product>> _fetchProducts(MarketQuery query, {int page = 1}) async {
    final products = await _api.fetchProducts(
      search: query.search,
      category: query.category,
      brand: query.brand,
      sizes: query.sizes,
      conditions: query.conditions,
      sort: query.sort,
      page: page,
    );

    return _applyClientFilters(products, null);
  }

  String _mapSort(SortOption sort) {
    switch (sort) {
      case SortOption.priceLow:
        return 'priceAsc';
      case SortOption.priceHigh:
        return 'priceDesc';
      case SortOption.popular:
        return 'likes';
      case SortOption.latest:
        return 'newest';
    }
  }
}

class MarketQuery {
  const MarketQuery({
    this.search = '',
    this.category = '',
    this.brand = '',
    this.sort = 'newest',
    this.maxPrice = 3000000,
    this.sizes = const [],
    this.conditions = const [],
  });

  final String search;
  final String category;
  final String brand;
  final String sort;
  final double maxPrice;
  final List<String> sizes;
  final List<String> conditions;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MarketQuery &&
        other.search == search &&
        other.category == category &&
        other.brand == brand &&
        other.sort == sort &&
        other.maxPrice == maxPrice &&
        _listEquals(other.sizes, sizes) &&
        _listEquals(other.conditions, conditions);
  }

  @override
  int get hashCode => Object.hash(
        search,
        category,
        brand,
        sort,
        maxPrice,
        Object.hashAll(sizes),
        Object.hashAll(conditions),
      );

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final sortedA = [...a]..sort();
    final sortedB = [...b]..sort();
    for (var i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) return false;
    }
    return true;
  }
}

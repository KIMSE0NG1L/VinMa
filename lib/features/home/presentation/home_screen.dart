import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/kakao_auth_service.dart';
import '../../../core/auth/session_storage.dart';
import '../../../core/network/error_message.dart';
import '../../market/data/market_api_client.dart';
import '../../market/data/market_providers.dart';
import '../../market/domain/filter_options.dart';
import '../../market/domain/order_summary.dart';
import '../../market/domain/product.dart';
import '../../market/domain/user_profile.dart';
import '../../market/domain/wardrobe_item.dart';
import '../../market/presentation/widgets/auth_flow_view.dart';
import '../../market/presentation/widgets/bag_view.dart';
import '../../market/presentation/widgets/checkout_sheet.dart';
import '../../market/presentation/widgets/compare_sheet.dart';
import '../../market/presentation/widgets/filter_sheet.dart';
import '../../market/presentation/widgets/order_tracking_sheet.dart';
import '../../market/presentation/widgets/product_card.dart';
import '../../market/presentation/widgets/product_detail_sheet.dart';
import '../../market/presentation/widgets/profile_view.dart';
import '../../market/presentation/widgets/recently_viewed_strip.dart';
import '../../market/presentation/widgets/safety_guide_sheet.dart';
import '../../market/presentation/widgets/swipe_view.dart';
import '../../market/presentation/widgets/upload_product_sheet.dart';

const productCategories = ['전체', '구두', '로퍼', '부츠', '스니커즈', '의류'];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  static const routeName = 'home';
  static const routePath = '/';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _kakaoAuthService = KakaoAuthService();

  final List<Product> _cart = [];
  final List<Product> _compareProducts = [];
  final List<Product> _recentlyViewed = [];

  String _selectedCategory = productCategories.first;
  String _searchQuery = '';
  String _currentOrderId = '';
  int _selectedTab = 0;
  UserProfile? _userProfile;
  String? _sessionToken;
  List<OrderSummary> _orders = const [];
  List<WardrobeItem> _wardrobeItems = const [];
  List<Product> _myProducts = const [];
  FilterOptions _filterOptions = const FilterOptions();
  Timer? _searchDebounce;
  bool _isRestoringSession = true;
  bool _needsOnboarding = false;

  bool get _isLoggedIn => _userProfile != null;
  bool get _isProfileComplete => _isLoggedIn && !_needsOnboarding;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_restoreSession());
      unawaited(_refreshProducts());
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(marketProductsProvider);
    final products = productsState.asData?.value ?? const <Product>[];

    if (_isRestoringSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_isLoggedIn) {
      return AuthFlowView(onKakaoLogin: _handleKakaoLogin);
    }

    if (_needsOnboarding && _userProfile != null) {
      return OnboardingProfileFlow(
        profile: _userProfile!,
        onComplete: _completeOnboardingProfile,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('빈마온', style: Theme.of(context).textTheme.titleLarge),
            Text(
              '좋은 빈티지를 다시 순환시키는 마켓',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFF6F665E),
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          productsState.when(
            data: (items) => _HomeCollectionView(
              filteredProducts: _syncProducts(items),
              recentlyViewed: _recentlyViewed,
              selectedCategory: _selectedCategory,
              searchQuery: _searchQuery,
              compareCount: _compareProducts.length,
              hasActiveFilters: _filterOptions.hasActiveFilters,
              isCompared: (product) => _compareProducts.any((item) => item.id == product.id),
              onSearchChanged: (value) {
                setState(() => _searchQuery = value);
                _scheduleSearchRefresh();
              },
              onSearchCleared: () {
                setState(() => _searchQuery = '');
                unawaited(_refreshProducts());
              },
              onCategorySelected: (category) {
                setState(() => _selectedCategory = category);
                unawaited(_refreshProducts());
              },
              onSafetyPressed: _showSafetyGuide,
              onFilterPressed: () => _showFilterSheet(items),
              onComparePressed: _compareProducts.isEmpty ? null : _showCompareSheet,
              onProductPressed: _showProductDetail,
              onLikePressed: (productId) {
                return () {
                  unawaited(_toggleLike(productId));
                };
              },
              onToggleCompare: _toggleCompare,
              onLoadMore: () => unawaited(ref.read(marketProductsProvider.notifier).loadMore()),
              hasMore: ref.watch(marketProductsProvider.notifier).hasMore,
              isLoadingMore: ref.watch(marketProductsProvider.notifier).isLoadingMore,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _ErrorView(
              message: '상품을 불러오지 못했어요.\n서버 상태를 확인한 뒤 다시 시도해 주세요.',
              onRetry: _refreshProducts,
            ),
          ),
          SwipeView(products: _syncProducts(products), onLike: _toggleLike, onPass: _passProduct, onAddToCart: _addToCart),
          BagView(products: _cart, onRemove: _removeFromCart, onCheckout: _showCheckout),
          if (_userProfile != null)
            ProfileView(
              profile: _userProfile!,
              orders: _orders,
              wardrobeItems: _wardrobeItems,
              myProducts: _myProducts,
              onEditProfile: _showEditProfileSheet,
              onOrderSelected: _showOrderTrackingFor,
              onRelistWardrobeItem: _relistWardrobeItem,
              onDeleteProduct: _deleteMyProduct,
              onDeleteAccount: _confirmDeleteAccount,
              onLogout: () => unawaited(_clearSession()),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: _handleUploadPressed,
              icon: const Icon(Icons.add),
              label: const Text('판매 등록'),
            )
          : _selectedTab == 3 && _currentOrderId.isNotEmpty
              ? FloatingActionButton.extended(onPressed: _showOrderTracking, icon: const Icon(Icons.local_shipping_outlined), label: const Text('배송 조회'))
              : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: '홈'),
          const NavigationDestination(icon: Icon(Icons.local_fire_department_outlined), selectedIcon: Icon(Icons.local_fire_department), label: '스와이프'),
          NavigationDestination(
            icon: Badge.count(count: _cart.length, isLabelVisible: _cart.isNotEmpty, child: const Icon(Icons.favorite_border)),
            selectedIcon: Badge.count(count: _cart.length, isLabelVisible: _cart.isNotEmpty, child: const Icon(Icons.favorite)),
            label: '가방',
          ),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: '마이'),
        ],
      ),
    );
  }

  Future<void> _handleKakaoLogin() async {
    try {
      final accessToken = await _kakaoAuthService.signIn();
      final session = await ref.read(marketApiClientProvider).authenticateWithKakao(accessToken);
      await _applySession(session.token, session.profile, needsOnboarding: session.isNewUser);
    } catch (error, stack) {
      if (!mounted) return;
      _showSnackBar('ERR: ${error.runtimeType}: $error\n$stack'.substring(0, 200.clamp(0, 'ERR: ${error.runtimeType}: $error\n$stack'.length)));
    }
  }

  Future<void> _completeOnboardingProfile(UserProfile profile) async {
    if (_sessionToken == null) return;
    try {
      final updated = await ref.read(marketApiClientProvider).updateMyProfile(token: _sessionToken!, profile: profile);
      if (!mounted) return;
      setState(() {
        _userProfile = updated;
        _needsOnboarding = false;
      });
      await _loadOrders();
      await _loadWardrobe();
      await _loadMyProducts();
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(toUserMessage(error, fallback: '프로필 저장에 실패했어요. 잠시 후 다시 시도해 주세요.'));
    }
  }

  Future<void> _restoreSession() async {
    final token = await SessionStorage.readSessionToken();
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      setState(() => _isRestoringSession = false);
      return;
    }
    try {
      final profile = await ref.read(marketApiClientProvider).fetchMyProfile(token);
      if (!mounted) return;
      setState(() {
        _sessionToken = token;
        _userProfile = profile;
        _needsOnboarding = false;
        _isRestoringSession = false;
      });
      await _loadOrders();
      await _loadWardrobe();
      await _loadMyProducts();
    } catch (_) {
      await SessionStorage.clearSessionToken();
      if (!mounted) return;
      setState(() {
        _sessionToken = null;
        _userProfile = null;
        _orders = const [];
        _wardrobeItems = const [];
        _myProducts = const [];
        _needsOnboarding = false;
        _isRestoringSession = false;
      });
    }
  }

  Future<void> _applySession(String token, UserProfile profile, {required bool needsOnboarding}) async {
    if (!mounted) return;
    setState(() {
      _sessionToken = token;
      _userProfile = profile;
      _needsOnboarding = needsOnboarding;
      _isRestoringSession = false;
    });
    try {
      await SessionStorage.saveSessionToken(token);
    } catch (_) {}
    await _loadOrders();
    await _loadWardrobe();
    await _loadMyProducts();
  }

  Future<void> _clearSession() async {
    await SessionStorage.clearSessionToken();
    if (!mounted) return;
    setState(() {
      _sessionToken = null;
      _userProfile = null;
      _orders = const [];
      _wardrobeItems = const [];
      _myProducts = const [];
      _compareProducts.clear();
      _cart.clear();
      _currentOrderId = '';
      _needsOnboarding = false;
      _isRestoringSession = false;
      _selectedTab = 0;
    });
  }
  Future<void> _refreshProducts() {
    return ref.read(marketProductsProvider.notifier).refreshProducts(
      search: _searchQuery,
      category: _selectedCategory,
      filters: _filterOptions,
    );
  }

  Future<void> _loadOrders() async {
    if (_sessionToken == null) {
      if (mounted) setState(() => _orders = const []);
      return;
    }
    try {
      final orders = await ref.read(marketApiClientProvider).fetchOrders(_sessionToken!);
      if (!mounted) return;
      setState(() => _orders = orders);
    } catch (_) {
      if (!mounted) return;
      setState(() => _orders = const []);
    }
  }

  Future<void> _loadWardrobe() async {
    if (_sessionToken == null) {
      if (mounted) setState(() => _wardrobeItems = const []);
      return;
    }
    try {
      final items = await ref.read(marketApiClientProvider).fetchWardrobe(_sessionToken!);
      if (!mounted) return;
      setState(() => _wardrobeItems = items);
    } catch (_) {
      if (!mounted) return;
      setState(() => _wardrobeItems = const []);
    }
  }

  Future<void> _loadMyProducts() async {
    if (_sessionToken == null) {
      if (mounted) setState(() => _myProducts = const []);
      return;
    }
    try {
      final products = await ref.read(marketApiClientProvider).fetchMyProducts(_sessionToken!);
      if (!mounted) return;
      setState(() => _myProducts = products);
    } catch (_) {
      if (!mounted) return;
      setState(() => _myProducts = const []);
    }
  }

  void _scheduleSearchRefresh() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      unawaited(_refreshProducts());
    });
  }

  Future<bool> _toggleLike(String productId) async {
    try {
      await ref.read(marketProductsProvider.notifier).likeProduct(productId, token: _sessionToken);
      _patchLocalProduct(productId, (product) => product.copyWith(isLiked: true, likeCount: product.likeCount + 1));
      return true;
    } on UnauthorizedException {
      if (!mounted) return false;
      await _clearSession();
      return false;
    } catch (error) {
      if (!mounted) return false;
      _showSnackBar(toUserMessage(error, fallback: '관심 처리에 실패했어요. 이미 반응한 상품일 수 있어요.'));
      return false;
    }
  }

  Future<bool> _passProduct(String productId) async {
    try {
      await ref.read(marketProductsProvider.notifier).passProduct(productId, token: _sessionToken);
      return true;
    } on UnauthorizedException {
      if (!mounted) return false;
      await _clearSession();
      return false;
    } catch (error) {
      if (!mounted) return false;
      _showSnackBar(toUserMessage(error, fallback: '패스 처리에 실패했어요. 이미 반응한 상품일 수 있어요.'));
      return false;
    }
  }

  void _toggleCompare(Product product) {
    setState(() {
      final index = _compareProducts.indexWhere((item) => item.id == product.id);
      if (index >= 0) {
        _compareProducts.removeAt(index);
      } else {
        _compareProducts.add(product);
      }
    });
  }

  void _addToCart(Product product) {
    if (!_cart.any((item) => item.id == product.id)) {
      setState(() => _cart.add(product));
    }
    _showSnackBar('${product.name} 상품을 가방에 담았어요.');
  }

  void _removeFromCart(String productId) {
    setState(() => _cart.removeWhere((item) => item.id == productId));
  }

  void _showProductDetail(Product product) {
    _rememberProduct(product);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final navigator = Navigator.of(context);
        return ProductDetailSheet(
        product: product,
        isInCart: _cart.any((item) => item.id == product.id),
        onAddToCart: () {
          _addToCart(product);
          navigator.pop();
        },
        onLikePressed: () async {
          final success = await _toggleLike(product.id);
          if (!mounted || !success) return;
          navigator.pop();
        },
      );
      },
    );
  }

  void _showFilterSheet(List<Product> products) {
    _showSheet(
      FilterSheet(
        initialOptions: _filterOptions,
        brands: _brands(products),
        sizes: _sizes(products),
        conditions: _conditions(products),
        onApply: (options) async {
          setState(() => _filterOptions = options);
          await _refreshProducts();
        },
      ),
    );
  }

  void _showUploadSheet() {
    _showSheet(
      UploadProductSheet(
        categories: productCategories,
        onUpload: (draft) async {
          try {
            await ref.read(marketProductsProvider.notifier).createProduct(
              name: draft.name,
              basePrice: draft.price,
              floorPrice: draft.floorPrice,
              brand: draft.brand,
              size: draft.size,
              category: draft.category,
              condition: draft.condition,
              description: draft.description,
              hashtags: draft.hashtags,
              imageUrls: draft.imageUrls,
              token: _sessionToken,
            );
            if (!mounted) return;
            await _loadMyProducts();
            _showSnackBar('상품을 등록했어요.');
          } catch (error) {
            if (!mounted) return;
            _showSnackBar(toUserMessage(error, fallback: '상품 등록에 실패했어요. 잠시 후 다시 시도해 주세요.'));
          }
        },
      ),
    );
  }

  void _handleUploadPressed() {
    if (!_isProfileComplete) {
      _promptProfileRequired();
      return;
    }
    _showUploadSheet();
  }

  void _showCompareSheet() {
    _showSheet(
      CompareSheet(
        products: _compareProducts,
        onRemove: (id) {
          setState(() => _compareProducts.removeWhere((product) => product.id == id));
        },
        onAddToCart: _addToCart,
      ),
    );
  }

  void _showCheckout() {
    if (!_isProfileComplete) {
      _promptProfileRequired();
      return;
    }
    _showSheet(
      CheckoutSheet(
        products: _cart,
        onComplete: (draft) async {
          final orderId = await ref.read(marketProductsProvider.notifier).createOrder(
                productIds: _cart.map((item) => item.id).toList(),
                receiverName: draft.receiverName,
                phone: draft.phone,
                address: draft.address,
                message: draft.message,
                token: _sessionToken,
              );
          if (!mounted) return orderId;
          setState(() {
            _currentOrderId = orderId;
            _cart.clear();
            _selectedTab = 3;
          });
          await _loadOrders();
          await _loadWardrobe();
          await _loadMyProducts();
          await _refreshProducts();
          return orderId;
        },
      ),
    );
  }

  void _showOrderTracking() {
    if (_currentOrderId.isEmpty) return;
    _showOrderTrackingFor(_currentOrderId);
  }

  void _showOrderTrackingFor(String orderId) {
    _showSheet(OrderTrackingSheet(orderId: orderId, loadTracking: () => ref.read(marketApiClientProvider).fetchOrderTracking(orderId)));
  }
  Future<void> _deleteMyProduct(Product product) async {
    if (_sessionToken == null) return;
    try {
      await ref.read(marketApiClientProvider).deleteProduct(product.id, token: _sessionToken);
      await _loadMyProducts();
      await _refreshProducts();
      if (!mounted) return;
      _showSnackBar('${product.name} 상품을 판매 목록에서 숨겼어요.');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(toUserMessage(error, fallback: '판매 상품을 숨기지 못했어요. 잠시 후 다시 시도해 주세요.'));
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text(
          '탈퇴하면 프로필과 옷장 정보가 지워지고, 판매 중인 상품은 숨김 처리돼요. 계속할까요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('탈퇴하기'),
          ),
        ],
      ),
    );

    if (confirmed != true || _sessionToken == null) return;

    try {
      await ref.read(marketApiClientProvider).deleteMyAccount(_sessionToken!);
      await _clearSession();
      if (!mounted) return;
      _showSnackBar('회원 탈퇴가 완료됐어요.');
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(
        toUserMessage(
          error,
          fallback: '회원 탈퇴에 실패했어요. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }
  }

  Future<void> _relistWardrobeItem(WardrobeItem item) async {
    if (_sessionToken == null) return;
    try {
      final relisted = await ref.read(marketProductsProvider.notifier).relistProduct(item.product.id, token: _sessionToken);
      await _refreshProducts();
      await _loadWardrobe();
      await _loadMyProducts();
      if (!mounted) return;
      _showSnackBar('${relisted.name} 상품을 다시 판매 목록에 올렸어요.');
      setState(() => _selectedTab = 0);
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(toUserMessage(error, fallback: '재판매 등록에 실패했어요. 잠시 후 다시 시도해 주세요.'));
    }
  }

  Future<void> _showEditProfileSheet() async {
    final profile = _userProfile;
    if (profile == null || _sessionToken == null) return;

    _showSheet(
      Scaffold(
        appBar: AppBar(title: const Text('프로필 수정')),
        body: ProfileEditorView(
          initialProfile: profile,
          title: '내 프로필을 다시 정리해 볼까요?',
          description: '성별, 사이즈, 지역 정보는 추천과 거래 흐름을 더 자연스럽게 만들어줘요.',
          submitLabel: '프로필 저장하기',
          onSubmit: (nextProfile) async {
            try {
              final updated = await ref.read(marketApiClientProvider).updateMyProfile(
                token: _sessionToken!,
                profile: nextProfile,
              );
              if (!mounted) return;
              setState(() => _userProfile = updated);
              Navigator.of(context).pop();
              _showSnackBar('프로필을 업데이트했어요.');
            } catch (error) {
              if (!mounted) return;
              _showSnackBar(
                toUserMessage(
                  error,
                  fallback: '프로필 수정에 실패했어요. 잠시 후 다시 시도해 주세요.',
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showSafetyGuide() => _showSheet(const SafetyGuideSheet());

  void _showSheet(Widget child) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.86,
        minChildSize: 0.5,
        maxChildSize: 0.94,
        builder: (context, scrollController) => PrimaryScrollController(controller: scrollController, child: child),
      ),
    );
  }

  void _rememberProduct(Product product) {
    setState(() {
      _recentlyViewed.removeWhere((item) => item.id == product.id);
      _recentlyViewed.insert(0, product);
      if (_recentlyViewed.length > 10) {
        _recentlyViewed.removeLast();
      }
    });
  }

  void _patchLocalProduct(String id, Product Function(Product product) update) {
    setState(() {
      for (var i = 0; i < _recentlyViewed.length; i++) {
        if (_recentlyViewed[i].id == id) _recentlyViewed[i] = update(_recentlyViewed[i]);
      }
      for (var i = 0; i < _compareProducts.length; i++) {
        if (_compareProducts[i].id == id) _compareProducts[i] = update(_compareProducts[i]);
      }
      for (var i = 0; i < _cart.length; i++) {
        if (_cart[i].id == id) _cart[i] = update(_cart[i]);
      }
      for (var i = 0; i < _myProducts.length; i++) {
        if (_myProducts[i].id == id) _myProducts[i] = update(_myProducts[i]);
      }
    });
  }

  List<Product> _syncProducts(List<Product> source) {
    return source.map((product) {
      final isLiked = product.isLiked || _recentlyViewed.any((item) => item.id == product.id && item.isLiked) || _compareProducts.any((item) => item.id == product.id && item.isLiked);
      return product.copyWith(isLiked: isLiked);
    }).toList();
  }

  List<String> _brands(List<Product> products) => products.map((product) => product.brand).toSet().toList()..sort();
  List<String> _sizes(List<Product> products) => products.map((product) => product.size).toSet().toList()..sort();
  List<String> _conditions(List<Product> products) => products.map((product) => product.condition).toSet().toList()..sort();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _promptProfileRequired() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('프로필을 먼저 완성해 주세요', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text('닉네임과 사이즈 정보를 입력하면 주문과 판매 흐름이 훨씬 자연스러워져요.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700, height: 1.45)),
              const SizedBox(height: 18),
              FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('확인')),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeCollectionView extends StatelessWidget {
  const _HomeCollectionView({required this.filteredProducts, required this.recentlyViewed, required this.selectedCategory, required this.searchQuery, required this.compareCount, required this.hasActiveFilters, required this.isCompared, required this.onSearchChanged, required this.onSearchCleared, required this.onCategorySelected, required this.onSafetyPressed, required this.onFilterPressed, required this.onComparePressed, required this.onProductPressed, required this.onLikePressed, required this.onToggleCompare, required this.onLoadMore, required this.hasMore, required this.isLoadingMore});

  final List<Product> filteredProducts;
  final List<Product> recentlyViewed;
  final String selectedCategory;
  final String searchQuery;
  final int compareCount;
  final bool hasActiveFilters;
  final bool Function(Product product) isCompared;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchCleared;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onSafetyPressed;
  final VoidCallback onFilterPressed;
  final VoidCallback? onComparePressed;
  final ValueChanged<Product> onProductPressed;
  final VoidCallback Function(String productId) onLikePressed;
  final ValueChanged<Product> onToggleCompare;
  final VoidCallback onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF122033), Color(0xFF2A3A52)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'TODAY\'S CURATION',
                  style: TextStyle(
                    color: Color(0xFFE5D1A6),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '지금 다시\n잘 팔릴 빈티지',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.14,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '브랜드, 상태, 시장 반응을 기준으로 오늘 볼 만한 상품을 먼저 모아봤어요.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${filteredProducts.length}개',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '현재 노출 상품',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.76),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            compareCount > 0 ? '$compareCount개' : '준비됨',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            compareCount > 0 ? '비교 담긴 상품' : '비교 기능 사용 가능',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.76),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: '브랜드, 상품명, 해시태그 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isEmpty
                    ? null
                    : IconButton(onPressed: onSearchCleared, icon: const Icon(Icons.close)),
              ),
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filledTonal(
            onPressed: onFilterPressed,
            icon: Badge(
              isLabelVisible: hasActiveFilters,
              child: const Icon(Icons.tune),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE8DFD5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '카테고리',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    selectedCategory,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6F665E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final category = productCategories[index];
                    final selected = category == selectedCategory;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        onSelected: (_) => onCategorySelected(category),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemCount: productCategories.length,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘의 셀렉션',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${filteredProducts.length}개 상품',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6F665E),
                    ),
                  ),
                ],
              ),
            ),
            if (compareCount > 0) TextButton.icon(onPressed: onComparePressed, icon: const Icon(Icons.compare_arrows, size: 18), label: Text('비교 $compareCount')),
            TextButton.icon(onPressed: onSafetyPressed, icon: const Icon(Icons.shield_outlined, size: 18), label: const Text('안전거래')),
          ],
        ),
        const SizedBox(height: 12),
        if (filteredProducts.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 48), child: Center(child: Text('조건에 맞는 상품이 없어요.')))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.58, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return ProductCard(product: product, onTap: () => onProductPressed(product), onLikePressed: onLikePressed(product.id), onComparePressed: () => onToggleCompare(product), isCompared: isCompared(product));
            },
          ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: isLoadingMore
                ? const Center(child: CircularProgressIndicator())
                : OutlinedButton(onPressed: onLoadMore, child: const Text('더 보기')),
          ),
        RecentlyViewedStrip(products: recentlyViewed, onProductPressed: onProductPressed),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => unawaited(onRetry()), child: const Text('다시 시도')),
          ],
        ),
      ),
    );
  }
}

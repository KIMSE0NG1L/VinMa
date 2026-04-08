import 'package:flutter/material.dart';

import '../../market/data/sample_products.dart';
import '../../market/domain/filter_options.dart';
import '../../market/domain/product.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = 'home';
  static const routePath = '/';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Product> _products = sampleProducts;
  final List<Product> _cart = [];
  final List<Product> _compareProducts = [];
  final List<Product> _recentlyViewed = [];
  String _selectedCategory = productCategories.first;
  String _searchQuery = '';
  String _userEmail = '';
  String _currentOrderId = '';
  int _selectedTab = 0;
  bool _isLoggedIn = false;
  FilterOptions _filterOptions = const FilterOptions();

  List<Product> get _filteredProducts {
    final filtered = _products.where((product) {
      final matchesCategory =
          _selectedCategory == productCategories.first ||
          product.category == _selectedCategory;
      final lowerQuery = _searchQuery.trim().toLowerCase();
      final matchesSearch =
          lowerQuery.isEmpty ||
          product.name.toLowerCase().contains(lowerQuery) ||
          product.brand.toLowerCase().contains(lowerQuery);
      final matchesPrice = product.price <= _filterOptions.maxPrice;
      final matchesBrand =
          _filterOptions.brands.isEmpty ||
          _filterOptions.brands.contains(product.brand);
      final matchesSize =
          _filterOptions.sizes.isEmpty ||
          _filterOptions.sizes.contains(product.size);
      final matchesCondition =
          _filterOptions.conditions.isEmpty ||
          _filterOptions.conditions.contains(product.condition);

      return matchesCategory &&
          matchesSearch &&
          matchesPrice &&
          matchesBrand &&
          matchesSize &&
          matchesCondition;
    }).toList();

    switch (_filterOptions.sortOption) {
      case SortOption.priceLow:
        filtered.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceHigh:
        filtered.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.popular:
        filtered.sort(
          (a, b) => b.isLiked.toString().compareTo(a.isLiked.toString()),
        );
      case SortOption.latest:
        filtered.sort((a, b) => b.id.compareTo(a.id));
    }

    return filtered;
  }

  List<String> get _brands {
    return _products.map((product) => product.brand).toSet().toList()..sort();
  }

  List<String> get _sizes {
    return _products.map((product) => product.size).toSet().toList()..sort();
  }

  List<String> get _conditions {
    return _products.map((product) => product.condition).toSet().toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '빈티지',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '마켓',
              style: textTheme.labelSmall?.copyWith(
                color: Colors.grey.shade600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _HomeCollectionView(
            filteredProducts: _filteredProducts,
            recentlyViewed: _recentlyViewed,
            selectedCategory: _selectedCategory,
            searchQuery: _searchQuery,
            compareCount: _compareProducts.length,
            hasActiveFilters: _filterOptions.hasActiveFilters,
            isCompared: (product) {
              return _compareProducts.any((item) => item.id == product.id);
            },
            onSearchChanged: (value) => setState(() => _searchQuery = value),
            onSearchCleared: () => setState(() => _searchQuery = ''),
            onCategorySelected: (category) {
              setState(() => _selectedCategory = category);
            },
            onSafetyPressed: _showSafetyGuide,
            onFilterPressed: _showFilterSheet,
            onComparePressed: _compareProducts.isEmpty
                ? null
                : _showCompareSheet,
            onProductPressed: _showProductDetail,
            onLikePressed: _toggleLike,
            onToggleCompare: _toggleCompare,
          ),
          SwipeView(
            products: _products,
            onLike: _toggleLike,
            onAddToCart: _addToCartFromSwipe,
          ),
          BagView(
            products: _cart,
            onRemove: _removeFromCart,
            onCheckout: _showCheckout,
          ),
          ProfileView(
            isLoggedIn: _isLoggedIn,
            email: _userEmail,
            onLogin: (email) {
              setState(() {
                _isLoggedIn = true;
                _userEmail = email;
              });
            },
            onLogout: () {
              setState(() {
                _isLoggedIn = false;
                _userEmail = '';
              });
            },
          ),
        ],
      ),
      floatingActionButton: _selectedTab == 0
          ? FloatingActionButton(
              onPressed: _showUploadSheet,
              child: const Icon(Icons.add),
            )
          : _selectedTab == 3 && _currentOrderId.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showOrderTracking,
              icon: const Icon(Icons.local_shipping_outlined),
              label: const Text('배송조회'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: '홈',
          ),
          const NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department),
            label: '스와이프',
          ),
          NavigationDestination(
            icon: Badge.count(
              count: _cart.length,
              isLabelVisible: _cart.isNotEmpty,
              child: const Icon(Icons.favorite_border),
            ),
            selectedIcon: Badge.count(
              count: _cart.length,
              isLabelVisible: _cart.isNotEmpty,
              child: const Icon(Icons.favorite),
            ),
            label: '가방',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '마이',
          ),
        ],
      ),
    );
  }

  void _toggleLike(int productId) {
    setState(() {
      _products = [
        for (final product in _products)
          if (product.id == productId)
            product.copyWith(isLiked: !product.isLiked)
          else
            product,
      ];
    });
  }

  void _toggleCompare(Product product) {
    setState(() {
      final index = _compareProducts.indexWhere(
        (item) => item.id == product.id,
      );
      if (index >= 0) {
        _compareProducts.removeAt(index);
      } else {
        _compareProducts.add(product);
      }
    });
  }

  void _addToCart(Product product, {bool shouldPop = false}) {
    if (!_cart.any((item) => item.id == product.id)) {
      setState(() => _cart.add(product));
    }

    if (shouldPop) {
      Navigator.of(context).pop();
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${product.name}을 담았습니다')));
  }

  void _addToCartFromSwipe(Product product) {
    _addToCart(product);
  }

  void _removeFromCart(int productId) {
    setState(() => _cart.removeWhere((product) => product.id == productId));
  }

  void _showProductDetail(Product product) {
    _rememberProduct(product);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final currentProduct = _products.firstWhere(
          (item) => item.id == product.id,
        );

        return ProductDetailSheet(
          product: currentProduct,
          isInCart: _cart.any((item) => item.id == currentProduct.id),
          onAddToCart: () => _addToCart(currentProduct, shouldPop: true),
          onLikePressed: () {
            _toggleLike(currentProduct.id);
            Navigator.of(context).pop();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final updatedProduct = _products.firstWhere(
                (item) => item.id == currentProduct.id,
              );
              _showProductDetail(updatedProduct);
            });
          },
        );
      },
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

  void _showFilterSheet() {
    _showSheet(
      FilterSheet(
        initialOptions: _filterOptions,
        brands: _brands,
        sizes: _sizes,
        conditions: _conditions,
        onApply: (options) => setState(() => _filterOptions = options),
      ),
    );
  }

  void _showUploadSheet() {
    _showSheet(
      UploadProductSheet(
        categories: productCategories,
        nextId:
            _products
                .map((product) => product.id)
                .reduce((a, b) => a > b ? a : b) +
            1,
        onUpload: (product) {
          setState(() {
            _products = [product, ..._products];
            _selectedCategory = productCategories.first;
          });
        },
      ),
    );
  }

  void _showCompareSheet() {
    _showSheet(
      CompareSheet(
        products: _compareProducts,
        onRemove: (id) {
          setState(() {
            _compareProducts.removeWhere((product) => product.id == id);
          });
        },
        onAddToCart: (product) => _addToCart(product),
      ),
    );
  }

  void _showCheckout() {
    _showSheet(
      CheckoutSheet(
        products: _cart,
        onComplete: (orderId) {
          setState(() {
            _currentOrderId = orderId;
            _cart.clear();
            _selectedTab = 3;
          });
          Navigator.of(context).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showOrderTracking();
          });
        },
      ),
    );
  }

  void _showOrderTracking() {
    if (_currentOrderId.isEmpty) {
      return;
    }

    _showSheet(OrderTrackingSheet(orderId: _currentOrderId));
  }

  void _showSafetyGuide() {
    _showSheet(const SafetyGuideSheet());
  }

  void _showSheet(Widget child) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.86,
        minChildSize: 0.5,
        maxChildSize: 0.94,
        builder: (context, scrollController) {
          return PrimaryScrollController(
            controller: scrollController,
            child: child,
          );
        },
      ),
    );
  }
}

class _HomeCollectionView extends StatelessWidget {
  const _HomeCollectionView({
    required this.filteredProducts,
    required this.recentlyViewed,
    required this.selectedCategory,
    required this.searchQuery,
    required this.compareCount,
    required this.hasActiveFilters,
    required this.isCompared,
    required this.onSearchChanged,
    required this.onSearchCleared,
    required this.onCategorySelected,
    required this.onSafetyPressed,
    required this.onFilterPressed,
    required this.onComparePressed,
    required this.onProductPressed,
    required this.onLikePressed,
    required this.onToggleCompare,
  });

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
  final ValueChanged<int> onLikePressed;
  final ValueChanged<Product> onToggleCompare;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: '빈티지 아이템 검색',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: onSearchCleared,
                          icon: const Icon(Icons.close),
                        ),
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
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 42,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final category = productCategories[index];
              final isSelected = category == selectedCategory;

              return ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (_) => onCategorySelected(category),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemCount: productCategories.length,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 8,
          children: [
            Text(
              '${filteredProducts.length}개 컬렉션',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (compareCount > 0)
                  TextButton.icon(
                    onPressed: onComparePressed,
                    icon: const Icon(Icons.compare_arrows, size: 18),
                    label: Text('비교 $compareCount'),
                  ),
                TextButton.icon(
                  onPressed: onSafetyPressed,
                  icon: const Icon(Icons.shield_outlined, size: 18),
                  label: const Text('안전거래'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filteredProducts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: Text('조건에 맞는 상품이 없습니다.')),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];

              return ProductCard(
                product: product,
                onTap: () => onProductPressed(product),
                onLikePressed: () => onLikePressed(product.id),
                onComparePressed: () => onToggleCompare(product),
                isCompared: isCompared(product),
              );
            },
          ),
        RecentlyViewedStrip(
          products: recentlyViewed,
          onProductPressed: onProductPressed,
        ),
      ],
    );
  }
}

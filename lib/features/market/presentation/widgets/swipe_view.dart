import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/product.dart';

class SwipeView extends StatefulWidget {
  const SwipeView({
    required this.products,
    required this.onLike,
    required this.onAddToCart,
    super.key,
  });

  final List<Product> products;
  final ValueChanged<int> onLike;
  final ValueChanged<Product> onAddToCart;

  @override
  State<SwipeView> createState() => _SwipeViewState();
}

class _SwipeViewState extends State<SwipeView> {
  static const _swipeThreshold = 110.0;

  int _index = 0;
  Offset _dragOffset = Offset.zero;

  Product? get _currentProduct {
    if (widget.products.isEmpty) {
      return null;
    }

    return widget.products[_index % widget.products.length];
  }

  @override
  Widget build(BuildContext context) {
    final product = _currentProduct;

    if (product == null) {
      return const Center(child: Text('표시할 상품이 없습니다.'));
    }

    final currency = NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    ).format(product.price);
    final width = MediaQuery.sizeOf(context).width;
    final rotation = (_dragOffset.dx / width).clamp(-0.18, 0.18);
    final likeOpacity = (_dragOffset.dx / _swipeThreshold).clamp(0.0, 1.0);
    final passOpacity = (-_dragOffset.dx / _swipeThreshold).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      children: [
        Text(
          '가격 매칭',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 4),
        Text(
          '왼쪽은 패스, 오른쪽은 관심',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey.shade600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onPanUpdate: (details) {
            setState(() => _dragOffset += details.delta);
          },
          onPanEnd: (_) => _handlePanEnd(product),
          child: AnimatedContainer(
            duration: _dragOffset == Offset.zero
                ? const Duration(milliseconds: 180)
                : Duration.zero,
            curve: Curves.easeOut,
            transform: Matrix4.identity()
              ..translateByDouble(_dragOffset.dx, _dragOffset.dy * 0.25, 0, 1)
              ..rotateZ(rotation),
            transformAlignment: Alignment.center,
            child: Stack(
              children: [
                _SwipeProductCard(product: product, currency: currency),
                Positioned(
                  top: 24,
                  left: 24,
                  child: _SwipeStamp(
                    label: '관심',
                    color: Colors.green,
                    opacity: likeOpacity,
                    angle: -math.pi / 16,
                  ),
                ),
                Positioned(
                  top: 24,
                  right: 24,
                  child: _SwipeStamp(
                    label: '패스',
                    color: Colors.redAccent,
                    opacity: passOpacity,
                    angle: math.pi / 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pass,
                icon: const Icon(Icons.close),
                label: const Text('패스'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  widget.onAddToCart(product);
                  _next();
                },
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('담기'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _like(product),
                icon: const Icon(Icons.favorite_border),
                label: const Text('관심'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handlePanEnd(Product product) {
    if (_dragOffset.dx > _swipeThreshold) {
      _like(product);
      return;
    }

    if (_dragOffset.dx < -_swipeThreshold) {
      _pass();
      return;
    }

    setState(() => _dragOffset = Offset.zero);
  }

  void _like(Product product) {
    widget.onLike(product.id);
    _next();
  }

  void _pass() {
    _next();
  }

  void _next() {
    setState(() {
      _index += 1;
      _dragOffset = Offset.zero;
    });
  }
}

class _SwipeProductCard extends StatelessWidget {
  const _SwipeProductCard({required this.product, required this.currency});

  final Product product;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  ColoredBox(color: Colors.grey.shade200),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.image_not_supported_outlined),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.brand,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                    Icon(
                      product.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: product.isLiked ? Colors.redAccent : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  currency,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeStamp extends StatelessWidget {
  const _SwipeStamp({
    required this.label,
    required this.color,
    required this.opacity,
    required this.angle,
  });

  final String label;
  final Color color;
  final double opacity;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: angle,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: color, width: 3),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withValues(alpha: 0.82),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

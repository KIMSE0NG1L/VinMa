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
  int _index = 0;

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
          '넘기면서 가격 반응을 확인하세요',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey.shade600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 20),
        Card(
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
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ),
                        Icon(
                          product.isLiked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product.isLiked ? Colors.redAccent : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currency,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _next,
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
                onPressed: () {
                  widget.onLike(product.id);
                  _next();
                },
                icon: const Icon(Icons.favorite_border),
                label: const Text('관심'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _next() {
    setState(() => _index += 1);
  }
}

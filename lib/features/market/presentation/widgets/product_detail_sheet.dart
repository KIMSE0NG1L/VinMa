import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/product.dart';

class ProductDetailSheet extends StatelessWidget {
  const ProductDetailSheet({
    required this.product,
    required this.isInCart,
    required this.onAddToCart,
    required this.onLikePressed,
    super.key,
  });

  final Product product;
  final bool isInCart;
  final VoidCallback onAddToCart;
  final VoidCallback onLikePressed;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    ).format(product.price);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      minChildSize: 0.5,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      ColoredBox(color: Colors.grey.shade200),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.brand,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: onLikePressed,
                  icon: Icon(
                    product.isLiked ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: product.isLiked ? Colors.redAccent : null,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              currency,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  label: product.category,
                  icon: Icons.category_outlined,
                ),
                _InfoChip(
                  label: product.condition,
                  icon: Icons.verified_outlined,
                ),
                _InfoChip(label: product.size, icon: Icons.straighten_outlined),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '아이템 스토리',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: isInCart ? null : onAddToCart,
              icon: Icon(
                isInCart
                    ? Icons.check_circle_outline
                    : Icons.shopping_bag_outlined,
              ),
              label: Text(isInCart ? '이미 담긴 상품' : '가방에 담기'),
            ),
          ],
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      side: BorderSide(color: Colors.grey.shade200),
      backgroundColor: Colors.grey.shade50,
    );
  }
}

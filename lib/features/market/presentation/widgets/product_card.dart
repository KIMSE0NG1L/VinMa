import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/vinma_image.dart';
import '../../domain/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    required this.onLikePressed,
    required this.onComparePressed,
    required this.onTap,
    required this.isCompared,
    super.key,
  });

  final Product product;
  final VoidCallback onLikePressed;
  final VoidCallback onComparePressed;
  final VoidCallback onTap;
  final bool isCompared;

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.imageUrls.isNotEmpty
        ? product.imageUrls.first
        : product.imageUrl;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 0.88,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: _ProductCardImage(imageUrl: imageUrl),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _ActionCircleButton(
                      icon: Icons.compare_arrows,
                      isActive: isCompared,
                      onPressed: onComparePressed,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _ActionCircleButton(
                      icon: product.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      isActive: product.isLiked,
                      activeColor: Colors.redAccent,
                      onPressed: onLikePressed,
                    ),
                  ),
                  if (product.imageUrls.length > 1)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: _OverlayBadge(
                        label: '${product.imageUrls.length}장',
                        backgroundColor: Colors.black.withValues(alpha: 0.58),
                      ),
                    ),
                  if (product.hasPriceDrop)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: _OverlayBadge(
                        label: '-${(product.priceDropRate * 100).round()}%',
                        backgroundColor: const Color(0xFFCC5B52),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF6F665E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                    Text(
                      _priceFormat.format(product.price),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (product.hasPriceDrop) ...[
                      const SizedBox(height: 4),
                      Text(
                        '초기 ${_priceFormat.format(product.basePrice)}에서 하락',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFFCC5B52),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _InfoPill(label: product.condition),
                        _InfoPill(label: product.size),
                        if (product.likeCount > 0)
                          _InfoPill(label: '관심 ${product.likeCount}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCardImage extends StatelessWidget {
  const _ProductCardImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return ColoredBox(
        color: const Color(0xFFF0ECE8),
        child: const Icon(Icons.image_not_supported_outlined),
      );
    }

    if (imageUrl.startsWith('file://')) {
      final file = File(Uri.parse(imageUrl).toFilePath());
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => ColoredBox(
          color: const Color(0xFFF0ECE8),
          child: const Icon(Icons.image_not_supported_outlined),
        ),
      );
    }

    return VinMaImage(url: imageUrl, fit: BoxFit.cover);
  }
}

class _ActionCircleButton extends StatelessWidget {
  const _ActionCircleButton({
    required this.icon,
    required this.isActive,
    required this.onPressed,
    this.activeColor,
  });

  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            size: 18,
            color: isActive
                ? (activeColor ?? Theme.of(context).colorScheme.primary)
                : const Color(0xFF58483C),
          ),
        ),
      ),
    );
  }
}

class _OverlayBadge extends StatelessWidget {
  const _OverlayBadge({
    required this.label,
    required this.backgroundColor,
  });

  final String label;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4F1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(label, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}

final _priceFormat = NumberFormat.currency(
  locale: 'ko_KR',
  symbol: '₩',
  decimalDigits: 0,
);

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/vinma_image.dart';
import '../../domain/product.dart';

class ProductDetailSheet extends StatefulWidget {
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
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  late final PageController _pageController;
  int _selectedImageIndex = 0;

  List<String> get _images {
    final urls = widget.product.imageUrls;
    if (urls.isNotEmpty) {
      return urls;
    }
    if (widget.product.imageUrl.isNotEmpty) {
      return [widget.product.imageUrl];
    }
    return const [''];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.92,
      minChildSize: 0.55,
      maxChildSize: 0.96,
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
                  color: const Color(0xFFD8D1C9),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _DetailGallery(
              images: _images,
              selectedIndex: _selectedImageIndex,
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _selectedImageIndex = index);
              },
              onThumbnailTap: (index) {
                setState(() => _selectedImageIndex = index);
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                );
              },
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.brand,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: const Color(0xFF6F665E),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.product.name,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _DetailActionButton(
                  icon: widget.product.isLiked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  isActive: widget.product.isLiked,
                  activeColor: Colors.redAccent,
                  onPressed: widget.onLikePressed,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _PricePanel(product: widget.product),
            const SizedBox(height: 18),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(label: widget.product.category),
                _InfoChip(label: widget.product.condition),
                _InfoChip(label: '사이즈 ${widget.product.size}'),
                _InfoChip(label: _statusLabel(widget.product.status)),
                _InfoChip(label: '조회 ${widget.product.viewCount}'),
              ],
            ),
            const SizedBox(height: 18),
            _SectionBox(
              title: '시장 반응',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MetricTile(
                          label: '관심',
                          value: '${widget.product.likeCount}',
                          tone: const Color(0xFFCC5B52),
                        ),
                      ),
                      Expanded(
                        child: _MetricTile(
                          label: '패스',
                          value: '${widget.product.passCount}',
                          tone: const Color(0xFFB07B43),
                        ),
                      ),
                      Expanded(
                        child: _MetricTile(
                          label: '최저가',
                          value: _currency.format(widget.product.floorPrice),
                          tone: const Color(0xFF4A3728),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.product.hasPriceDrop
                        ? '현재 가격은 초기 등록가보다 ${(widget.product.priceDropRate * 100).round()}% 낮아졌어요.'
                        : '아직 가격 조정은 없어요. 반응이 쌓이면 가격 흐름이 달라질 수 있어요.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6F665E),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.product.hashtags.isNotEmpty) ...[
              const SizedBox(height: 18),
              _SectionBox(
                title: '태그',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in widget.product.hashtags)
                      _TagChip(label: '#$tag'),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            _SectionBox(
              title: '상품 설명',
              child: Text(
                widget.product.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4C433C),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _SectionBox(
              title: '빈마온 메모',
              child: Text(
                '패스가 쌓이면 가격이 조금씩 내려가고, 관심이 높으면 현재 가격이 더 오래 유지돼요. 마음에 드는 상품은 늦기 전에 담아두는 쪽이 좋아요.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF6F665E),
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: widget.isInCart ? null : widget.onAddToCart,
              icon: Icon(
                widget.isInCart
                    ? Icons.check_circle_outline
                    : Icons.shopping_bag_outlined,
              ),
              label: Text(widget.isInCart ? '이미 가방에 담긴 상품' : '가방에 담기'),
            ),
          ],
        );
      },
    );
  }
}

class _DetailGallery extends StatelessWidget {
  const _DetailGallery({
    required this.images,
    required this.selectedIndex,
    required this.controller,
    required this.onPageChanged,
    required this.onThumbnailTap,
  });

  final List<String> images;
  final int selectedIndex;
  final PageController controller;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onThumbnailTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 0.9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: controller,
                  itemCount: images.length,
                  onPageChanged: onPageChanged,
                  itemBuilder: (context, index) {
                    return VinMaImage(
                      url: images[index],
                      fit: BoxFit.cover,
                      placeholder: const ColoredBox(color: Color(0xFFF0ECE8)),
                      error: const Icon(Icons.image_not_supported_outlined),
                    );
                  },
                ),
                if (images.length > 1)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.58),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: Text(
                          '${selectedIndex + 1} / ${images.length}',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 74,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;
                return InkWell(
                  onTap: () => onThumbnailTap(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : const Color(0xFFE7E1DA),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: VinMaImage(
                        url: images[index],
                        fit: BoxFit.cover,
                        placeholder: const ColoredBox(color: Color(0xFFF0ECE8)),
                        error: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _PricePanel extends StatelessWidget {
  const _PricePanel({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1C34),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currency.format(product.price),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: const Color(0xFFE3C37A),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.hasPriceDrop
                ? '초기 ${_currency.format(product.basePrice)}에서 ${_currency.format(product.priceDropAmount)} 하락'
                : '아직 가격 조정 없이 현재가를 유지하고 있어요.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionBox extends StatelessWidget {
  const _SectionBox({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7E1DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF6F665E),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: tone,
          ),
        ),
      ],
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  const _DetailActionButton({
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
      color: const Color(0xFFF6F4F1),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 20,
            color: isActive
                ? (activeColor ?? Theme.of(context).colorScheme.primary)
                : const Color(0xFF4A3728),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4F1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(label, style: Theme.of(context).textTheme.labelSmall),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'SOLD':
      return '판매 완료';
    case 'RESERVED':
      return '예약 중';
    case 'HIDDEN':
      return '숨김';
    case 'ACTIVE':
    default:
      return '판매 중';
  }
}

final _currency = NumberFormat.currency(
  locale: 'ko_KR',
  symbol: '₩',
  decimalDigits: 0,
);

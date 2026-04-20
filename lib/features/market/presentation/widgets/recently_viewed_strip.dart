import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/vinma_image.dart';
import '../../domain/product.dart';

class RecentlyViewedStrip extends StatelessWidget {
  const RecentlyViewedStrip({
    required this.products,
    required this.onProductPressed,
    super.key,
  });

  final List<Product> products;
  final ValueChanged<Product> onProductPressed;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    final currency = NumberFormat.compactCurrency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Text(
          '최근 본 상품',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 132,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = products[index];

              return InkWell(
                onTap: () => onProductPressed(product),
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 92,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: VinMaImage(
                            url: product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: ColoredBox(
                              color: Colors.grey.shade200,
                            ),
                            error: const Icon(
                              Icons.image_not_supported_outlined,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        currency.format(product.price),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

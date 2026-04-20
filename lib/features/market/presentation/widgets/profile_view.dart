import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/vinma_image.dart';
import '../../domain/order_summary.dart';
import '../../domain/product.dart';
import '../../domain/user_profile.dart';
import '../../domain/wardrobe_item.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({
    required this.profile,
    required this.orders,
    required this.wardrobeItems,
    required this.myProducts,
    required this.onEditProfile,
    required this.onOrderSelected,
    required this.onRelistWardrobeItem,
    required this.onDeleteProduct,
    required this.onDeleteAccount,
    required this.onLogout,
    super.key,
  });

  final UserProfile profile;
  final List<OrderSummary> orders;
  final List<WardrobeItem> wardrobeItems;
  final List<Product> myProducts;
  final Future<void> Function() onEditProfile;
  final ValueChanged<String> onOrderSelected;
  final Future<void> Function(WardrobeItem item) onRelistWardrobeItem;
  final Future<void> Function(Product product) onDeleteProduct;
  final Future<void> Function() onDeleteAccount;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      children: [
        Text('마이 빈마온', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        _ProfileHeaderCard(
          profile: profile,
          onEditProfile: onEditProfile,
        ),
        const SizedBox(height: 14),
        _ProfileSummaryCard(items: wardrobeItems),
        const SizedBox(height: 24),
        _SectionTitle(
          title: '판매 관리',
          subtitle: '판매 중인 상품 상태를 정리하고 숨김 처리할 수 있어요.',
        ),
        const SizedBox(height: 10),
        if (myProducts.isEmpty)
          const _EmptyCard(
            message: '아직 등록한 판매 상품이 없어요. 첫 상품을 올리면 여기서 관리할 수 있어요.',
          )
        else ...[
          _SaleSummaryCard(items: myProducts),
          const SizedBox(height: 10),
          ...myProducts.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SaleProductCard(
                product: product,
                onDelete: () => onDeleteProduct(product),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        _SectionTitle(
          title: '주문 내역',
          subtitle: '최근 주문과 배송 흐름을 여기서 확인해요.',
        ),
        const SizedBox(height: 10),
        if (orders.isEmpty)
          const _EmptyCard(message: '아직 주문 내역이 없어요.')
        else
          ...orders.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _OrderSummaryCard(
                order: order,
                onTap: () => onOrderSelected(order.id),
              ),
            ),
          ),
        const SizedBox(height: 24),
        _SectionTitle(
          title: '내 옷장',
          subtitle: '구매한 상품을 보관하고 다시 판매로 돌릴 수 있어요.',
        ),
        const SizedBox(height: 10),
        if (wardrobeItems.isEmpty)
          const _EmptyCard(
            message: '아직 옷장에 담긴 상품이 없어요. 구매한 상품은 자동으로 이곳에 정리돼요.',
          )
        else
          ...wardrobeItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _WardrobeItemCard(
                item: item,
                onRelist: () => onRelistWardrobeItem(item),
              ),
            ),
          ),
        const SizedBox(height: 20),
        FilledButton.tonalIcon(
          onPressed: onDeleteAccount,
          icon: const Icon(Icons.person_remove_outlined),
          label: const Text('회원 탈퇴'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onLogout,
          icon: const Icon(Icons.logout),
          label: const Text('로그아웃'),
        ),
      ],
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.profile,
    required this.onEditProfile,
  });

  final UserProfile profile;
  final Future<void> Function() onEditProfile;

  @override
  Widget build(BuildContext context) {
    final initials = profile.nickname.isNotEmpty
        ? profile.nickname.substring(0, 1)
        : 'V';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7E1DA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  initials,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.nickname.isEmpty ? '닉네임 미설정' : profile.nickname,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6F665E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (profile.gender.isNotEmpty) _InfoChip(profile.gender),
              if (profile.shoeSize.isNotEmpty) _InfoChip('신발 ${profile.shoeSize}'),
              if (profile.topSize.isNotEmpty) _InfoChip('상의 ${profile.topSize}'),
              if (profile.bottomSize.isNotEmpty)
                _InfoChip('하의 ${profile.bottomSize}'),
              if (profile.heightCm.isNotEmpty) _InfoChip('${profile.heightCm}cm'),
              if (profile.region.isNotEmpty) _InfoChip(profile.region),
            ],
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onEditProfile,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('프로필 수정'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF6F665E),
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4F1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF6F665E),
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.items});

  final List<WardrobeItem> items;

  @override
  Widget build(BuildContext context) {
    final averageLiquidity = items.isEmpty
        ? null
        : items
                  .map((item) => item.liquidityScore ?? 0)
                  .reduce((a, b) => a + b) ~/
              items.length;
    final estimatedValue = items.fold<int>(
      0,
      (sum, item) => sum + (item.estimatedResalePrice ?? item.purchasePrice),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4F1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryMetric(
              label: '보유 상품',
              value: '${items.length}개',
            ),
          ),
          Expanded(
            child: _SummaryMetric(
              label: '평균 유동성',
              value: averageLiquidity == null ? '-' : '$averageLiquidity점',
            ),
          ),
          Expanded(
            child: _SummaryMetric(
              label: '예상 가치',
              value: _currency.format(estimatedValue),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleSummaryCard extends StatelessWidget {
  const _SaleSummaryCard({required this.items});

  final List<Product> items;

  @override
  Widget build(BuildContext context) {
    final activeCount = items.where((item) => item.status == 'ACTIVE').length;
    final soldCount = items.where((item) => item.status == 'SOLD').length;
    final hiddenCount = items.where((item) => item.status == 'HIDDEN').length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4F1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryMetric(label: '등록 상품', value: '${items.length}개'),
          ),
          Expanded(
            child: _SummaryMetric(label: '판매 중', value: '$activeCount개'),
          ),
          Expanded(
            child: _SummaryMetric(
              label: '완료/숨김',
              value: '${soldCount + hiddenCount}개',
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleProductCard extends StatelessWidget {
  const _SaleProductCard({
    required this.product,
    required this.onDelete,
  });

  final Product product;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7E1DA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ThumbImage(url: product.imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.brand,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF6F665E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(product.name, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(_productStatusLabel(product.status)),
                    _InfoChip('사이즈 ${product.size}'),
                    _InfoChip('관심 ${product.likeCount}'),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '현재가 ${_currency.format(product.price)}  |  조회 ${product.viewCount}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6F665E),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.visibility_off_outlined),
                  label: const Text('목록에서 숨기기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WardrobeItemCard extends StatelessWidget {
  const _WardrobeItemCard({
    required this.item,
    required this.onRelist,
  });

  final WardrobeItem item;
  final Future<void> Function() onRelist;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7E1DA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ThumbImage(url: item.product.imageUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.brand,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF6F665E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.product.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip('사이즈 ${item.product.size}'),
                    _InfoChip(
                      '유동성 ${item.liquidityScore?.toString() ?? '-'}',
                    ),
                    _InfoChip(_wardrobeStatusLabel(item.status)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '구매가 ${_currency.format(item.purchasePrice)}  |  예상 리셀 ${_currency.format(item.estimatedResalePrice ?? item.purchasePrice)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6F665E),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onRelist,
                  icon: const Icon(Icons.refresh),
                  label: const Text('재판매하기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.order,
    required this.onTap,
  });

  final OrderSummary order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = order.items.isNotEmpty ? order.items.first.product : null;
    final subtitle = order.items.length <= 1
        ? (preview?.name ?? '주문 상품')
        : '${preview?.name ?? '주문 상품'} 외 ${order.items.length - 1}개';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7E1DA)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(14),
        leading: _ThumbImage(url: preview?.imageUrl ?? ''),
        title: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '${_orderStatusLabel(order.status)}  |  ${_currency.format(order.totalPrice)}',
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _ThumbImage extends StatelessWidget {
  const _ThumbImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 72,
        height: 72,
        child: url.isEmpty
            ? ColoredBox(
                color: const Color(0xFFF0ECE8),
                child: const Icon(Icons.image_not_supported_outlined),
              )
            : VinMaImage(
                url: url,
                fit: BoxFit.cover,
                placeholder: const ColoredBox(color: Color(0xFFF0ECE8)),
                error: const Icon(Icons.image_not_supported_outlined),
              ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

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
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label);

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

String _productStatusLabel(String status) {
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

String _wardrobeStatusLabel(String status) {
  switch (status) {
    case 'RELISTED':
      return '재판매 중';
    case 'SOLD':
      return '판매 완료';
    case 'HOLDING':
    default:
      return '보유 중';
  }
}

String _orderStatusLabel(String status) {
  switch (status) {
    case 'DELIVERED':
      return '배송 완료';
    case 'SHIPPING':
      return '배송 중';
    case 'CANCELED':
      return '주문 취소';
    case 'PREPARING':
    default:
      return '상품 준비 중';
  }
}

final _currency = NumberFormat.currency(
  locale: 'ko_KR',
  symbol: '₩',
  decimalDigits: 0,
);

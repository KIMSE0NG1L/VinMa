import 'package:flutter/material.dart';

class SafetyGuideSheet extends StatelessWidget {
  const SafetyGuideSheet({super.key});

  @override
  Widget build(BuildContext context) {
    const tips = [
      '판매자 프로필과 거래 이력을 확인하세요.',
      '결제 전 상태 사진과 설명을 꼼꼼히 확인하세요.',
      '사이즈나 하자가 애매하면 추가 사진을 요청하세요.',
      '배송 거래는 안전결제 흐름을 이용하세요.',
      '거래 초반부터 외부 메신저로 이동하는 요청은 조심하세요.',
    ];
    const warnings = [
      '시세보다 지나치게 낮은 가격입니다.',
      '판매자가 상세 사진 요청을 거절합니다.',
      '급하게 결제를 요구합니다.',
      '프로필이나 거래 이력이 비어 있거나 어색합니다.',
      '앱 밖에서 결제를 요구합니다.',
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '안전거래 가이드',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _GuideSection(
            title: '안전거래 체크리스트',
            color: Colors.green,
            icon: Icons.check_circle_outline,
            items: tips,
          ),
          const SizedBox(height: 20),
          _GuideSection(
            title: '주의해야 할 신호',
            color: Colors.red,
            icon: Icons.warning_amber_outlined,
            items: warnings,
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('고객센터: 1588-1234\nsupport@vintage-market.com'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({
    required this.title,
    required this.color,
    required this.icon,
    required this.items,
  });

  final String title;
  final MaterialColor color;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color.shade700),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final item in items)
          Card(
            color: color.shade50,
            child: ListTile(
              leading: Icon(icon, color: color.shade700),
              title: Text(item),
            ),
          ),
      ],
    );
  }
}

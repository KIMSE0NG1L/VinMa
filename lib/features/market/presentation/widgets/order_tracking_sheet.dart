import 'package:flutter/material.dart';

class OrderTrackingSheet extends StatelessWidget {
  const OrderTrackingSheet({required this.orderId, super.key});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TrackingStep('주문 접수', '방금 전', Icons.check_circle, true),
      _TrackingStep('상품 준비중', '다음 업데이트 예정', Icons.inventory_2, true),
      _TrackingStep('배송중', '내일 출발 예정', Icons.local_shipping, false),
      _TrackingStep('배송 완료', '곧 업데이트 예정', Icons.flag, false),
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
          Text(
            '배송 조회',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('주문번호', style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(
                    orderId,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('택배사: CJ대한통운'),
                  const Text('운송장: 1234-5678-9012'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          for (var index = 0; index < steps.length; index++)
            _TrackingTile(
              step: steps[index],
              isLast: index == steps.length - 1,
            ),
          const SizedBox(height: 16),
          Card(
            color: Colors.blue.shade50,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('배송 문의: 1588-1234'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingStep {
  const _TrackingStep(this.title, this.time, this.icon, this.completed);

  final String title;
  final String time;
  final IconData icon;
  final bool completed;
}

class _TrackingTile extends StatelessWidget {
  const _TrackingTile({required this.step, required this.isLast});

  final _TrackingStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final color = step.completed ? primary : Colors.grey.shade400;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              backgroundColor: color,
              foregroundColor: Colors.white,
              child: Icon(step.icon, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: step.completed ? primary : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: step.completed ? null : Colors.grey.shade500,
                  ),
                ),
                Text(step.time),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

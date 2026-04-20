import 'package:flutter/material.dart';

import '../../domain/order_summary.dart';

class OrderTrackingSheet extends StatelessWidget {
  const OrderTrackingSheet({
    required this.orderId,
    required this.loadTracking,
    super.key,
  });

  final String orderId;
  final Future<OrderTrackingData> Function() loadTracking;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<OrderTrackingData>(
        future: loadTracking(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _SheetHandle(),
                const SizedBox(height: 18),
                Text(
                  '배송 조회',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '배송 정보를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            );
          }

          final tracking = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              const _SheetHandle(),
              const SizedBox(height: 18),
              Text(
                '배송 조회',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.grey.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '주문번호',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orderId,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text('택배사  ${tracking.carrier}'),
                      Text('송장번호  ${tracking.trackingNumber}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              for (var index = 0; index < tracking.steps.length; index++)
                _TrackingTile(
                  step: tracking.steps[index],
                  isLast: index == tracking.steps.length - 1,
                ),
              const SizedBox(height: 16),
              Card(
                color: Colors.blue.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('배송 문의: 1588-1255'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _TrackingTile extends StatelessWidget {
  const _TrackingTile({required this.step, required this.isLast});

  final OrderTrackingStep step;
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
              child: Icon(
                step.completed ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20,
              ),
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
                  _trackingLabel(step.title),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: step.completed ? null : Colors.grey.shade500,
                      ),
                ),
                Text(step.completed ? '완료' : '대기 중'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _trackingLabel(String title) {
  switch (title) {
    case '주문 접수':
      return '주문 접수';
    case '상품 준비중':
      return '상품 준비중';
    case '배송중':
      return '배송중';
    case '배송 완료':
      return '배송 완료';
    default:
      return title;
  }
}

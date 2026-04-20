import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/product.dart';

class CheckoutDraft {
  const CheckoutDraft({
    required this.receiverName,
    required this.phone,
    required this.address,
    this.message,
  });

  final String receiverName;
  final String phone;
  final String address;
  final String? message;
}

class CheckoutSheet extends StatefulWidget {
  const CheckoutSheet({
    required this.products,
    required this.onComplete,
    super.key,
  });

  final List<Product> products;
  final Future<String> Function(CheckoutDraft draft) onComplete;

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _messageController = TextEditingController();
  int _step = 0;
  String _paymentMethod = '카드 결제';
  bool _isSubmitting = false;

  int get _total =>
      widget.products.fold(0, (sum, product) => sum + product.price);
  int get _shippingFee => widget.products.isEmpty ? 0 : 3000;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    );

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
            _step == 0
                ? '배송 정보'
                : _step == 1
                ? '결제 수단'
                : '주문 완료',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          if (_step == 0)
            _ShippingStep(
              nameController: _nameController,
              phoneController: _phoneController,
              addressController: _addressController,
              messageController: _messageController,
              onChanged: () => setState(() {}),
            ),
          if (_step == 1) ...[
            for (final method in const ['카드 결제', '계좌 이체', '간편 결제'])
              Card(
                child: ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: Text(method),
                  trailing: _paymentMethod == method
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const Icon(Icons.circle_outlined),
                  onTap: () => setState(() => _paymentMethod = method),
                ),
              ),
            const SizedBox(height: 12),
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _SummaryRow('상품 금액', currency.format(_total)),
                    _SummaryRow('배송비', currency.format(_shippingFee)),
                    const Divider(),
                    _SummaryRow(
                      '총 결제 금액',
                      currency.format(_total + _shippingFee),
                      isStrong: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_step == 2) ...[
            const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 72,
            ),
            const SizedBox(height: 12),
            const Text(
              '주문이 완료되었습니다. 배송 조회에서 상태를 확인할 수 있습니다.',
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          if (_step < 2)
            FilledButton(
              onPressed: _isSubmitting || !_canContinue ? null : _next,
              child: Text(
                _isSubmitting
                    ? '처리 중...'
                    : _step == 0
                    ? '다음'
                    : '결제하기',
              ),
            ),
        ],
      ),
    );
  }

  bool get _canContinue {
    if (_step == 0) {
      return _nameController.text.trim().isNotEmpty &&
          _phoneController.text.trim().isNotEmpty &&
          _addressController.text.trim().isNotEmpty;
    }

    return widget.products.isNotEmpty;
  }

  Future<void> _next() async {
    if (_step == 0) {
      setState(() => _step = 1);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final orderId = await widget.onComplete(
        CheckoutDraft(
          receiverName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          message: _messageController.text.trim().isEmpty
              ? null
              : _messageController.text.trim(),
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() => _step = 2);
      Navigator.of(context).pop(orderId);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _ShippingStep extends StatelessWidget {
  const _ShippingStep({
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.messageController,
    required this.onChanged,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController messageController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: '받는 사람'),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: phoneController,
          decoration: const InputDecoration(labelText: '연락처'),
          keyboardType: TextInputType.phone,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: addressController,
          decoration: const InputDecoration(labelText: '배송 주소'),
          minLines: 2,
          maxLines: 4,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: messageController,
          decoration: const InputDecoration(labelText: '배송 요청사항'),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {this.isStrong = false});

  final String label;
  final String value;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontWeight: isStrong ? FontWeight.w800 : FontWeight.w500,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(value, style: style),
        ],
      ),
    );
  }
}

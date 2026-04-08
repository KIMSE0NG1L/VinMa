import 'package:flutter/material.dart';

import '../../domain/product.dart';

class UploadProductSheet extends StatefulWidget {
  const UploadProductSheet({
    required this.categories,
    required this.nextId,
    required this.onUpload,
    super.key,
  });

  final List<String> categories;
  final int nextId;
  final ValueChanged<Product> onUpload;

  @override
  State<UploadProductSheet> createState() => _UploadProductSheetState();
}

class _UploadProductSheetState extends State<UploadProductSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _brandController = TextEditingController();
  final _sizeController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = '';
  String _condition = '중';

  @override
  void initState() {
    super.initState();
    _category = widget.categories.firstWhere(
      (category) => category != widget.categories.first,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    _sizeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: _formKey,
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
              '상품 등록',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.image_outlined, size: 48),
                      SizedBox(height: 8),
                      Text('이미지 선택 영역'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '상품명'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: '가격'),
              keyboardType: TextInputType.number,
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brandController,
              decoration: const InputDecoration(labelText: '브랜드'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sizeController,
              decoration: const InputDecoration(labelText: '사이즈'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: '카테고리'),
              items: [
                for (final category in widget.categories)
                  if (category != widget.categories.first)
                    DropdownMenuItem(value: category, child: Text(category)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _condition,
              decoration: const InputDecoration(labelText: '상태'),
              items: const [
                DropdownMenuItem(value: '상', child: Text('상')),
                DropdownMenuItem(value: '중', child: Text('중')),
                DropdownMenuItem(value: '하', child: Text('하')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _condition = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: '상품 설명'),
              minLines: 3,
              maxLines: 5,
              validator: _required,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.upload),
              label: const Text('등록하기'),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '필수 입력 항목입니다';
    }

    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.onUpload(
      Product(
        id: widget.nextId,
        name: _nameController.text.trim(),
        price: int.tryParse(_priceController.text.trim()) ?? 0,
        category: _category,
        condition: _condition,
        imageUrl:
            'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=900',
        brand: _brandController.text.trim(),
        size: _sizeController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
    Navigator.of(context).pop();
  }
}

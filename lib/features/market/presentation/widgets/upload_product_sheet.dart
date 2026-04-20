import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UploadProductDraft {
  const UploadProductDraft({
    required this.name,
    required this.price,
    required this.brand,
    required this.size,
    required this.category,
    required this.condition,
    required this.description,
    required this.hashtags,
    required this.imageUrls,
    this.floorPrice,
  });

  final String name;
  final int price;
  final int? floorPrice;
  final String brand;
  final String size;
  final String category;
  final String condition;
  final String description;
  final List<String> hashtags;
  final List<String> imageUrls;
}

class UploadProductSheet extends StatefulWidget {
  const UploadProductSheet({
    required this.categories,
    required this.onUpload,
    super.key,
  });

  final List<String> categories;
  final Future<void> Function(UploadProductDraft draft) onUpload;

  @override
  State<UploadProductSheet> createState() => _UploadProductSheetState();
}

class _UploadProductSheetState extends State<UploadProductSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _floorPriceController = TextEditingController();
  final _brandController = TextEditingController();
  final _sizeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hashtagsController = TextEditingController();
  final _imagePicker = ImagePicker();
  final List<XFile> _selectedImages = [];

  String _category = '';
  String _condition = _conditionOptions.first.value;
  bool _isSubmitting = false;
  bool _isPickingImages = false;

  static const List<_ConditionOption> _conditionOptions = [
    _ConditionOption(value: 'New', label: '새 상품급'),
    _ConditionOption(value: 'Good', label: '상태 좋음'),
    _ConditionOption(value: 'Used', label: '사용감 있음'),
  ];

  @override
  void initState() {
    super.initState();
    _category = widget.categories.firstWhere(
      (category) => category != widget.categories.first,
      orElse: () => widget.categories.first,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _floorPriceController.dispose();
    _brandController.dispose();
    _sizeController.dispose();
    _descriptionController.dispose();
    _hashtagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Center(
              child: Container(
                width: 46,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD3C4B3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _UploadHeroCard(onPickImages: _pickImages, isPickingImages: _isPickingImages),
            const SizedBox(height: 18),
            _SectionCard(
              title: '사진',
              subtitle: '첫 번째 사진이 대표 사진으로 사용돼요. 정면, 측면, 밑창, 하자 부위를 함께 올리면 좋아요.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: _isPickingImages ? null : _pickImages,
                        icon: _isPickingImages
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.photo_library_outlined),
                        label: Text(
                          _selectedImages.isEmpty ? '사진 선택하기' : '사진 다시 고르기',
                        ),
                      ),
                      if (_selectedImages.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(_selectedImages.clear);
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('전체 비우기'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedImages.isEmpty)
                    const _EmptyImagePickerHint()
                  else
                    _SelectedImagesGrid(
                      images: _selectedImages,
                      onRemove: _removeImageAt,
                      onMoveToPrimary: _moveToPrimary,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: '기본 정보',
              subtitle: '브랜드, 상품명, 사이즈가 명확할수록 검색과 비교가 쉬워져요.',
              child: Column(
                children: [
                  TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(labelText: '브랜드'),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '상품명',
                      hintText: '예: 크로켓앤존스 코도반 로퍼 UK 8',
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _sizeController,
                          decoration: const InputDecoration(
                            labelText: '사이즈',
                            hintText: 'UK 8, 42, M',
                          ),
                          validator: _required,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _condition,
                          decoration: const InputDecoration(labelText: '상태'),
                          items: _conditionOptions
                              .map(
                                (option) => DropdownMenuItem(
                                  value: option.value,
                                  child: Text(option.label),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _condition = value);
                            }
                          },
                        ),
                      ),
                    ],
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: '가격',
              subtitle: '희망가와 최저가를 함께 정하면 스와이프 가격 조정 흐름이 자연스러워져요.',
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: const InputDecoration(
                            labelText: '희망가',
                            prefixText: '₩ ',
                            hintText: '350000',
                          ),
                          keyboardType: TextInputType.number,
                          validator: _requiredNumber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _floorPriceController,
                          decoration: const InputDecoration(
                            labelText: '최저가',
                            prefixText: '₩ ',
                            hintText: '비워두면 자동 계산',
                          ),
                          keyboardType: TextInputType.number,
                          validator: _optionalNumber,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: '설명과 해시태그',
              subtitle: '착용감, 하자, 구성품, 관리 상태를 적어두면 구매 결정을 돕기 좋아요.',
              child: Column(
                children: [
                  TextFormField(
                    controller: _hashtagsController,
                    decoration: const InputDecoration(
                      labelText: '해시태그',
                      hintText: '#크로켓앤존스, #영국수제화, #로퍼',
                      helperText: '쉼표로 구분해서 입력해 주세요.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '상품 설명',
                      hintText: '착용감, 하자 유무, 보관 상태, 수선 여부를 적어 주세요.',
                    ),
                    minLines: 5,
                    maxLines: 7,
                    validator: _required,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F2EC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5D7C8)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '등록 준비가 끝났어요',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '사진, 가격, 설명이 모두 들어가면 바로 판매 목록에 올라가요.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6F665E),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.north_east),
                    label: Text(_isSubmitting ? '등록 중' : '상품 올리기'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    setState(() => _isPickingImages = true);
    try {
      final picked = await _imagePicker.pickMultiImage(
        imageQuality: 88,
        maxWidth: 1800,
      );

      if (!mounted || picked.isEmpty) {
        return;
      }

      setState(() {
        _selectedImages
          ..clear()
          ..addAll(picked.take(10));
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진을 불러오지 못했어요. 다시 시도해 주세요.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImages = false);
      }
    }
  }

  void _removeImageAt(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _moveToPrimary(int index) {
    if (index <= 0 || index >= _selectedImages.length) return;
    setState(() {
      final selected = _selectedImages.removeAt(index);
      _selectedImages.insert(0, selected);
    });
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '필수 입력 항목이에요.';
    }
    return null;
  }

  String? _requiredNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '가격을 입력해 주세요.';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return '0보다 큰 숫자를 입력해 주세요.';
    }
    return null;
  }

  String? _optionalNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return '0보다 큰 숫자를 입력해 주세요.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진을 한 장 이상 선택해 주세요.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await widget.onUpload(
        UploadProductDraft(
          name: _nameController.text.trim(),
          price: int.parse(_priceController.text.trim()),
          floorPrice: _floorPriceController.text.trim().isEmpty
              ? null
              : int.tryParse(_floorPriceController.text.trim()),
          brand: _brandController.text.trim(),
          size: _sizeController.text.trim(),
          category: _category,
          condition: _condition,
          description: _descriptionController.text.trim(),
          hashtags: _hashtagsController.text
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList(),
          imageUrls: _selectedImages
              .map((image) => Uri.file(image.path).toString())
              .toList(),
        ),
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _UploadHeroCard extends StatelessWidget {
  const _UploadHeroCard({
    required this.onPickImages,
    required this.isPickingImages,
  });

  final Future<void> Function() onPickImages;
  final bool isPickingImages;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF122033), Color(0xFF25354E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'SELL WITH VINMAON',
              style: TextStyle(
                color: Color(0xFFE5D1A6),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '좋은 사진과 정확한 정보가\n판매 속도를 바꿔요.',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.18,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            '사진을 먼저 고르고, 가격과 설명을 차분히 정리해 보세요. 빈마온의 판매 흐름에 맞게 바로 정리해 드릴게요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 18),
          FilledButton.tonalIcon(
            onPressed: isPickingImages ? null : onPickImages,
            icon: isPickingImages
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('사진 먼저 선택하기'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8DFD5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6F665E),
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _EmptyImagePickerHint extends StatelessWidget {
  const _EmptyImagePickerHint();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F4EF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5D7C8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF122033),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.photo_library_outlined,
                color: Color(0xFFE5D1A6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '대표 사진은 상품 전체가 잘 보이게, 나머지는 착용감과 디테일이 보이게 올려 주세요.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF5F564E),
                      height: 1.45,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedImagesGrid extends StatelessWidget {
  const _SelectedImagesGrid({
    required this.images,
    required this.onRemove,
    required this.onMoveToPrimary,
  });

  final List<XFile> images;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onMoveToPrimary;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final image = images[index];
        final isPrimary = index == 0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPrimary
                    ? const Color(0xFF122033)
                    : const Color(0xFFE0D5C8),
                width: isPrimary ? 2 : 1,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(image.path), fit: BoxFit.cover),
                Positioned(
                  top: 8,
                  left: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: isPrimary
                          ? const Color(0xFF122033)
                          : Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        isPrimary ? '대표' : '${index + 1}장',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isPrimary)
                        IconButton.filledTonal(
                          visualDensity: VisualDensity.compact,
                          onPressed: () => onMoveToPrimary(index),
                          icon: const Icon(Icons.star_outline, size: 18),
                        ),
                      const SizedBox(width: 4),
                      IconButton.filledTonal(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => onRemove(index),
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConditionOption {
  const _ConditionOption({required this.value, required this.label});

  final String value;
  final String label;
}

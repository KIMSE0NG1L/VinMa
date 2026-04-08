import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/filter_options.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({
    required this.initialOptions,
    required this.brands,
    required this.sizes,
    required this.conditions,
    required this.onApply,
    super.key,
  });

  final FilterOptions initialOptions;
  final List<String> brands;
  final List<String> sizes;
  final List<String> conditions;
  final ValueChanged<FilterOptions> onApply;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late FilterOptions _options = widget.initialOptions;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.compactCurrency(
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
          Row(
            children: [
              const Icon(Icons.tune),
              const SizedBox(width: 8),
              Text(
                '필터',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    setState(() => _options = const FilterOptions()),
                child: const Text('초기화'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SectionTitle('정렬'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _sortChip('최신순', SortOption.latest),
              _sortChip('낮은 가격순', SortOption.priceLow),
              _sortChip('높은 가격순', SortOption.priceHigh),
              _sortChip('인기순', SortOption.popular),
            ],
          ),
          const SizedBox(height: 24),
          _SectionTitle('가격'),
          Slider(
            value: _options.maxPrice,
            min: 0,
            max: 3000000,
            divisions: 60,
            label: currency.format(_options.maxPrice),
            onChanged: (value) {
              setState(() => _options = _options.copyWith(maxPrice: value));
            },
          ),
          Text(
            '${currency.format(_options.maxPrice)} 이하',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          _SectionTitle('브랜드'),
          _FilterChipWrap(
            values: widget.brands,
            selected: _options.brands,
            onToggle: (value) => _toggleSet(_options.brands, value, (next) {
              _options = _options.copyWith(brands: next);
            }),
          ),
          const SizedBox(height: 24),
          _SectionTitle('사이즈'),
          _FilterChipWrap(
            values: widget.sizes,
            selected: _options.sizes,
            onToggle: (value) => _toggleSet(_options.sizes, value, (next) {
              _options = _options.copyWith(sizes: next);
            }),
          ),
          const SizedBox(height: 24),
          _SectionTitle('상태'),
          _FilterChipWrap(
            values: widget.conditions,
            selected: _options.conditions,
            onToggle: (value) => _toggleSet(_options.conditions, value, (next) {
              _options = _options.copyWith(conditions: next);
            }),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: () {
              widget.onApply(_options);
              Navigator.of(context).pop();
            },
            child: const Text('필터 적용'),
          ),
        ],
      ),
    );
  }

  Widget _sortChip(String label, SortOption option) {
    return ChoiceChip(
      label: Text(label),
      selected: _options.sortOption == option,
      onSelected: (_) {
        setState(() => _options = _options.copyWith(sortOption: option));
      },
    );
  }

  void _toggleSet(
    Set<String> current,
    String value,
    ValueChanged<Set<String>> assign,
  ) {
    final next = {...current};
    if (next.contains(value)) {
      next.remove(value);
    } else {
      next.add(value);
    }

    setState(() => assign(next));
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _FilterChipWrap extends StatelessWidget {
  const _FilterChipWrap({
    required this.values,
    required this.selected,
    required this.onToggle,
  });

  final List<String> values;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final value in values)
          FilterChip(
            label: Text(value),
            selected: selected.contains(value),
            onSelected: (_) => onToggle(value),
          ),
      ],
    );
  }
}

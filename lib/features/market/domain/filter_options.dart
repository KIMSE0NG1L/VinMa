enum SortOption { latest, priceLow, priceHigh, popular }

class FilterOptions {
  const FilterOptions({
    this.maxPrice = 3000000,
    this.brands = const {},
    this.sizes = const {},
    this.conditions = const {},
    this.sortOption = SortOption.latest,
  });

  final double maxPrice;
  final Set<String> brands;
  final Set<String> sizes;
  final Set<String> conditions;
  final SortOption sortOption;

  bool get hasActiveFilters {
    return maxPrice < 3000000 ||
        brands.isNotEmpty ||
        sizes.isNotEmpty ||
        conditions.isNotEmpty ||
        sortOption != SortOption.latest;
  }

  FilterOptions copyWith({
    double? maxPrice,
    Set<String>? brands,
    Set<String>? sizes,
    Set<String>? conditions,
    SortOption? sortOption,
  }) {
    return FilterOptions(
      maxPrice: maxPrice ?? this.maxPrice,
      brands: brands ?? this.brands,
      sizes: sizes ?? this.sizes,
      conditions: conditions ?? this.conditions,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

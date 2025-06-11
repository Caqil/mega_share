import 'base_model.dart';

/// Pagination metadata
class PaginationMeta extends BaseModel {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    final currentPage = json['currentPage'] ?? 1;
    final totalPages = json['totalPages'] ?? 1;
    final totalItems = json['totalItems'] ?? 0;
    final itemsPerPage = json['itemsPerPage'] ?? 10;

    return PaginationMeta(
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems,
      itemsPerPage: itemsPerPage,
      hasNextPage: json['hasNextPage'] ?? (currentPage < totalPages),
      hasPreviousPage: json['hasPreviousPage'] ?? (currentPage > 1),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }

  /// Create first page
  factory PaginationMeta.first({int itemsPerPage = 10}) {
    return PaginationMeta(
      currentPage: 1,
      totalPages: 1,
      totalItems: 0,
      itemsPerPage: itemsPerPage,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }

  /// Create empty pagination
  factory PaginationMeta.empty() {
    return const PaginationMeta(
      currentPage: 1,
      totalPages: 0,
      totalItems: 0,
      itemsPerPage: 10,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }

  /// Get next page number
  int? get nextPage => hasNextPage ? currentPage + 1 : null;

  /// Get previous page number
  int? get previousPage => hasPreviousPage ? currentPage - 1 : null;

  /// Get start index for current page
  int get startIndex => (currentPage - 1) * itemsPerPage;

  /// Get end index for current page
  int get endIndex {
    final end = startIndex + itemsPerPage;
    return end > totalItems ? totalItems : end;
  }

  /// Check if pagination is empty
  bool get isEmpty => totalItems == 0;

  /// Check if pagination has only one page
  bool get isSinglePage => totalPages <= 1;

  @override
  List<Object?> get props => [
    currentPage,
    totalPages,
    totalItems,
    itemsPerPage,
    hasNextPage,
    hasPreviousPage,
  ];
}

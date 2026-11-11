class FinancialTip {
  final int id;
  final String title;
  final String description;
  final String category;

  const FinancialTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
  });

  factory FinancialTip.fromJson(Map<String, dynamic> json) {
    return FinancialTip(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
    );
  }
}

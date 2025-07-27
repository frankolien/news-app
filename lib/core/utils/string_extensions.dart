extension StringUtils on String {
  String get capitalized => length > 0 ? '${this[0].toUpperCase()}${substring(1)}' : this;

  bool get isNullOrEmpty => this == null || trim().isEmpty;
}
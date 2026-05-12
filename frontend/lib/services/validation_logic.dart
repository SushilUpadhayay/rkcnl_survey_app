/// Simple data class for validation results.
class ValidationResult {
  final bool isValid;
  final String? message;

  const ValidationResult({required this.isValid, this.message});

  factory ValidationResult.valid() => const ValidationResult(isValid: true);
  factory ValidationResult.invalid(String message) =>
      ValidationResult(isValid: false, message: message);
}

/// Abstract base class for all survey validation rules.
abstract class ValidationRule {
  ValidationResult validate(dynamic value);
}

/// Rule for required fields.
class RequiredRule extends ValidationRule {
  final String message;
  RequiredRule({this.message = 'This field is required'});

  @override
  ValidationResult validate(dynamic value) {
    if (value == null) return ValidationResult.invalid(message);
    if (value is String && value.trim().isEmpty) return ValidationResult.invalid(message);
    if (value is List && value.isEmpty) return ValidationResult.invalid(message);
    if (value is Map && value.isEmpty) return ValidationResult.invalid(message);
    return ValidationResult.valid();
  }
}

/// Rule for selection counts (Min/Max).
class SelectionCountRule extends ValidationRule {
  final int? min;
  final int? max;
  SelectionCountRule({this.min, this.max});

  @override
  ValidationResult validate(dynamic value) {
    if (value is! List) return ValidationResult.valid();
    if (min != null && value.length < min!) {
      return ValidationResult.invalid('Select at least $min options');
    }
    if (max != null && value.length > max!) {
      return ValidationResult.invalid('Select no more than $max options');
    }
    return ValidationResult.valid();
  }
}

/// Rule for ranking completeness.
class RankingCompleteRule extends ValidationRule {
  final int totalCount;
  RankingCompleteRule(this.totalCount);

  @override
  ValidationResult validate(dynamic value) {
    if (value is! List) return ValidationResult.invalid('Invalid ranking data');
    if (value.length < totalCount) {
      return ValidationResult.invalid('Please rank all items');
    }
    return ValidationResult.valid();
  }
}

/// Rule for Matrix completeness.
class MatrixCompleteRule extends ValidationRule {
  final int rowCount;
  MatrixCompleteRule(this.rowCount);

  @override
  ValidationResult validate(dynamic value) {
    if (value is! Map) return ValidationResult.invalid('Invalid matrix data');
    if (value.length < rowCount) {
      return ValidationResult.invalid('Please answer all rows in the matrix');
    }
    return ValidationResult.valid();
  }
}

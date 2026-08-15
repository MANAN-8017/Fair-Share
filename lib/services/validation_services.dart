enum ValidationType { required, name, email, phone, password, confirmPassword }

class ValidationService {
  static String? validate(
      String value, {
        required ValidationType type,
        String? compareValue,
        int? minLength,
        int? maxLength,
      }) {
    value = value.trim();

    switch (type) {
      case ValidationType.required:
        if (value.isEmpty) {
          return "This field is required.";
        }
        break;

      case ValidationType.name:
        if (value.isEmpty) {
          return "Name is required.";
        }

        final pattern = RegExp(r'^[a-zA-Z ]+$');

        if (!pattern.hasMatch(value)) {
          return "Name can only contain letters.";
        }
        break;

      case ValidationType.email:
        if (value.isEmpty) {
          return "Email is required.";
        }

        final pattern = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

        if (!pattern.hasMatch(value)) {
          return "Please enter a valid email address.";
        }
        break;

      case ValidationType.phone:
        if (value.isEmpty) {
          return "Phone number is required.";
        }

        final pattern = RegExp(r'^[0-9]{10}$');

        if (!pattern.hasMatch(value)) {
          return "Phone number must contain exactly 10 digits.";
        }
        break;

      case ValidationType.password:
        if (value.isEmpty) {
          return "Password is required.";
        }

        if (minLength != null && value.length < minLength) {
          return "Password must be at least $minLength characters.";
        }
        break;

      case ValidationType.confirmPassword:
        if (value.isEmpty) {
          return "Please confirm your password.";
        }

        if (value != compareValue) {
          return "Passwords do not match.";
        }
        break;
    }

    if (maxLength != null && value.length > maxLength) {
      return "Maximum $maxLength characters allowed.";
    }

    return null;
  }
}
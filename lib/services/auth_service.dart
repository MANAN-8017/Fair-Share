import 'validation_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;
  bool get isLoggedIn => supabase.auth.currentSession != null;

  AuthService._internal();

  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  Future<String?> login(String identifier, String password) async {
    try {
      final emailPattern = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );

      // EMAIL LOGIN
      if (emailPattern.hasMatch(identifier)) {
        final valid = validateLogin(
          identifier,
          password,
          1,
        );

        if (valid != null) {
          return valid;
        }

        await supabase.auth.signInWithPassword(
          email: identifier,
          password: password,
        );

        return "True";
      }

      // PHONE LOGIN
      final valid = validateLogin(
        identifier,
        password,
        0,
      );

      if (valid != null) {
        return valid;
      }

      final phoneNumber = "+91$identifier";

      final userData = await supabase
          .from('users')
          .select('email')
          .eq('phone_number', phoneNumber)
          .maybeSingle();

      if (userData == null) {
        return "No account found with this phone number.";
      }

      final email = userData['email'] as String;

      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return "True";
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> register(
      String name,
      String email,
      String phoneNumber,
      String password,
      String confirmPassword,
      ) async {
    final valid = validateRegistration(
      name,
      email,
      phoneNumber,
      password,
      confirmPassword,
    );

    if (valid != null) {
      return valid;
    }

    try {
      phoneNumber = "+91$phoneNumber";

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        return "Try Again";
      }

      await supabase.from('users').insert({
        'id': user.id,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
      });

      return "True";
    } catch (error) {
      return error.toString();
    }
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}

String? validateRegistration(String name, String email, String phoneNumber, String password, String confirmPassword) {
  return ValidationService.validate(
    name,
    type: ValidationType.name,
  ) ??
      ValidationService.validate(
        email,
        type: ValidationType.email,
      ) ??
      ValidationService.validate(
        phoneNumber,
        type: ValidationType.phone,
      ) ??
      ValidationService.validate(
        password,
        type: ValidationType.password,
        minLength: 8,
      ) ??
      ValidationService.validate(
        confirmPassword,
        type: ValidationType.confirmPassword,
        compareValue: password,
      );
}

String? validateLogin(String identifier, String password, int x){
  if(x == 1) {
    return
      ValidationService.validate(identifier, type: ValidationType.email)
          ??
          ValidationService.validate(password, type: ValidationType.password);
  }

  return
    ValidationService.validate(identifier, type: ValidationType.phone)
        ??
        ValidationService.validate(password, type: ValidationType.password);
}
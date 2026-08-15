import '../../data/mock_data.dart';

class AuthService {
  AuthService._internal();
  static final AuthService _instance = AuthService._internal();
  factory AuthService() {
    return _instance;
  }

  bool isLoggedIn = false;
  int id = 4;

  bool isValidGmail(String email) {
    final pattern = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    return pattern.hasMatch(email);
  }

  bool isValidName(String name){
    final pattern = RegExp(r'^[a-zA-Z]');
    return pattern.hasMatch(name);
  }

  bool isValidPassword(String password){
    if(password.length < 4){
      return false;
    }
    return true;
  }

  String? login(String email, String password) {
    if (!isValidGmail(email)) {
      return "Please enter a valid Gmail address.";
    }

    for (int i = 0; i < mockUsers.length; i++) {
      if ((mockUsers[i]['email'] as String).toLowerCase() == email.toLowerCase() &&
          (mockUsers[i]['password'] as String) == password) {
        isLoggedIn = true;
        return null;
      }
    }

    return "Invalid email or password.";
  }

  String? register(String username, String name, String email, String password, String confirmPassword) {
    if (!isValidGmail(email)) {
      return "Please enter a valid Gmail address.";
    }

    if (!isValidName(name)) {
      return "Please enter a valid Name.";
    }

    if(!isValidPassword(password)){
      return "Password must be at least 4 characters.";
    }

    if (password != confirmPassword){
      return "Passwords do not match.";
    }

    mockUsers.add({'username': username, 'name': name, 'email': email, 'password': password});
    return null;
  }
  bool logout() {
    isLoggedIn = false;
    return true;
  }
}
import '../../data/mock_data.dart';
class AuthService {
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

  bool login(String email, String password) {
    if(!isValidGmail(email)) {
      return false;
    }

    for(int i=0;i<mockUsers.length;i++){

      if((mockUsers[i]['email'] as String).toLowerCase() == email.toLowerCase() &&
          (mockUsers[i]['password'] as String).toLowerCase() == password.toLowerCase())
      {
        isLoggedIn = true;
        return true;
      }
    }
    return false;
  }

  bool register(String username, String name, String email, String password, String confirmPassword) {
    if (!isValidGmail(email)) {
      return false;
    }

    if (!isValidName(name)) {
      return false;
    }

    if (password != confirmPassword){
      return false;
    }

    mockUsers.add({
      'username': username,
      'name': name,
      'email': email,
      'password': password
    });
    return true;
  }
  bool logout() {
    isLoggedIn = false;
    return true;
  }
}
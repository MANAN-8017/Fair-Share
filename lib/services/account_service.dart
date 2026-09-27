import 'package:supabase_flutter/supabase_flutter.dart';

class AccountService {
  final SupabaseClient supabase = Supabase.instance.client;

  static final AccountService _instance = AccountService._internal();
  AccountService._internal();
  factory AccountService() {
    return _instance;
  }

  Future<Map<String, dynamic>?> getProfile(){
    final user = supabase.auth.currentUser;
    if(user == null) return Future.value(null);
    return supabase.from('users').select('name, email').eq('id', user.id).maybeSingle();
  }

  Future<String?> updateProfile({required String name}){
    final user = supabase.auth.currentUser;
    if(user == null) return Future.value("You must be logged in to update profile.");
    return supabase.from('users').update({'name': name}).eq('id', user.id).then((value) => "True").catchError((error) => error.toString());
  }

  Future<Map<String, bool>?> getNotificationSettings(){return Future.value({});}

  Future<String?> updateNotificationSetting({required String key, required bool value}){return Future.value("True");}

  Future<Map<String, dynamic>?> getPaymentDetails(){return Future.value({});}

  Future<String?> updatePaymentDetails({
    required String upiId,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
  }){return Future.value("True");}

  Future<String?> submitSupportRequest({required String subject, required String message}){return Future.value("True");}

  Future<String> getAppVersion(){return Future.value("1.0.0");}
}
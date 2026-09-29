import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountService {
  final SupabaseClient supabase = Supabase.instance.client;

  static final AccountService _instance = AccountService._internal();
  AccountService._internal();
  factory AccountService() {
    return _instance;
  }

  static final ValueNotifier<String?> currentAvatarUrl = ValueNotifier<String?>(null);
  static final ValueNotifier<int> profileVersion = ValueNotifier<int>(0);

  Future<Map<String, dynamic>?> getProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;
    final data = await supabase
        .from('users')
        .select('name, email, avatar_url')
        .eq('id', user.id)
        .maybeSingle();
    currentAvatarUrl.value = data?['avatar_url'] as String?;
    return data;
  }

  Future<String?> updateProfileName({required String name}) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return "You must be logged in to update profile.";

      await supabase.from('users').update({'name': name}).eq('id', user.id);
      profileVersion.value++;
      return "True";
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> updateEmail({required String newEmail, required String currentPassword}) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        return "You must be logged in";
      }

      if (user.email == null || user.email!.isEmpty) {
        return "User email is unavailable";
      }

      await supabase.auth.signInWithPassword(email: user.email!, password: currentPassword);
      await supabase.auth.updateUser(UserAttributes(email: newEmail));
      return "True";
    } on AuthApiException catch (error) {
      return error.message.toLowerCase();
    } catch (error) {
      return "Something went wrong. Please try again.";
    }
  }

  Future<String?> updatePassword({required String currentPassword, required String newPassword}){
    final user = supabase.auth.currentUser;
    if(user == null) return Future.value("You must be logged in to update password.");
    return supabase.auth.updateUser(UserAttributes(password: newPassword)).then((value) => "True").catchError((error) => error.toString());
  }

  Future<Object?> uploadAvatar(Uint8List bytes) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final path = '${user.id}/avatar.jpg';

      await supabase.storage.from('avatars').uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );

      final publicUrl = supabase.storage.from('avatars').getPublicUrl(path);
      final url = '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';

      await supabase.from('users').update({'avatar_url': url}).eq('id', user.id);
      currentAvatarUrl.value = url;
      return url;
    } catch (error) {
      return null;
    }
  }

  Future<String?> removeAvatar() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return "You must be logged in.";

      await supabase.storage.from('avatars').remove(['${user.id}/avatar.jpg']);
      await supabase.from('users').update({'avatar_url': null}).eq('id', user.id);
      currentAvatarUrl.value = null;
      return "True";
    } catch (error) {
      return error.toString();
    }
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

  Future<String> getAppVersion(){return Future.value("2.1.3");}
}
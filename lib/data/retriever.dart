import 'package:supabase_flutter/supabase_flutter.dart';

class Retriever {
  final SupabaseClient supabase = Supabase.instance.client;

  Retriever._internal();

  static final Retriever _instance = Retriever._internal();

  factory Retriever() {
    return _instance;
  }

  Future<String?> getName() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        return null;
      }

      final data = await supabase
          .from('users')
          .select('name')
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) {
        return null;
      }

      return data['name'] as String?;
    } catch (error) {
      return error.toString();
    }
  }
}
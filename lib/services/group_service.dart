import 'package:supabase_flutter/supabase_flutter.dart';

class GroupService{
  final SupabaseClient supabase = Supabase.instance.client;

  GroupService._internal();
  static final GroupService _instance = GroupService._internal();

  factory GroupService(){
    return _instance;
  }

  Future<String?> createGroup(String groupName, String? description) async{
    try {
      final user = supabase.auth.currentUser;

      if(user == null){
        return "You must be logged in to create Group";
      }

      final groupResponse = await supabase.from("groups").insert({
        'name': groupName,
        'description': description,
        'created_by': user.id
      }).select().single();

      final groupId = groupResponse['id'];

      await supabase.from("group_members").insert({
        'group_id': groupId,
        'user_id' : user.id,
      });

      return "True";
    }
    catch(error){
      return error.toString();
    }
  }

  Future<List<Map<String, dynamic>>> getUserGroups() async {
    try {
      final user = supabase.auth.currentUser;
      if(user == null) return [];

      final response = await supabase
          .from("groups")
          .select("id, name, description, created_by, group_members!inner(user_id)")
          .eq('group_members.user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    }
    catch (error) {
      print("Error fetching groups: $error");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    try {
      final response = await supabase
          .from('group_members')
          .select('user_id, joined_at, users!inner (id, name, email)')
          .eq('group_id', groupId)
          .order('joined_at', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      print("Error fetching members: $error");
      return [];
    }
  }

  Future<String?> addMemberByEmail(String groupId, String email) async {
    try {
      final userRecord = await supabase
          .from('users')
          .select('id')
          .eq('email', email.trim())
          .maybeSingle();

      if (userRecord == null) {
        return "No user found with that email.";
      }

      await supabase.from('group_members').insert({
        'group_id': groupId,
        'user_id': userRecord['id'],
      });

      return "True";
    } catch (error) {
      if (error.toString().contains('duplicate key value') || error.toString().contains('already exists')) {
        return "User is already in this group.";
      }
      return error.toString();
    }
  }

  Future<String?> removeMember(String groupId, String userId) async {
    try {
      await supabase
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', userId);
      return "True";
    } catch (error) {
      return error.toString();
    }
  }

  Future<String?> deleteGroup(String groupId) async {
    try {
      await supabase.from('groups').delete().eq('id', groupId);
      return "True";
    } catch (error) {
      return error.toString();
    }
  }
}
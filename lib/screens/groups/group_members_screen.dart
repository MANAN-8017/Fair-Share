import 'package:flutter/material.dart';
import '../../services/services.dart';
import '../../widgets/widgets.dart';

class GroupMembersScreen extends StatefulWidget {
  final Map<String, dynamic> group;
  final String currentUserId;

  const GroupMembersScreen({
    super.key,
    required this.group,
    required this.currentUserId,
  });

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  final GroupService _groupService = GroupService();
  List<Map<String, dynamic>> members = [];
  bool isLoading = true;
  bool changesMade = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  bool get isCreator => widget.currentUserId == widget.group['created_by'];

  Future<void> _loadMembers() async {
    setState(() => isLoading = true);
    final fetchedMembers = await _groupService.getGroupMembers(widget.group['id']);
    if (!mounted) return;
    setState(() {
      members = fetchedMembers;
      isLoading = false;
    });
  }

  Future<void> _showAddMemberDialog() async {
    final TextEditingController emailController = TextEditingController();
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: const Color(0xFFFAF8F3),
                title: const Text("Add Member", style: TextStyle(color: Color(0xFF17202B))),
                content: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: "Enter user's email",
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2F9E8F))),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Color(0xFF5A6472))),
                  ),
                  ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                      if (emailController.text.trim().isEmpty) return;

                      setDialogState(() => isSubmitting = true);

                      final result = await _groupService.addMemberByEmail(
                        widget.group['id'],
                        emailController.text.trim(),
                      );

                      if (!mounted) return;
                      Navigator.pop(context);

                      if (result == "True") {
                        AppSnackBar.success(context, "Member added!");
                        changesMade = true;
                        _loadMembers();
                      } else {
                        AppSnackBar.error(context, result ?? "Failed to add member");
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F9E8F)),
                    child: isSubmitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Add", style: TextStyle(color: Colors.white)),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  Future<void> _removeMember(String userId, String memberName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFAF8F3),
        title: const Text("Remove Member"),
        content: Text("Are you sure you want to remove $memberName from the group?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6452)),
            child: const Text("Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await _groupService.removeMember(widget.group['id'], userId);
    if (!mounted) return;

    if (result == "True") {
      AppSnackBar.success(context, "$memberName removed.");
      changesMade = true;
      _loadMembers();
    } else {
      AppSnackBar.error(context, result ?? "Failed to remove member");
    }
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope ensures we pass `changesMade` back even if the user uses the physical back button
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, changesMade);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8F3),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFAF8F3),
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF17202B)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, changesMade),
          ),
          title: const Text(
            "Members",
            style: TextStyle(color: Color(0xFF17202B), fontWeight: FontWeight.bold),
          ),
          actions: [
            if (isCreator)
              IconButton(
                icon: const Icon(Icons.person_add, color: Color(0xFF2F9E8F)),
                onPressed: _showAddMemberDialog,
              ),
          ],
        ),
        body: isLoading
            ? const Center(child: LoadingDots(color: Color(0xFFFF6452), size: 8, spacing: 8))
            : ListView.builder(
          padding: const EdgeInsets.all(22),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final memberRecord = members[index];
            final userRecord = memberRecord['users'] as Map<String, dynamic>;
            final memberId = userRecord['id'];
            final isMe = memberId == widget.currentUserId;
            final isMemberCreator = memberId == widget.group['created_by'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE4E0D5)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF2F9E8F).withOpacity(0.2),
                    child: Text(
                      userRecord['name'].toString().substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Color(0xFF1B5C53), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isMe ? "You" : userRecord['name'],
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            ),
                            if (isMemberCreator)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6452).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "Creator",
                                  style: TextStyle(fontSize: 10, color: Color(0xFFFF6452), fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                        Text(
                          userRecord['email'],
                          style: const TextStyle(fontSize: 12, color: Color(0xFF9AA2AC)),
                        ),
                      ],
                    ),
                  ),
                  if (isCreator && !isMe)
                    IconButton(
                      icon: const Icon(Icons.person_remove, color: Color(0xFF9AA2AC)),
                      onPressed: () => _removeMember(memberId, userRecord['name']),
                    )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
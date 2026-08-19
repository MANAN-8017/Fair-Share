import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import '../../services/services.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> handleCreateGroup() async {
    String name = nameController.text.trim();
    String? description = descriptionController.text.trim();

    if(name.isEmpty){
      AppSnackBar.error(context, "Group name is required.");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final GroupService groupService = GroupService();
    String? response = await groupService.createGroup(name, description);

    if(!mounted) return;

    if(response == "True"){
      AppSnackBar.success(context, "Group created successfully.");
      Navigator.pop(context, true);
    }
    else{
      setState(() {
        isLoading = false;
      });
      AppSnackBar.error(context, response.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                //Back
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: Color(0xFF17202B),
                    ),
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    tooltip: "Back",
                  ),
                ),

                const SizedBox(height: 25),

                // Heading
                const Text(
                  "Create a New Group",
                  style: TextStyle(
                    fontSize: 27,
                    height: 1.15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF17202B),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Set up a space to split expenses with friends.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5A6472),
                  ),
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Group name",
                    filled: true,
                    fillColor: const Color(0xFFF1EEE5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFE4E0D5),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: "Group description",
                    filled: true,
                    fillColor: const Color(0xFFF1EEE5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Color(0xFFE4E0D5),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : handleCreateGroup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6452),
                      disabledBackgroundColor: const Color(0xFFFF6452),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const LoadingDots(
                      color: Colors.white,
                      size: 7,
                      spacing: 6,
                    )
                        : const Text(
                      "Create Group",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
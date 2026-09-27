import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import 'home_screen.dart';
import 'groups/group_screen.dart';
import 'activity/activity_screen.dart';
import 'account/account_screen.dart';

class Layout extends StatefulWidget {
  final int initialIndex;
  const Layout({super.key, required this.initialIndex});

  @override
  State<Layout> createState() => _LayoutState();
}

 class _LayoutState extends State<Layout> {
  late int selected = 0;

  @override
  void initState() {
    super.initState();
    selected = widget.initialIndex;
  }

  void selectScreen(int index) {
    setState(() {
      selected = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F3),

      // CONTENT
      body: IndexedStack(
        index: selected,
        children: const [
          HomeScreen(),
          GroupScreen(),
          ActivityScreen(),
          AccountScreen(),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFFAF8F3),
          border: Border(
            top: BorderSide(
              color: Color(0xFFE4E0D5),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            NavItem(
              Icons.home_outlined,
              "Home",
              selected == 0,
                  () => selectScreen(0),
            ),
            NavItem(
              Icons.people_outline,
              "Groups",
              selected == 1,
                  () => selectScreen(1),
            ),
            NavItem(
              Icons.receipt_long,
              "Activity",
              selected == 2,
                  () => selectScreen(2),
            ),
            NavItem(
              Icons.person_outline,
              "Account",
              selected == 3,
                  () => selectScreen(3),
            ),
          ],
        ),
      ),
    );
  }
}
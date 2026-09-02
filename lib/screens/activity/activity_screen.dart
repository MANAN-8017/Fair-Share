import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 24, 22, 10),
            child: Text(
              "Recent Activity",
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w600,
                color: Color(0xFF17202B),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: const [
                  ActivityRow(
                      icon: "🍽️",
                      title: "Dinner at Otto's",
                      subtitle: "Priya paid → Flatmates",
                      amount: "+₹24.50",
                      iconColor: Color(0xFF1B5C53)
                  ),
                  ActivityRow(
                      icon: "🚕",
                      title: "Airport cab",
                      subtitle: "You paid · Goa Trip",
                      amount: "+₹14.00",
                      iconColor: Color(0xFFE3492F)
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
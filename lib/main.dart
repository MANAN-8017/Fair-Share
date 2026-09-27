import 'package:flutter/material.dart';
import 'screens/auth/loading_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(
      url: 'https://ufyqhxgfvxfyqgifednn.supabase.co',
      publishableKey: 'sb_publishable_-Z7aiYb9fabdcweG_dRhrw_6lDPh39Q',
    );
    runApp(const FairShareApp());
  }
  catch(error){
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('Error initializing Supabase: $error'),
        ),
      ),
    ));
  }
}

class FairShareApp extends StatelessWidget {
  const FairShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FairShare',
      home: const LoadingScreen(),
    );
  }
}
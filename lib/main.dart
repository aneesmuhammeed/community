import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/models/user_model.dart';
import 'features/layout/presentation/pages/main_layout_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cqotnvittlldtyekpgam.supabase.co',
    anonKey: 'sb_publishable_8c1pSPTJIbo_bYlGlHmpOA_7LoARw1C',
  );
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make system UI transparent
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    final supabase = Supabase.instance.client;
    final res = await supabase.from('v_resident_details').select().limit(1).maybeSingle();
    if (res != null) {
      currentUser = UserModel.fromJson(res);
    } else {
      currentUser = testUser; // Fallback
    }
  } catch (e) {
    debugPrint('Error fetching user: $e');
    currentUser = testUser; // Fallback
  }

  runApp(const CommunityHubApp());
}

class CommunityHubApp extends StatelessWidget {
  const CommunityHubApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CommunityHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const MainLayoutPage(),
    );
  }
}

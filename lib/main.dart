import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/models/user_model.dart';
import 'features/layout/presentation/pages/main_layout_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
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

  final supabase = Supabase.instance.client;
  Widget initialScreen = const LoginPage();

  if (supabase.auth.currentSession != null) {
    try {
      final res = await supabase
          .from('v_resident_details')
          .select()
          .eq('resident_id', supabase.auth.currentUser!.id)
          .maybeSingle();

      if (res != null) {
        currentUser = UserModel.fromJson(res);
        initialScreen = const MainLayoutPage();
      } else {
        await supabase.auth.signOut();
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      await supabase.auth.signOut();
    }
  }

  runApp(CommunityHubApp(initialScreen: initialScreen));
}

class CommunityHubApp extends StatelessWidget {
  final Widget initialScreen;
  const CommunityHubApp({Key? key, required this.initialScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CommunityHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: initialScreen,
    );
  }
}

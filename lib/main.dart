import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/models/user_model.dart';
import 'features/layout/presentation/pages/main_layout_page.dart';
import 'core/config/env.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/user_provider.dart';

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

  // ─── Resolve user BEFORE building the widget tree ───
  UserModel initialUser = const UserModel(
    residentId: '55555555-5555-5555-5555-555555555555',
    societyId: '11111111-1111-1111-1111-111111111111',
    apartmentId: '33333333-3333-3333-3333-333333333333',
    name: 'Demo Resident',
    societyName: 'Green Valley Heights',
    block: 'Block A',
    apartment: 'A-405',
    phone: '+91 9876543210',
    email: 'demo@community.app',
    role: 'resident',
    residentType: 'Owner',
    gender: 'male',
    ageGroup: '25-35',
    heritage: '',
    avatarIndex: 0,
  );

  final authUser = Supabase.instance.client.auth.currentUser;
  if (authUser != null) {
    try {
      final res = await Supabase.instance.client
          .from('v_resident_details')
          .select()
          .eq('user_id', authUser.id)
          .maybeSingle();
      if (res != null) {
        initialUser = UserModel.fromJson(res);
      }
    } catch (e) {
      debugPrint('Auth fetch error: $e');
    }
  }

  // Create a container and pre-set the user
  final container = ProviderContainer();
  container.read(userProvider.notifier).setUser(initialUser);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const CommunityHubApp(),
    ),
  );
}

class CommunityHubApp extends StatelessWidget {
  const CommunityHubApp({super.key});

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

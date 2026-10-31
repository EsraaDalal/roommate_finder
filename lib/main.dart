import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rommate_finder/core/config/di.dart';
import 'package:rommate_finder/core/config/supabase_config.dart';
import 'package:rommate_finder/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:rommate_finder/features/auth/presentation/bloc/auth_session/auth_session_bloc.dart';
import 'package:rommate_finder/features/favorites/data/models/favorite_model.dart';
import 'package:rommate_finder/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/resources/app_theme.dart';
import 'core/resources/theme_controller.dart';
import 'core/services/push_notification_service.dart';
import 'features/auth/presentation/bloc/auth_session/auth_session_event.dart';
import 'features/auth/presentation/bloc/onboarding/onboarding_bloc.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/favorites/presentation/bloc/favorite_bloc.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';

late Box<FavoriteModel> favoriteBox;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Hive.initFlutter();

  Hive.registerAdapter(FavoriteModelAdapter());

  favoriteBox = await Hive.openBox<FavoriteModel>("STAY_FAVORITE_BOX");

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
      accessToken: () async {
        return FirebaseAuth.instance.currentUser?.getIdToken();
      },
    );
  }
  await setupDependencies();
  await getIt<PushNotificationService>().initialize(navigatorKey: navigatorKey);

  runApp(const RoommateFinderApp());
}

class RoommateFinderApp extends StatelessWidget {
  const RoommateFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (BuildContext context, _) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
            BlocProvider<AuthSessionBloc>(
              create: (_) =>
                  getIt<AuthSessionBloc>()..add(const AuthSessionStarted()),
            ),
            BlocProvider<FavoritesBloc>(create: (_) => getIt<FavoritesBloc>()),
            BlocProvider<NotificationBloc>(
              create: (_) => getIt<NotificationBloc>(),
            ),
             BlocProvider<OnboardingBloc>(
              create: (_) => getIt<OnboardingBloc>(),
            ),
          ],
          child: MaterialApp(
            navigatorKey: navigatorKey,
            title: 'Roommate Finder',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeController.instance.mode,
            home: const SplashPage(),
          ),
        );
      },
    );
  }
}

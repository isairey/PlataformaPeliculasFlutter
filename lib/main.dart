import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adblocker_webview/adblocker_webview.dart';

import 'core/constants/constants.dart';
import 'screens/main_nav_screen.dart';
import 'screens/details_screen.dart';
import 'screens/player_screen.dart';
import 'screens/search_screen.dart';
import 'models/movie.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await AdBlockerWebviewController.instance.initialize(
    FilterConfig(filterTypes: [FilterType.easyList, FilterType.adGuard]),
  );

  runApp(const ProviderScope(child: MovieSyncApp()));
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const MainNavScreen();
      },
    ),
    GoRoute(
      path: '/details',
      builder: (BuildContext context, GoRouterState state) {
        final movie = state.extra as Movie;
        return DetailsScreen(movie: movie);
      },
    ),
    GoRoute(
      path: '/player',
      builder: (BuildContext context, GoRouterState state) {
        final movie = state.extra as Movie;
        return PlayerScreen(movie: movie);
      },
    ),
    GoRoute(
      path: '/search',
      builder: (BuildContext context, GoRouterState state) {
        return const SearchScreen();
      },
    ),
  ],
);

class MovieSyncApp extends StatelessWidget {
  const MovieSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MovieSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}

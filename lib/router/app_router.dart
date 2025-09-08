// ignore_for_file: unused_import

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/auth/ui/splash_screen.dart';

import '../auth/ui/login_screen.dart';
import '../auth/ui/register_screen.dart';
import '../auth/ui/forgot_password_screen.dart';
import '../blocs/heart_rate/heart_rate_bloc.dart';
import '../hydration_tracking/bloc/hydration_bloc.dart';
import '../hydration_tracking/bloc/hydration_event.dart';
import '../hydration_tracking/notification.dart';
import '../hydration_tracking/repository/hydration_repository.dart';
import '../hydration_tracking/screen/hydration_screen.dart';

import '../profile/bloc/profile_bloc.dart';
import '../profile/bloc/profile_event.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/repository/profile_repository.dart';
import '../screens/heart_rate_screen.dart';
import '../screens/home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;

    final path = state.fullPath ?? state.uri.toString();

    final isSplash = path == '/';
    final isAuthPage =
        path == '/login' || path == '/register' || path == '/forgot-password';

    if (isSplash) return null;

    if (!isLoggedIn && !isAuthPage) return '/login';
    if (isLoggedIn && isAuthPage) return '/home';

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        return BlocProvider(
          create: (_) => ProfileBloc(
            profileRepository: ProfileRepository(),
          )..add(LoadProfile()),
          child: const ProfileScreen(),
        );
      },
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/hydration',
      builder: (context, state) {
        //final uid = FirebaseAuth.instance.currentUser!.uid;
        return BlocProvider(
          create: (_) => WaterBloc(
            WaterRepository(FirebaseFirestore.instance, FirebaseAuth.instance),
            NotificationService(),
          )..add(LoadWaterData()),
          child: const WaterScreen(),
        );
      },
    ),
  ],
);

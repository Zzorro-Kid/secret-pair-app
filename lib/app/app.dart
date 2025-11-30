import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secretpairapp/app/routes.dart';
import 'package:secretpairapp/core/di/service_locator.dart';
import 'package:secretpairapp/core/theme/app_theme.dart';
import 'package:secretpairapp/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:secretpairapp/features/pair/presentation/bloc/pair_bloc.dart';
import 'package:secretpairapp/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:secretpairapp/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:secretpairapp/features/panic/presentation/cubit/panic_cubit.dart';

class SecretPairApp extends StatelessWidget {
  const SecretPairApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => sl<AuthBloc>()..add(AuthCheckStatusEvent()),
        ),
        BlocProvider<PairBloc>(
          create: (context) => sl<PairBloc>(),
        ),
        BlocProvider<ChatBloc>(
          create: (context) => sl<ChatBloc>(),
        ),
        BlocProvider<GalleryBloc>(
          create: (context) => sl<GalleryBloc>(),
        ),
        BlocProvider<PanicCubit>(
          create: (context) => sl<PanicCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'SecretPair',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}

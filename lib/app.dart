import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'state/auth_provider.dart';

/// 根组件：主题 + 路由（路由依赖登录态，需随 AuthProvider 一并创建）。
class HappyRiddingApp extends StatefulWidget {
  const HappyRiddingApp({super.key});

  @override
  State<HappyRiddingApp> createState() => _HappyRiddingAppState();
}

class _HappyRiddingAppState extends State<HappyRiddingApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(auth: context.read<AuthProvider>());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}

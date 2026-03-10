import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import 'app/utils/app_theme.dart';

void main() {
  runApp(const CredApp());
}

class CredApp extends StatelessWidget {
  const CredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CRED Bills',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}

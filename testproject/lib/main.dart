import 'package:flutter/material.dart';
import 'login_page.dart';
import 'role_selection_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ValueNotifier<bool> isLoggedIn = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ecommerce App',
      home: ValueListenableBuilder<bool>(
        valueListenable: isLoggedIn,
        builder: (context, loggedIn, _) {
          if (!loggedIn) {
            return LoginPage(
              onLoginSuccess: () {
                isLoggedIn.value = true;
              },
            ); 
          }
          return RoleSelectionPage();
        },
      ),
    );
  }
}
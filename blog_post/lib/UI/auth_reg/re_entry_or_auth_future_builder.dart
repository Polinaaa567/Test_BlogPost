import 'package:blog_post/UI/auth_reg/auth_reg_widget.dart';
import 'package:blog_post/UI/auth_reg/re_entry.dart';
import 'package:blog_post/provider/authentication/authentication_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReEntryOrAuth extends StatelessWidget {
  const ReEntryOrAuth({super.key});

  @override
  Widget build(BuildContext context) {
    AuthenticationModel authenticationModelRead =
    context.read<AuthenticationModel>();

    return FutureBuilder<List<void>>(
      future: Future.wait([
        authenticationModelRead.readUseBiometryFromPref(),
        authenticationModelRead.readPinCodeFromPref(),
        authenticationModelRead.readEmailFromPref(),
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const AuthRegWidget();
        } else {
          if (authenticationModelRead.pinCodePrefs != "" &&
              authenticationModelRead.email != '') {
            return const ReEntry(true);
          } else {
            return const AuthRegWidget();
          }
        }
      },
    );
  }
}
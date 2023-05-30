import 'package:flutter/material.dart';

import '../components/theme_helper.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({Key? key, required this.errorType}) : super(key: key);
  final ErrorType errorType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        color: ThemeHelper.theme.colorScheme.background,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Icon(
                  Icons.highlight_remove_rounded,
                  color: ThemeHelper.theme.colorScheme.error,
                  size: 110,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "ERROR",
                  style: TextStyle(
                    color: ThemeHelper.theme.colorScheme.error,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            Column(
              children: [
                Text(
                  "An error has occurred",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: ThemeHelper.theme.colorScheme.onBackground,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum ErrorType {
  RouteNotFound,
  NoInternet,
  NoData,
  NoPermission,
}

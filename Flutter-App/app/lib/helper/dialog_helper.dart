import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

import '../components/custom_icon_button.dart';
import '../components/custom_outline_button.dart';
import '../components/snackbar/snackbar.dart';
import '../components/theme_helper.dart';

class DialogHelper {
  void displayErrorSnackBar(
      BuildContext context, String errorMessage, ContentType contentType) {
    var title = "";
    if (contentType == ContentType.failure) {
      title = "Fehler!";
    } else if (contentType == ContentType.success) {
      title = "Erfolg!";
    } else if (contentType == ContentType.warning) {
      title = "Warnung!";
    } else if (contentType == ContentType.help) {
      title = "Hilfe!";
    }

    // var width = context.size?.width;

    final snackBar = SnackBar(
        // width: width,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: title,
          message: errorMessage,
          contentType: contentType,
          inMaterialBanner: true,
        ));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Future<bool> showDeleteDialog(
      BuildContext context, String title, String msg) async {
    bool returnValue = false;
    var res = await Dialogs.materialDialog(
        dialogWidth: kIsWeb ? 0.5 : null,
        context: context,
        title: title,
        msg: msg,
        color: ThemeHelper.theme.dialogBackgroundColor,
        actions: [
          CustomIconOutlineButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: 'Abbruch',
            iconData: Icons.cancel_outlined,
            textStyle: const TextStyle(color: Colors.grey),
            iconColor: Colors.grey,
          ),
          CustomIconButton(
            onPressed: () {
              returnValue = true;
              Navigator.of(context).pop();
            },
            text: 'Löschen',
            iconData: Icons.delete,
            color: ThemeHelper.theme.primaryColorDark,
            textStyle: const TextStyle(color: Colors.white),
            iconColor: Colors.white,
          ),
        ]);

    return returnValue;
  }

  void getErrorDialog(BuildContext context, String title, String msg) {
    Dialogs.materialDialog(
        dialogWidth: kIsWeb ? 0.5 : null,
        context: context,
        title: title,
        msg: msg,
        color: ThemeHelper.theme.dialogBackgroundColor,
        actions: [
          IconsButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: "Schließen",
            iconData: Icons.close_fullscreen,
            textStyle: const TextStyle(color: Colors.white),
            iconColor: ThemeHelper.theme.primaryColorDark,
            color: ThemeHelper.theme.primaryColorDark,
          ),
        ]);
  }

  void showErrorAndRedirect(
      BuildContext context, String title, String msg, String route) {
    Dialogs.materialDialog(
        dialogWidth: kIsWeb ? 0.5 : null,
        context: context,
        title: title,
        msg: msg,
        color: ThemeHelper.theme.dialogBackgroundColor,
        actions: [
          IconsButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(route);
            },
            text: "Schließen",
            iconData: Icons.close_fullscreen,
            textStyle: const TextStyle(color: Colors.white),
            iconColor: ThemeHelper.theme.primaryColorDark,
            color: ThemeHelper.theme.primaryColorDark,
          ),
        ]);
  }
}

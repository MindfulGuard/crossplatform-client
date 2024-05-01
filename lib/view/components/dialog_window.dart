import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AlertDialogWindow extends StatefulWidget {
  final String title;
  final String content;
  final String? closeButtonText;

  AlertDialogWindow({
    required this.title,
    required this.content,
    this.closeButtonText,
    Key? key,
  }) : super(key: key);

  @override
  _AlertDialogWindowState createState() => _AlertDialogWindowState();
}

class _AlertDialogWindowState extends State<AlertDialogWindow> {
  @override
  Widget build(BuildContext context) {
    final closeButtonText = widget.closeButtonText ?? AppLocalizations.of(context)!.close;

    return AlertDialog(
      title: Text(
        widget.title,
        style: TextStyle(color: Colors.black),
      ),
      content: SingleChildScrollView(
        child: Text(
          widget.content,
          style: TextStyle(color: Colors.black),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey[350],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ).copyWith(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
            overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.grey.withOpacity(0.1);
              }
              if (states.contains(MaterialState.pressed)) {
                return Colors.grey.withOpacity(0.3);
              }
              return null;
            }),
          ),
          child: Text(closeButtonText),
        ),
      ],
    );
  }
}

class AlertDialogRowWindow extends StatefulWidget {
  final String title;
  final List<Widget> content;
  final String? closeButtonText;

  AlertDialogRowWindow({
    required this.title,
    required this.content,
    this.closeButtonText,
    Key? key,
  }) : super(key: key);

  @override
  _AlertDialogRowWindowState createState() => _AlertDialogRowWindowState();
}

class _AlertDialogRowWindowState extends State<AlertDialogRowWindow> {
  @override
  Widget build(BuildContext context) {
    final closeButtonText = widget.closeButtonText ?? AppLocalizations.of(context)!.close;

    return AlertDialog(
      title: Text(
        widget.title,
        style: TextStyle(color: Colors.black),
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.content,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey[350],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ).copyWith(
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
            overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.grey.withOpacity(0.1);
              }
              if (states.contains(MaterialState.pressed)) {
                return Colors.grey.withOpacity(0.3);
              }
              return null;
            }),
          ),
          child: Text(closeButtonText),
        ),
      ],
    );
  }
}

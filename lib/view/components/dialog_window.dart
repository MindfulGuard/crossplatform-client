import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AlertDialogWindow extends StatefulWidget {
  final String title;
  final String content;
  final String? closeButtonText;
  final String? secondButtonText;
  final VoidCallback? onCloseButtonPressed;
  final VoidCallback? onSecondButtonPressed;

  AlertDialogWindow({
    required this.title,
    required this.content,
    this.closeButtonText,
    this.secondButtonText,
    this.onCloseButtonPressed,
    this.onSecondButtonPressed,
    Key? key,
  }) : super(key: key);

  @override
  _AlertDialogWindowState createState() => _AlertDialogWindowState();
}

class _AlertDialogWindowState extends State<AlertDialogWindow> {
  @override
  Widget build(BuildContext context) {
    final closeButtonText = widget.closeButtonText ?? AppLocalizations.of(context)!.close;
    final secondButtonText = widget.secondButtonText ?? '';

    return AlertDialog(
      title: Text(
        widget.title,
        style: TextStyle(color: Colors.black87), 
      ),
      content: SingleChildScrollView(
        child: Text(
          widget.content,
          style: TextStyle(color: Colors.black87), 
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      actions: [
        if (closeButtonText.isNotEmpty)
          TextButton(
            onPressed: widget.onCloseButtonPressed ?? () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              elevation: 0, // Removed elevation
            ).copyWith(
              overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.hovered)) {
                  return Colors.blue.withOpacity(0.3);
                }
                if (states.contains(MaterialState.pressed)) {
                  return Colors.blue.withOpacity(0.6);
                }
                return null;
              }),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black87),
            ),
            child: Text(closeButtonText),
          ),
        if (secondButtonText.isNotEmpty)
          TextButton(
            onPressed: widget.onSecondButtonPressed ?? () {},
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              elevation: 0,
            ).copyWith(
              overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.hovered)) {
                  return Colors.blue.withOpacity(0.3);
                }
                if (states.contains(MaterialState.pressed)) {
                  return Colors.blue.withOpacity(0.6); 
                }
                return null;
              }),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black87),
            ),
            child: Text(secondButtonText),
          ),
      ],
    );
  }
}

class AlertDialogRowWindow extends StatefulWidget {
  final String title;
  final List<Widget> content;
  final String? closeButtonText;
  final String? secondButtonText;
  final VoidCallback? onCloseButtonPressed;
  final VoidCallback? onSecondButtonPressed;

  AlertDialogRowWindow({
    required this.title,
    required this.content,
    this.closeButtonText,
    this.secondButtonText,
    this.onCloseButtonPressed,
    this.onSecondButtonPressed,
    Key? key,
  }) : super(key: key);

  @override
  _AlertDialogRowWindowState createState() => _AlertDialogRowWindowState();
}

class _AlertDialogRowWindowState extends State<AlertDialogRowWindow> {
  @override
  Widget build(BuildContext context) {
    final closeButtonText = widget.closeButtonText ?? AppLocalizations.of(context)!.close;
    final secondButtonText = widget.secondButtonText ?? '';

    return AlertDialog(
      title: Text(
        widget.title,
        style: TextStyle(color: Colors.black87), 
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
        if (closeButtonText.isNotEmpty)
          TextButton(
            onPressed: widget.onCloseButtonPressed ?? () {
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              elevation: 0, // Removed elevation
            ).copyWith(
              overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.hovered)) {
                  return Colors.blue.withOpacity(0.3); 
                }
                if (states.contains(MaterialState.pressed)) {
                  return Colors.blue.withOpacity(0.6); 
                }
                return null;
              }),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black87),
            ),
            child: Text(closeButtonText),
          ),
        if (secondButtonText.isNotEmpty)
          TextButton(
            onPressed: widget.onSecondButtonPressed ?? () {},
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              elevation: 0, // Removed elevation
            ).copyWith(
              overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.hovered)) {
                  return Colors.blue.withOpacity(0.3);
                }
                if (states.contains(MaterialState.pressed)) {
                  return Colors.blue.withOpacity(0.6); 
                }
                return null;
              }),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black87),
            ),
            child: Text(secondButtonText),
          ),
      ],
    );
  }
}

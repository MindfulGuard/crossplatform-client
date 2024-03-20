import 'package:flutter/material.dart';

class AlignTextField extends StatefulWidget {
  final String labelText;
  final InputBorder inputBorder;
  final Alignment alignment;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Color cursorColor;
  final Color textColor;
  final int? maxLength;

  AlignTextField({
    this.labelText = "",
    this.inputBorder = const UnderlineInputBorder(),
    this.alignment = Alignment.topLeft,
    this.controller,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.cursorColor = Colors.black,
    this.textColor = Colors.black,
    Key? key,
  }) : super(key: key);

  @override
  _AlignTextFieldState createState() => _AlignTextFieldState(obscureText);
}

class _AlignTextFieldState extends State<AlignTextField> {
  late bool obscureText;

  _AlignTextFieldState(this.obscureText);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: TextFormField(
        maxLength: widget.maxLength,
        controller: widget.controller,
        decoration: InputDecoration(
          border: widget.inputBorder,
          labelText: widget.labelText,
          suffixIcon: widget.keyboardType == TextInputType.visiblePassword ? IconButton(
            icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                obscureText = !obscureText; 
              });
            },
          ) : null,
        ),
        obscureText: obscureText, 
        keyboardType: widget.keyboardType, 
        cursorColor: widget.cursorColor,
        style: TextStyle(color: widget.textColor),
      ),
    );
  }
}
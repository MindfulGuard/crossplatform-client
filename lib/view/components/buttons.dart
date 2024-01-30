import 'package:flutter/material.dart';

class DropDown extends StatefulWidget {
  final List<String> options;
  final Function(String?) onOptionChanged;

  DropDown({required this.options, required this.onOptionChanged});

  @override
  _DropDownState createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  String? _selectedOption;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedOption,
      items: widget.options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedOption = newValue;
          widget.onOptionChanged(_selectedOption);
        });
      },
    );
  }
}
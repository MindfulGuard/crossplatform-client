import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vibration/vibration.dart';

class InsertPasscodePage extends StatefulWidget {
  String passcode;
  AppBar? appBar;
  VoidCallback passcodeSuccess;
  VoidCallback? passcodeNotSuccess;

  InsertPasscodePage({
    this.appBar,
    required this.passcodeSuccess,
    this.passcodeNotSuccess,
    required this.passcode,
    Key? key,
  }) : super(key: key);

  @override
  _InsertPasscodePageState createState() =>
      _InsertPasscodePageState();
}

class _InsertPasscodePageState extends State<InsertPasscodePage> {
  final TextEditingController _passcodeController = TextEditingController();
  bool isDesktop = false;
  bool _success = false;
  
  @override
  void initState(){
    super.initState();

    widget.passcodeNotSuccess = (){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.invalidPasscode),
        ),
      );
    };

    _isDesktop();
  }

  @override
  void dispose() {
    super.dispose();
    _passcodeController.dispose();
  }

  void _isDesktop(){
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS){
      setState(() {
        isDesktop = true;
      });
    } else {
      setState(() {
        isDesktop = false;
      });
    }
    print(isDesktop);
  }

  Future<void> _vibrate() async{
    if (Platform.isAndroid){
      if (await Vibration.hasVibrator() == true) {
        if (await Vibration.hasCustomVibrationsSupport() == true) {
            Vibration.vibrate(
              duration: 40,
              intensities: [1],
            );
        } else {
          return;
        }
      }
    } else{
      return;
    }
  }

  void _verifyPasscode(){
    String passcode = Crypto.hash().sha(_passcodeController.text).toString();
    if (passcode == widget.passcode) {
      setState(() {
        _success = true;
      });
      Future.delayed(Duration(milliseconds: 256), (){
        _vibrate();
      });

      Future.delayed(Duration(seconds: 1), (){
        widget.passcodeSuccess();
      });
    } else {
      widget.passcodeNotSuccess!();
    }
  }

  Widget _buildVirtualKeyboard() {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeyboardButton('1'),
              _buildKeyboardButton('2'),
              _buildKeyboardButton('3'),
            ],
          ),
          SizedBox(height: 7,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeyboardButton('4'),
              _buildKeyboardButton('5'),
              _buildKeyboardButton('6'),
            ],
          ),
          SizedBox(height: 7,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeyboardButton('7'),
              _buildKeyboardButton('8'),
              _buildKeyboardButton('9'),
            ],
          ),
          SizedBox(height: 7,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEmptyButton(),
              _buildKeyboardButton('0'),
              _buildBackspaceButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardButton(String value) {
    return Expanded(
      child: TextButton(
        style: ButtonStyle(
          overlayColor:  MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.grey.withOpacity(0.5);
              } else if(states.contains(MaterialState.pressed)){
                return Colors.grey.withOpacity(0.8);
              }
              return Colors.transparent;
            },
          ),
        ),
        onPressed: () => _handleKeyboardInput(value),
        child: Text(
          value,
          style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildEmptyButton() {
    return Expanded(child: Container());
  }

  Widget _buildBackspaceButton() {
    return Expanded(
      child: TextButton(
        style: ButtonStyle(
          overlayColor:  MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.grey.withOpacity(0.5);
              } else if(states.contains(MaterialState.pressed)){
                return Colors.grey.withOpacity(0.8);
              }
              return Colors.transparent;
            },
          ),
        ),
        onPressed: () => _handleBackspace(),
        child: Icon(Icons.backspace, color: Colors.red),
      ),
    );
  }

  void _handleKeyboardInput(String value) {
    setState(() {
      _passcodeController.text += value;
    });
  }

  void _handleBackspace() {
    if (_passcodeController.text.isNotEmpty) {
      setState(() {
        _passcodeController.text = _passcodeController.text.substring(0, _passcodeController.text.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              _success
              ? Icon(
                size: 56,
                Icons.lock_outline
              ).animate().crossfade(
                delay: 256.ms,
                builder: ((context) => Icon(
                  size: 56,
                  Icons.lock_open_outlined
                ))
              ).scale(delay: 744.ms, begin: Offset(1, 1), end: Offset(0, 0))
              : Icon(
                size: 56,
                Icons.lock_outline
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.24),
              Container(
                constraints: BoxConstraints(
                  maxWidth: 400.0,
                ),
                child: TextField(
                  style: TextStyle(
                    fontSize: 21,
                  ),
                  keyboardType: isDesktop ? TextInputType.text : TextInputType.number,
                  controller: _passcodeController,
                  inputFormatters: isDesktop ? null : [FilteringTextInputFormatter.digitsOnly],
                  readOnly: isDesktop ? false : true,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.enterPasscode,
                    suffixIcon: isDesktop ?
                    null
                    : 
                    IconButton(
                      onPressed: _verifyPasscode,
                      icon: Icon(Icons.arrow_forward),
                    ),
                  ),
                ),
              ),
              isDesktop
              ? Container()
                :
                Expanded(
                  child: ListView(
                    reverse: true,
                    children: [
                      _buildVirtualKeyboard(),
                    ],
                  ),
                ),
              SizedBox(height: isDesktop ? 70 : 20),
              isDesktop
              ? ElevatedButton(
                  onPressed: _verifyPasscode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.black,
                    minimumSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.submitPasscode,
                    style: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                )
              : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
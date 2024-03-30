import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added to use Clipboard
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:url_launcher/url_launcher.dart'; // Added to open links
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:otp/otp.dart';

class ItemsInfoPage extends StatefulWidget {
  final String apiUrl;
  final String token;
  final String password;
  final String privateKey;
  final Uint8List privateKeyBytes;
  Map<String, dynamic> selectedSafeItems;
  String selectedSafeId;

  ItemsInfoPage({
    required this.apiUrl,
    required this.token,
    required this.password,
    required this.privateKey,
    required this.privateKeyBytes,
    required this.selectedSafeId,
    required this.selectedSafeItems,
    Key? key,
  }) : super(key: key);

  @override
  _ItemsInfoPageState createState() => _ItemsInfoPageState();
}

class _ItemsInfoPageState extends State<ItemsInfoPage> {
  late List<bool> _isPasswordVisibleList;
  bool _isDecrypted = false;

  @override
  void initState() {
    super.initState();
    _isPasswordVisibleList = List.filled(widget.selectedSafeItems['sections'].length, false);
    Future.delayed(Duration(milliseconds: 200), (){
      _decryptData();
    });
  }

  Future<void> _decryptData() async{
    var decryptedData = await Crypto.crypto().decryptMapValues(
      widget.selectedSafeItems,
      ['value', 'notes'],
      widget.password,
      widget.privateKeyBytes,
    );

    setState(() {
      widget.selectedSafeItems = decryptedData;
      _isDecrypted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: 
        _isDecrypted
        ? SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                widget.selectedSafeItems['title'],
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Center(
              child: Text(
                widget.selectedSafeItems['category'],
                style: TextStyle(
                  fontSize: 24.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Center(
              child:  widget.selectedSafeItems['notes'] != null && widget.selectedSafeItems['notes'].isNotEmpty
                  ? Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        widget.selectedSafeItems['notes'] ?? "",
                        style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : Container(),
            ),
            SizedBox(height: 11.0),
            // Display tags in separate mini-containers
          if (widget.selectedSafeItems['tags'] != null &&
              widget.selectedSafeItems['tags'].isNotEmpty)
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: widget.selectedSafeItems['tags']
                  .map<Widget>((tag) => _buildTagCard(tag))
                  .toList(), // Conversion to List<Widget>
            ),
            SizedBox(height: 11.0),
            for (var index = 0; index < widget.selectedSafeItems['sections'].length; index++)
              _buildSectionCard(widget.selectedSafeItems['sections'][index], index),
          ],
        ),
      )
      : Center(
        child: CircularProgressIndicator(),
      )
    );
  }

  Widget _buildTagCard(String tag) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      ),
    );
  }

  String _generateTotpString(String secretCode) {
    // Checks if the string is a BASE32 so that an exception will not occur when generating TOTP code.
    if (RegExp(r'^[A-Z2-7]+=*$').hasMatch(secretCode)) {
      print("Ok");
      return OTP.generateTOTPCodeString(
        secretCode, 
        DateTime.now().millisecondsSinceEpoch,
        interval: 30,
        length: 6,
        algorithm: Algorithm.SHA1,
        isGoogle: true
      );
    } else {
      return secretCode;
    }
  }

  Widget _buildSectionCard(Map<String, dynamic> section, int index) {
    return section['fields'].length == 0 ? Container() : Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          section['section'] == 'INIT' ? Container() : Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10.0),
              ),
            ),
            child: Text(
              section['section'],
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (section['fields'] as List).map((field) {
                int fieldIndex = section['fields'].indexOf(field);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.fieldLabelWithValue(field['label']),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      if (field['type'] != 'PASSWORD' && field['type'] != 'URL' && field['type'] != 'OTP')
                        Text(
                          AppLocalizations.of(context)!.fieldValueWithValue(field['value'] ?? ""),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey[800],
                          ),
                        ),
                      if (field['type'] == 'PASSWORD')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.fieldValueWithValue(_isPasswordVisibleList[index] ? field['value'] ?? "" : '********'),
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8.0),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isPasswordVisibleList[index] = !_isPasswordVisibleList[index];
                                });
                              },
                              child: Icon(
                                _isPasswordVisibleList[index] ? Icons.visibility : Icons.visibility_off,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        if (field['type'] == 'URL')
                          InkWell(
                            onTap: () {
                              _launchURL(field['value'] ?? "");
                            },
                            child: Text(
                              AppLocalizations.of(context)!.fieldValueTypeLinkWithValue(field['value'] ?? ""),
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        if (field['type'] == 'OTP')
                          Text(
                            AppLocalizations.of(context)!.fieldValueWithValue(
                              _generateTotpString(field['value'] ?? "")
                            ),
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey[800],
                            ),
                          ),
                        SizedBox(height: 4.0),
                        Text(
                          AppLocalizations.of(context)!.fieldTypeWithValue(field['type']),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 8.0),
                        ElevatedButton.icon(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: (){
                              if (field['type'] == 'OTP'){
                                return _generateTotpString(field['value'] ?? "");
                              }
                              return field['value'] ?? "";
                            }()));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.valueCopiedToClipboard),
                              ),
                            );
                          },
                          icon: Icon(Icons.copy),
                          label: Text(AppLocalizations.of(context)!.copy),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }

  Future<void> _launchURL(String url) async {
    try {
      await launch(url);
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}
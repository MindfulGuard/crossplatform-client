import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindfulguard/restart_widget.dart';
import 'package:mindfulguard/view/components/dialog_window.dart';
import 'package:mindfulguard/view/components/text.dart';

class FontFamilySettingsPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  const FontFamilySettingsPage({
    required this.apiUrl,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  _FontFamilySettingsPageState createState() => _FontFamilySettingsPageState();
}

class _FontFamilySettingsPageState extends State<FontFamilySettingsPage> {
  late String _defaultName;
  final _fontFamily = TextFontFamily();
  String _selectedFontFamily = "";
  late int _currentPage;
  List<String> _fontsInfo = [];

  @override
  void initState() {
    super.initState();
    _currentPage = 1;
    _getSelectedFontFamily();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _defaultName = AppLocalizations.of(context)!.defaulT;
    _fontsInfo = _fontFamily.getAllAvailableFonts();
    if (!_fontsInfo.contains(_defaultName)) {
      _fontsInfo.insert(0, _defaultName);
    }
    setState(() {});
  }

  void _getSelectedFontFamily() async {
    String? result = await _fontFamily.getAppFontFamily();
    setState(() {
      if (result == null) {
        _selectedFontFamily = _fontFamily.fontFamilyDefault;
      } else {
        _selectedFontFamily = result;
      }
      _fontsInfo.remove(_selectedFontFamily);
      if (_selectedFontFamily != _fontFamily.fontFamilyDefault) {
        _fontsInfo.insert(0, _selectedFontFamily);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int itemsPerPage = 15;
    final int totalPages = (_fontsInfo.length / itemsPerPage).ceil();
    final List<String> currentPageItems = _fontsInfo.skip((_currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.fontFamily),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialogWindow(
                    title: AppLocalizations.of(context)!.helpReference,
                    content: [
                      Text(AppLocalizations.of(context)!.selectedFontWillBeUsedAsPrimaryLanguageInApplication),
                      SizedBox(height: 10),
                      Text(AppLocalizations.of(context)!.fontFamilyInfoWithValueTwo(_fontFamily.fontFamilyDefault))
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.help_outline),
          ),
        ],
      ),
      body: _buildFontList(currentPageItems),
      bottomNavigationBar: _buildPagination(totalPages),
    );
  }

  Widget _buildFontList(List<String> currentPageItems) {
    if (currentPageItems.isNotEmpty) {
      return ListView.builder(
        itemCount: currentPageItems.length,
        itemBuilder: (context, index) {
          final fontFamily = currentPageItems[index];
          return InkWell(
            onTap: () {
              if (_selectedFontFamily != (fontFamily == _defaultName ? _fontFamily.fontFamilyDefault : fontFamily)) {
                _showConfirmationDialog(fontFamily == _defaultName ? _fontFamily.fontFamilyDefault : fontFamily);
              }
            },
            child: ListTile(
              title: Text(
                fontFamily != _fontFamily.fontFamilyDefault ? fontFamily : _defaultName,
                style: GoogleFonts.getFont(fontFamily == _defaultName ? _fontFamily.fontFamilyDefault : fontFamily),
              ),
              trailing: _selectedFontFamily == (fontFamily == _defaultName ? _fontFamily.fontFamilyDefault : fontFamily) ? Icon(Icons.done) : null,
            ),
          );
        },
      );
    } else {
      return Center(
        child: Text(""),
      );
    }
  }

  Widget _buildPagination(int totalPages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _currentPage > 1 ? () {
            setState(() {
              _currentPage--;
            });
          } : null,
        ),
        Text(AppLocalizations.of(context)!.pageValueOfPages(_currentPage, totalPages)),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: _currentPage < totalPages ? () {
            setState(() {
              _currentPage++;
            });
          } : null,
        ),
      ],
    );
  }

  void _showConfirmationDialog(String fontFamily) {
    showDialog(
      context: context,
      builder: (context) => AlertDialogWindow(
        title: AppLocalizations.of(context)!.fontFamilyChangeConfirmation,
        content: AppLocalizations.of(context)!.fontFamilyChangeRequest,
        closeButtonText: AppLocalizations.of(context)!.cancel,
        secondButtonText: AppLocalizations.of(context)!.ok,
        onSecondButtonPressed: (){
          _changeFontFamily(fontFamily);
          RestartWidget.restartApp(context);
        },
      ),
    );
  }

  void _changeFontFamily(String fontFamily) async {
    _fontFamily.setAppFontFamily(fontFamily);
  }
}

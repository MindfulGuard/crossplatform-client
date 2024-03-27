import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/net/api/items/item/update.dart';
import 'package:mindfulguard/view/main/items_and_files/item/item_write_abstract.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemsEditPage extends AbstractItemsWritePage {
  String selectedItemId;
  Map<String, dynamic> selectedItemData;

  ItemsEditPage({
    required String apiUrl,
    required String token,
    required String password,
    required String privateKey,
    required Uint8List privateKeyBytes,
    required String selectedSafeId,
    required this.selectedItemId,
    required this.selectedItemData,
    Key? key,
  }) : super(
          apiUrl: apiUrl,
          token: token,
          password: password,
          privateKey: privateKey,
          privateKeyBytes: privateKeyBytes,
          selectedSafeId: selectedSafeId,
          key: key,
          isCreateItem: false
        );

  @override
  _ItemsEditPageState createState() => _ItemsEditPageState(
    selectedItemData: selectedItemData,
    selectedItemId: selectedItemId
  );
}

class _ItemsEditPageState extends AbstractItemsWritePageState {
  String selectedItemId;
  Map<String, dynamic> selectedItemData;
  bool _isLoading = true;

  _ItemsEditPageState({
    required this.selectedItemId,
    required this.selectedItemData
  });

  Future<void> _decryptData() async{
    var data = await Crypto.crypto().decryptMapValues(
        selectedItemData,
        ['value', 'notes'],
        widget.password,
        widget.privateKeyBytes,
    );
    setState(() {
      selectedItemData = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAndDecryptData();
  }

  Future<void> _fetchAndDecryptData() async {
    await fetchApiData();
    await _decryptData();

    if (selectedItemData != null) {
      setState(() {
        titleController.text = selectedItemData['title'];
        category = selectedItemData['category'];
        notesController.text = selectedItemData['notes'] ?? "";
        tags = List<String>.from(selectedItemData['tags'] ?? []);
        
        var json = selectedItemData;
        if (json['item_categories'] != null) {
          categoriesApi.addAll(json['item_categories'].map<String>((e) => e.toString()));
        }
        if (json['item_types'] != null) {
          typesApi.addAll(json['item_types'].map<String>((e) => e.toString()));
        }

        // Clear and fill sections
        sections.clear();
        var sectionsData = selectedItemData['sections'];
        if (sectionsData != null && sectionsData is List) {
          sections.addAll(sectionsData.map<Map<String, dynamic>>((section) {
            var fields = section['fields'];
            if (fields != null && fields is List) {
              return {
                'section': section['section'],
                'fields': List<Map<String, dynamic>>.from(fields),
              };
            }
            return {'section': section['section'], 'fields': []};
          }));
        }
      });
    }
  }

  @override
  Future<void> saveFormData() async {
    var formData = {
      'title': titleController.text,
      'category': category,
      'notes': notesController.text,
      'tags': tags,
      'sections': sections,
    };

    var _encryptFormData = await encryptFormData(formData);

    await ItemUpdateApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token,
      safeId: widget.selectedSafeId,
      itemId: selectedItemId,
      data: _encryptFormData,
    ).execute();

    Navigator.pop(context, true); // Pass any result you want, e.g., true
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.editItem),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return super.build(context);
    }
  }
}
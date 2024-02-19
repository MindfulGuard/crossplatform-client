import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mindfulguard/net/api/items/item/update.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';
import 'package:mindfulguard/view/main/items_and_files/item/item_write_abstract.dart';

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

  _ItemsEditPageState({
    required this.selectedItemId,
    required this.selectedItemData
  });

  @override
  void initState() {
    super.initState();

    fetchApiData();

    // Check that the data is available
    if (selectedItemData != null) {
      setState(() {
        titleController.text = selectedItemData['title'];
        category = selectedItemData['category'];
        notesController.text = selectedItemData['notes'];
        tags = List<String>.from(selectedItemData['tags'] ?? []);
        
        // Clear and fill categoriesApi and typesApi
        categoriesApi.clear();
        typesApi.clear();
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

    var api = await ItemUpdateApi(
      widget.apiUrl,
      widget.token,
      widget.selectedSafeId,
      selectedItemId,
      _encryptFormData,
    ).execute();

    if (api != null && api.statusCode == 401) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    } else {
      // Use Navigator.pop with a result
      Navigator.pop(context, true); // Pass any result you want, e.g., true
    }

    print(api?.statusCode);
  }
}
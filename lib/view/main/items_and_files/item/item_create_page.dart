import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/items/item/create.dart';
import 'package:mindfulguard/view/main/items_and_files/item/item_write_abstract.dart';

class ItemsCreatePage extends AbstractItemsWritePage {
  ItemsCreatePage({
    required String apiUrl,
    required String token,
    required String password,
    required String privateKey,
    required Uint8List privateKeyBytes,
    required String selectedSafeId,
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
  _ItemsCreatePageState createState() => _ItemsCreatePageState();
}

class _ItemsCreatePageState extends AbstractItemsWritePageState {
  @override
  void initState() {
    super.initState();

    fetchApiData();

    // Add an 'init' section that cannot be deleted or modified
    sections.add({
      'section': 'INIT',
      'fields': [],
    });
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

    var api = await ItemCreateApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token,
      safeId: widget.selectedSafeId,
      body: _encryptFormData,
    );

    await api.execute();

    Navigator.pop(context, true); // Pass any result you want, e.g., true

    AppLogger.logger.d(api.response.statusCode);
  }
}
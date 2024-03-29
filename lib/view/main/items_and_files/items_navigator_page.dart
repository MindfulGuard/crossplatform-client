import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mindfulguard/view/main/items_and_files/files_page.dart';
import 'package:mindfulguard/view/main/items_and_files/items_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemsNavigator extends StatefulWidget {
  final String apiUrl;
  final String token;
  final String password;
  final String privateKey;
  final Uint8List privateKeyBytes;
  String selectedSafeId;
  String selectedSafeName;
  List<dynamic> safesApiResponse;
  Map<String, dynamic> itemsApiResponse;

  ItemsNavigator({
    required this.apiUrl,
    required this.token,
    required this.password,
    required this.privateKey,
    required this.privateKeyBytes,
    required this.selectedSafeId,
    required this.selectedSafeName,
    required this.safesApiResponse,
    required this.itemsApiResponse,
    Key? key,
  }) : super(key: key);

  @override
  _ItemsNavigatorPageState createState() => _ItemsNavigatorPageState();
}

class _ItemsNavigatorPageState extends State<ItemsNavigator> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Replace 2 with the number of sections/pages you have
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.safeWithValue(widget.selectedSafeName)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.items),
            Tab(text: AppLocalizations.of(context)!.files),
            // Add more Tab widgets for additional sections
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Replace with the content/widgets for Section 1
          ItemsPage(
            apiUrl: widget.apiUrl,
            token: widget.token,
            password: widget.password,
            privateKey: widget.privateKey,
            privateKeyBytes: widget.privateKeyBytes,
            safesApiResponse: widget.safesApiResponse,
            selectedSafeId: widget.selectedSafeId,
          ),
          // Replace with the content/widgets for Section 2
          FilesPage(
            apiUrl: widget.apiUrl,
            token: widget.token,
            password: widget.password,
            privateKey: widget.privateKey,
            privateKeyBytes: widget.privateKeyBytes,
            selectedSafeId: widget.selectedSafeId,
          ),
          // Add more containers for additional sections
        ],
      ),
    );
  }
}

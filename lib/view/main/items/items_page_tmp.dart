import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mindfulguard/net/api/items/get.dart';
import 'package:mindfulguard/view/main/items/safe_page.dart';
import 'package:mindfulguard/view/router.dart';

/*
class ItemsPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  ItemsPage({
    required this.apiUrl,
    required this.token,
    Key? key
  }) : super(key: key);

  @override
  _ItemsPageState createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> itemsAPiResponse = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getItems();
  }

  Future<void> _getItems() async {
    var api = await ItemsApi(widget.apiUrl, widget.token).execute();

    if (api?.statusCode != 200 || api?.body == null) {
      return;
    } else {
      setState(() {
        itemsAPiResponse = json.decode(api!.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Set a custom height here
        child: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Safes'),
              Tab(text: 'Files'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SafePage(
            apiUrl: widget.apiUrl,
            token: widget.token,
            itemsAPiResponse: itemsAPiResponse
          ),
          Scaffold(),
        ],
      ),
    );
  }
}

*/
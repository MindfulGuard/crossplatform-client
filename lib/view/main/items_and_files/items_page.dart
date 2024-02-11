import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/net/api/items/get.dart';
import 'package:mindfulguard/net/api/items/item/delete.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';
import 'package:mindfulguard/view/main/items_and_files/item/item_create_page.dart';
import 'package:mindfulguard/view/main/items_and_files/item/item_edit_page.dart';
import 'package:mindfulguard/view/main/items_and_files/item/item_info_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemsPage extends StatefulWidget {
  final String apiUrl;
  final String token;
  final String password;
  final String privateKey;
  final Uint8List privateKeyBytes;
  String selectedSafeId;

  ItemsPage({
    required this.apiUrl,
    required this.token,
    required this.password,
    required this.privateKey,
    required this.privateKeyBytes,
    required this.selectedSafeId,
    Key? key,
  }) : super(key: key);

  @override
  _ItemsPageState createState() => _ItemsPageState();
}


class _ItemsPageState extends State<ItemsPage> {
  late List<dynamic> selectedSafeItems = [];
  Map<String, dynamic> itemsApiResponse = {};
  bool isLoading = true;
  bool isButtonDisabled = true;

  @override
  void didUpdateWidget(ItemsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if selectedSafeId has changed
    if (widget.selectedSafeId != oldWidget.selectedSafeId) {
      _getItems();
    }
  }

  @override
  void initState() {
    super.initState();
    _getItems();
  }

  Future<void> _getItems() async {
    var api = await ItemsApi(widget.apiUrl, widget.token).execute();

    if (api?.statusCode != 200 || api?.body == null) {
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
      return;
    } else {
      var decodedApiResponse = json.decode(utf8.decode(api!.body.runes.toList()));
      var decryptedApiResponse = await Crypto.crypto().decryptMapValues(
        decodedApiResponse,
        widget.password,
        widget.privateKeyBytes,
      );

      setState(() {
        itemsApiResponse = decryptedApiResponse;
        // Filter items based on selectedSafeId and convert to List
        selectedSafeItems = (itemsApiResponse['list'] as List<dynamic>)
            .where((item) => item['safe_id'] == widget.selectedSafeId)
            .toList();
        isLoading = false;
        isButtonDisabled = false; // Enable the button after loading
      });
    }
  }

  Future<void> _handleRefresh() async {
    // Perform the refresh operation here
    await _getItems();
  }

  Future<void> _navigateToItemDetailsPage(Map<String, dynamic> selectedItem) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemsInfoPage(
          apiUrl: widget.apiUrl,
          token: widget.token,
          password: widget.password,
          privateKey: widget.privateKey,
          privateKeyBytes: widget.privateKeyBytes,
          selectedSafeId: widget.selectedSafeId,
          selectedSafeItems: selectedItem,
        ),
      ),
    ).then((result) {
      // Handle the result if needed
      if (result != null && result == true) {
        // Trigger a refresh or update here if needed
        _getItems();
      }
    });
  }

Future<void> _deleteItem(String itemId) async {
  try {
    var api = await ItemDeleteApi(
      widget.apiUrl,
      widget.token,
      widget.selectedSafeId,
      itemId,
    ).execute();

    if (api?.statusCode != 200) {
      print('Delete request failed with status code: ${api?.statusCode}');
      return;
    }
    await _getItems();
    print('Item deleted successfully');
  } catch (error) {
    print('Error during item deletion: $error');
  }
}

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView.builder(
          itemCount: selectedSafeItems.length,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < selectedSafeItems[index]['items'].length; i++)
                  Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(selectedSafeItems[index]['items'][i]['title']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selectedSafeItems[index]['items'][i]['category']),
                          Text(AppLocalizations.of(context)!.tags(selectedSafeItems[index]['items'][i]['tags'].join(', '))),
                          // Add more details as per your requirement
                        ],
                      ),
                      onTap: () {
                        _navigateToItemDetailsPage(selectedSafeItems[index]['items'][i]);
                      },
                      trailing: PopupMenuButton(
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            onTap: () {
                              _navigateToItemsUpdatePage(index, i);
                            },
                            child: Text(AppLocalizations.of(context)!.edit),
                          ),
                          PopupMenuItem(
                            onTap: () {
                              _deleteItem(selectedSafeItems[index]['items'][i]['id']);
                            },
                            child: Text(AppLocalizations.of(context)!.delete),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: isButtonDisabled ? null : _navigateToItemsCreatePage,
            child: Icon(Icons.add),
            backgroundColor: isButtonDisabled ? Colors.grey : Colors.blue,
          ),
        ),
      ],
    );
  }

  Future<void> _navigateToItemsUpdatePage(int indexSafe, int indexItem) async {
    print(indexSafe);
    print(indexItem);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemsEditPage(
          apiUrl: widget.apiUrl,
          token: widget.token,
          password: widget.password,
          privateKey: widget.privateKey,
          privateKeyBytes: widget.privateKeyBytes,
          selectedSafeId: widget.selectedSafeId,
          selectedItemId: selectedSafeItems[indexSafe]['items'][indexItem]['id'],
          selectedItemData: selectedSafeItems[indexSafe]['items'][indexItem],
      )
      ),
    ).then((result) {
      // Handle the result if needed
      if (result != null && result == true) {
        // Trigger a refresh or update here
        _getItems();
      }
    });
  }

  Future<void> _navigateToItemsCreatePage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemsCreatePage(
          apiUrl: widget.apiUrl,
          token: widget.token,
          password: widget.password,
          privateKey: widget.privateKey,
          privateKeyBytes: widget.privateKeyBytes,
          selectedSafeId: widget.selectedSafeId,
        ),
      ),
    ).then((result) {
      // Handle the result if needed
      if (result != null && result == true) {
        // Trigger a refresh or update here
        _getItems();
      }
    });
  }
}
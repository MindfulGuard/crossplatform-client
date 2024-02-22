import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/localization/localization.dart';
import 'package:mindfulguard/net/api/items/get.dart';
import 'package:mindfulguard/net/api/items/item/delete.dart';
import 'package:mindfulguard/net/api/items/item/favorite.dart';
import 'package:mindfulguard/net/api/items/item/move.dart';
import 'package:mindfulguard/view/auth/sign_in_page.dart';
import 'package:mindfulguard/view/components/glass_morphism.dart';
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
  List<dynamic> safesApiResponse;

  ItemsPage({
    required this.apiUrl,
    required this.token,
    required this.password,
    required this.privateKey,
    required this.privateKeyBytes,
    required this.selectedSafeId,
    required this.safesApiResponse,
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
        ['value', 'notes'],
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
                          Text(AppLocalizations.of(context)!.categoryWithValue(selectedSafeItems[index]['items'][i]['category'])),
                          selectedSafeItems[index]['items'][i]['tags'].length > 0
                              ?Text(AppLocalizations.of(context)!.tags(selectedSafeItems[index]['items'][i]['tags'].join(', ')))
                              : Container(),
                          selectedSafeItems[index]['items'][i]['updated_at'] != null // Only server API version 0.5.0 and higher is supported
                              ? Text(AppLocalizations.of(context)!.updatedAt(Localization.formatUnixTimestamp(selectedSafeItems[index]['items'][i]['updated_at'])))
                              : Container(),
                          selectedSafeItems[index]['items'][i]['created_at'] != null // Only server API version 0.5.0 and higher is supported
                              ? Text(AppLocalizations.of(context)!.createdAt(Localization.formatUnixTimestamp(selectedSafeItems[index]['items'][i]['created_at'])))
                              : Container(),
                          // Add more details as per your requirement
                        ],
                      ),
                      onLongPress: (){
                        _showItemActionsDialog(
                          context,
                          index,
                          widget.safesApiResponse,
                          i,
                          selectedSafeItems[index]['items'][i]['id'],
                          selectedSafeItems[index]['items'][i]['favorite']
                        );
                      },
                      onTap: () {
                        _navigateToItemDetailsPage(selectedSafeItems[index]['items'][i]);
                      },
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
            foregroundColor: Colors.black,
            backgroundColor: isButtonDisabled ? Colors.grey : Colors.blue,
          ),
        ),
      ],
    );
  }

  void _addOrRemoveFavorite(String itemId) async{
    try {
      var api = await ItemFavoriteApi(
        widget.apiUrl,
        widget.token,
        widget.selectedSafeId,
        itemId,
      ).execute();

      if (api?.statusCode != 200) {
        print('Favorite request failed with status code: ${api?.statusCode}');
        return;
      }
      await _getItems();
    } catch (error) {
      print('Cannot perform an operation on a favorite: $error');
    }
  }

  void _showItemActionsDialog(
    BuildContext context,
    int indexSafe,
    List<dynamic> safes,
    int indexItem,
    String itemId,
    bool isFavorite,
  ) {
    String favoriteLabel = AppLocalizations.of(context)!.addToFavorites;
    IconData favoriteIcon = Icons.star_border;
    if (isFavorite) {
      favoriteLabel = AppLocalizations.of(context)!.removeFromFavorites;
      favoriteIcon = Icons.star;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GlassMorphismItemActionsWidget(
          functions: [
            GlassMorphismActionRow(
              icon: Icons.edit,
              label: AppLocalizations.of(context)!.edit,
              onTap: () {
                Navigator.pop(context);
                _navigateToItemsUpdatePage(indexSafe, indexItem);
              },
            ),
            GlassMorphismActionRow(
              icon: favoriteIcon,
              label: favoriteLabel,
              onTap: () async {
                Navigator.pop(context);
                _addOrRemoveFavorite(itemId);
              },
            ),
            GlassMorphismActionRow(
              icon: Icons.move_to_inbox,
              label: AppLocalizations.of(context)!.move,
              onTap: () {
                Navigator.pop(context);
                _showSafesList(
                  context,
                  safes,
                  itemId
                );
              },
            ),
            GlassMorphismActionRow(
              icon: Icons.delete,
              label: AppLocalizations.of(context)!.delete,
              onTap: () async {
                Navigator.pop(context);
                await _deleteItem(itemId);
              },
            ),
          ],
        );
      },
    );
  }

  void _showSafesList(
    BuildContext context,
    List<dynamic> safes,
    String itemId
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GlassMorphismItemActionsWidget(
          functions: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var val in safes)
                  GlassMorphismActionRow(
                    icon: val['id'] == widget.selectedSafeId? Icons.done: null,
                    label: val['name'],
                    onTap: () async {
                      _moveItemToNewSafe(
                        val['id'],
                        val['name'],
                        itemId
                      );
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ]
        );
      },
    );
  }

  void _moveItemToNewSafe(
    String newSafeId,
    String newSafeName,
    String itemId
  ) async{
    try {
      var api = await ItemMoveToNewSafeApi(
        widget.apiUrl,
        widget.token,
        widget.selectedSafeId,
        newSafeId,
        itemId
      ).execute();
      if (api?.statusCode != 200 && api != null) {
        Map<String, dynamic> body = json.decode(utf8.decode(api.body.runes.toList()));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body[Localization.getLocale()]?? body[Localization.defaultLanguage]),
          ),
        );
        return;
      }
      await _getItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.itemWasSuccessfullyMovedToSafe(newSafeName)
          ),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorFailedToMoveItemToSafe),
        ),
      );
      print('Error during item move: $error');
    }
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
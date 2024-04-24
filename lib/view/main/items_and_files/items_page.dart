import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mindfulguard/localization/localization.dart';
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/items/get.dart';
import 'package:mindfulguard/net/api/items/item/delete.dart';
import 'package:mindfulguard/net/api/items/item/favorite.dart';
import 'package:mindfulguard/net/api/items/item/move.dart';
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

  void Function()? _cardInfoOnLongPress;
  Function(TapDownDetails)? _cardInfoOnSecondaryTapDown;

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
    var api = ItemsApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token
    );

    await api.execute();
    
    var decodedApiResponse = json.decode(utf8.decode(api.response.body.runes.toList()));

    setState(() {
      itemsApiResponse = decodedApiResponse;
      // Filter items based on selectedSafeId and convert to List
      selectedSafeItems = (itemsApiResponse['list'] as List<dynamic>)
          .where((item) => item['safe_id'] == widget.selectedSafeId)
          .toList();
      isLoading = false;
      isButtonDisabled = false; // Enable the button after loading
    });
    
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
      var api = ItemDeleteApi(
        buildContext: context,
        apiUrl: widget.apiUrl,
        token: widget.token,
        safeId: widget.selectedSafeId,
        itemId: itemId,
      );

      await api.execute();

      await _getItems();
  }

  void _pressOnActionDialog(int index, int i) {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      _cardInfoOnSecondaryTapDown = (details) {
        _showItemActionsDialog(
          context,
          index,
          widget.safesApiResponse,
          i,
          selectedSafeItems[index]['items'][i]['id'],
          selectedSafeItems[index]['items'][i]['favorite'],
        );
      };
    } else {
      _cardInfoOnLongPress = () {
        _showItemActionsDialog(
          context,
          index,
          widget.safesApiResponse,
          i,
          selectedSafeItems[index]['items'][i]['id'],
          selectedSafeItems[index]['items'][i]['favorite'],
        );
      };
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
                    _buildCard(index, i),
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

  Widget _buildCard(int index, int i) {
    _pressOnActionDialog(index, i); // Initialization of event handlers for each list item
    return Card(
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          _navigateToItemDetailsPage(selectedSafeItems[index]['items'][i]);
        },
        onLongPress: _cardInfoOnLongPress,
        onSecondaryTapDown: _cardInfoOnSecondaryTapDown,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: ListTile(
          title: Text(selectedSafeItems[index]['items'][i]['title']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.categoryWithValue(selectedSafeItems[index]['items'][i]['category'])),
              selectedSafeItems[index]['items'][i]['tags'].length > 0
                ? Text(AppLocalizations.of(context)!.tags(selectedSafeItems[index]['items'][i]['tags'].join(', ')))
                : Container(),
              selectedSafeItems[index]['items'][i]['updated_at'] != null // Only server API version 0.5.0 and higher is supported
                ? Text(AppLocalizations.of(context)!.updatedAt(Localization.formatUnixTimestamp(selectedSafeItems[index]['items'][i]['updated_at'])))
                : Container(),
              selectedSafeItems[index]['items'][i]['created_at'] != null // Only server API version 0.5.0 and higher is supported
                ? Text(AppLocalizations.of(context)!.createdAtWithValue(Localization.formatUnixTimestamp(selectedSafeItems[index]['items'][i]['created_at'])))
                : Container(),
            ],
          ),
        ),
      ),
    );
  }

  void _addOrRemoveFavorite(String itemId) async{
      var api = ItemFavoriteApi(
        buildContext: context,
        apiUrl: widget.apiUrl,
        token: widget.token,
        safeId: widget.selectedSafeId,
        itemId: itemId,
      );

      await api.execute();

      await _getItems();
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
                  IgnorePointer(
                    ignoring: val['id'] == widget.selectedSafeId ? true : false,
                    child: GlassMorphismActionRow(
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
                )
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
      await ItemMoveToNewSafeApi(
        buildContext: context,
        apiUrl: widget.apiUrl,
        token: widget.token,
        oldSafeId: widget.selectedSafeId,
        newSafeId: newSafeId,
        itemId: itemId
      ).execute();
  
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
      AppLogger.logger.i('Error during item move: $error');
    }
  }

  Future<void> _navigateToItemsUpdatePage(int indexSafe, int indexItem) async {
    AppLogger.logger.i("Index safe: $indexSafe. Index item: $indexItem");
  
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
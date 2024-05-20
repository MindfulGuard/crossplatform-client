import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/admin/get_settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:collection/collection.dart';
import 'package:mindfulguard/net/api/admin/update_settings.dart';
import 'package:mindfulguard/view/components/dialog_window.dart';

class SettingsSettingsAdminPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  SettingsSettingsAdminPage({
    required this.apiUrl,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  _SettingsSettingsAdminPageState createState() => _SettingsSettingsAdminPageState();
}

class _SettingsSettingsAdminPageState extends State<SettingsSettingsAdminPage> {
  Map<String, dynamic> originalData = {};
  Map<String, dynamic> data = {};
  bool showSaveButton = false;
  String? currentEditingKey;
  dynamic currentEditingValue;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    var api = AdminSettingsGetApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token,
    );

    await api.execute();

    if (api.response.statusCode == 200) {
      var jsonResponse = json.decode(utf8.decode(api.response.body.runes.toList()));
      setState(() {
        data = jsonResponse;
        originalData = Map.from(data);
        showSaveButton = false;
      });
    } else {
    }
  }

  // Check if the data corresponds to the initial state
  bool dataMatchesOriginal() {
    return MapEquality().equals(data, originalData);
  }

  void _updateField(String key, dynamic newValue) {
    setState(() {
      data[key] = newValue;
      showSaveButton = !dataMatchesOriginal();

      // Reset the current editable field if the data matches the original data
      if (dataMatchesOriginal()) {
        currentEditingKey = null;
        currentEditingValue = null;
      } else {
        currentEditingKey = key;
        currentEditingValue = newValue;
      }
    });
  }

  Widget _buildItem(String key, dynamic value) {
    bool isEditable = dataMatchesOriginal() || (currentEditingKey == null || currentEditingKey == key);
    
    if (value is bool) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              key,
              style: TextStyle(fontSize: 16),
            ),
            Switch(
              value: value,
              onChanged: isEditable ? (newValue) => _updateField(key, newValue) : null,
            ),
          ],
        ),
      );
    } else if (value is String) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(key, style: TextStyle(fontSize: 16)),
            TextFormField(
              initialValue: value,
              enabled: isEditable,
              onChanged: (newValue) => _updateField(key, newValue),
            ),
          ],
        ),
      );
    } else if (value is int) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(key, style: TextStyle(fontSize: 16)),
            TextFormField(
              initialValue: value.toString(),
              keyboardType: TextInputType.number,
              enabled: isEditable,
              onChanged: (newValue) {
                int? intValue = int.tryParse(newValue);
                if (intValue != null) {
                  _updateField(key, intValue);
                }
              },
            ),
          ],
        ),
      );
    } else if (value is List) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(key, style: TextStyle(fontSize: 16)),
            IgnorePointer(
              ignoring: !isEditable,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditArrayPage(
                        array: value,
                        keyName: key,
                        onSave: (newArray) {
                          _updateField(key, newArray);
                        },
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_forward),
              ),
            ) 
          ],
        ),
      );
    } else if (value is Map) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(key, style: TextStyle(fontSize: 16)),
            IgnorePointer(
              ignoring: !isEditable,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EditMapPage(
                        map: value,
                        keyName: key,
                        onSave: (newArray) {
                          _updateField(key, newArray);
                        },
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_forward),
              ),
            ) 
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text("Unsupported type"),
      );
    }
  }

  String _convertData(dynamic data){
    String dataString = "";

    if (data is String) {
      dataString = data;
    } else if (data is int || data is double || data is bool) {
      dataString = data.toString();
    } else if (data is List) {
      dataString = json.encode(data);
    } else if (data is Map) {
      dataString = json.encode(data);
    } else if (data is Set) {
      dataString = json.encode(data.toList());
    } else if(data is bool){
      data == true ? dataString = "true" : dataString = "false";
    } else {
      try {
        dataString = data.toString();
      } catch (e) {
        dataString = '';
      }
    }

    return dataString;
  }

  Future<void> _sendData(String key, dynamic data) async{
    String dataString = _convertData(data);

    var api = AdminSettingsUpdateApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token,
      key: key,
      value: dataString
    );

    await api.execute();

    if (api.response.statusCode == 200){
      await _getData();
      showSaveButton = false;
      currentEditingKey = null;
      currentEditingValue = null;
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToUpdateSettings),
        ),
      );

      AppLogger.logger.d(api.response.statusCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.serverSettings),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialogWindow(
                    title: AppLocalizations.of(context)!.helpReference,
                    content: [
                      Text(AppLocalizations.of(context)!.adminSettingsInfo),
                      SizedBox(height: 10),
                      Text(AppLocalizations.of(context)!.adminSettingsWarningInfo),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.help_outline),
          ),
        ],
      ),
      body: ListView(
        children: data.entries.map((entry) => _buildItem(entry.key, entry.value)).toList(),
      ),
      floatingActionButton: showSaveButton
          ? FloatingActionButton(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.black,
              onPressed: () {
                AppLogger.logger.d(widget.token);
                AppLogger.logger.d("Key: $currentEditingKey. Value: $currentEditingValue");
                _sendData(currentEditingKey ?? '', currentEditingValue);
              },
              child: Icon(Icons.save),
            )
          : null,
    );
  }
}

class EditArrayPage extends StatefulWidget {
    final List<dynamic> array;
    final String keyName;
    final ValueChanged<List<dynamic>> onSave;

    EditArrayPage({
        required this.array,
        required this.keyName,
        required this.onSave,
    });

    @override
    _EditArrayPageState createState() => _EditArrayPageState();
}


class _EditArrayPageState extends State<EditArrayPage> {
  late List<dynamic> editedArray;
  late ScrollController _scrollController;
  bool _showAddButton = true;

  @override
  void initState() {
    super.initState();
    editedArray = List.from(widget.array);
    _scrollController = ScrollController();

    // Add a listener for scroll position change
    _scrollController.addListener(() {
      setState(() {
        // If the scroll is not on the top or bottom edge, show the button
        if (_scrollController.position.pixels == 0) {
          // If at the beginning of the list, the button is visible
          _showAddButton = true;
        } else if (_scrollController.position.atEdge) {
          // If on the edge (bottom), the button is hidden
          _showAddButton = _scrollController.position.pixels != _scrollController.position.maxScrollExtent;
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addElement() {
    setState(() {
      editedArray.add("");
    });
  }

  void _updateElement(int index, String value) {
    setState(() {
      editedArray[index] = value;
    });
  }

  void _deleteElement(int index) {
    setState(() {
      editedArray.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${AppLocalizations.of(context)!.edit}: ${widget.keyName}"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              widget.onSave(editedArray);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: editedArray.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: TextFormField(
              initialValue: editedArray[index].toString(),
              onChanged: (value) {
                _updateElement(index, value);
              },
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteElement(index);
              },
            ),
          );
        },
      ),
      floatingActionButton: _showAddButton
          ? FloatingActionButton(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.black,
              onPressed: _addElement,
              child: Icon(Icons.add),
            )
          : null,
    );
  }
}

class EditMapPage extends StatefulWidget {
  final Map<dynamic, dynamic> map;
  final String keyName;
  final ValueChanged<Map<String, dynamic>> onSave;

  EditMapPage({
    required this.map,
    required this.keyName,
    required this.onSave,
  });

  @override
  _EditMapPageState createState() => _EditMapPageState();
}

class _EditMapPageState extends State<EditMapPage> {
  late Map<String, dynamic> editedMap;

  @override
  void initState() {
    super.initState();
    editedMap = Map.from(widget.map);
  }

  void _updateKey(String oldKey, String newKey) {
    setState(() {
      final value = editedMap.remove(oldKey);
      editedMap[newKey] = value;
    });
  }

  void _updateValue(String key, dynamic value) {
    setState(() {
      editedMap[key] = value;
    });
  }

  void _deleteElement(String key) {
    setState(() {
      editedMap.remove(key);
    });
  }

  void _addElement() {
    setState(() {
      editedMap[""] = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${AppLocalizations.of(context)!.edit}: ${widget.keyName}"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              widget.onSave(editedMap);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: editedMap.length,
        itemBuilder: (context, index) {
          final key = editedMap.keys.elementAt(index);
          final value = editedMap[key];

          return ListTile(
            title: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.key
                    ),
                    initialValue: key,
                    onChanged: (newKey) {
                      _updateKey(key, newKey);
                    },
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.value
                    ),
                    initialValue: value.toString(),
                    onChanged: (newValue) {
                      _updateValue(key, newValue);
                    },
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _deleteElement(key);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.black,
        onPressed: _addElement,
        child: Icon(Icons.add),
      ),
    );
  }
}
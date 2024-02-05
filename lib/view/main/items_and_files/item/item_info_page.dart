import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Добавлено для использования Clipboard
import 'package:url_launcher/url_launcher.dart'; // Добавлено для открытия ссылок

class ItemsInfoPage extends StatefulWidget {
  final String apiUrl;
  final String token;
  final String password;
  final String privateKey;
  final Uint8List privateKeyBytes;
  Map<String, dynamic> selectedSafeItems;
  String selectedSafeId;

  ItemsInfoPage({
    required this.apiUrl,
    required this.token,
    required this.password,
    required this.privateKey,
    required this.privateKeyBytes,
    required this.selectedSafeId,
    required this.selectedSafeItems,
    Key? key,
  }) : super(key: key);

  @override
  _ItemsInfoPageState createState() => _ItemsInfoPageState();
}

class _ItemsInfoPageState extends State<ItemsInfoPage> {
  bool _isPasswordVisible = false; // Добавлено состояние для отслеживания видимости пароля

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                widget.selectedSafeItems['title'],
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Center(
              child: Text(
                widget.selectedSafeItems['category'],
                style: TextStyle(
                  fontSize: 24.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Center(
              child: widget.selectedSafeItems['notes'].isNotEmpty
                  ? Container(
                      padding: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue,
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        widget.selectedSafeItems['notes'],
                        style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.black,
                        ),
                      ),
                    )
                  : Container(),
            ),
            SizedBox(height: 11.0),
            // Вывод тэгов в отдельных мини-контейнерах
          if (widget.selectedSafeItems['tags'] != null &&
              widget.selectedSafeItems['tags'].isNotEmpty)
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: widget.selectedSafeItems['tags']
                  .map<Widget>((tag) => _buildTagCard(tag))
                  .toList(), // Преобразование в List<Widget>
            ),
            SizedBox(height: 11.0),
            for (var section in widget.selectedSafeItems['sections'])
              _buildSectionCard(section),
          ],
        ),
      ),
    );
  }

  Widget _buildTagCard(String tag) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionCard(Map<String, dynamic> section) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(10.0),
              ),
            ),
            child: Text(
              section['section'],
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (section['fields'] as List).map((field) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Label: ${field['label']}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      if (field['type'] != 'PASSWORD' && field['type'] != 'URL')
                        Text(
                          'Value: ${field['value']}',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey[800],
                          ),
                        ),
                      if (field['type'] == 'PASSWORD')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Value: ${_isPasswordVisible ? field['value'] : '********'}',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 8.0),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              child: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      if (field['type'] == 'URL')
                        InkWell(
                          onTap: () {
                            _launchURL(field['value']);
                          },
                          child: Text(
                            'Value: ${field['value']} (Click to open)',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      SizedBox(height: 4.0),
                      Text(
                        'Type: ${field['type']}',
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: field['value']));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Value copied to clipboard'),
                            ),
                          );
                        },
                        icon: Icon(Icons.copy),
                        label: Text('Copy'),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    try {
      await launch(url);
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}
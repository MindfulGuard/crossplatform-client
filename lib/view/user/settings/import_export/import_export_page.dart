import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/view/user/settings/import_export/export_page.dart';
import 'package:mindfulguard/view/user/settings/import_export/import_page.dart';

class ImportExportPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  ImportExportPage({
    required this.apiUrl,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  _ImportExportPageState createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> with SingleTickerProviderStateMixin{
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dataImportExport),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.import),
            Tab(text: AppLocalizations.of(context)!.export),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          kDebugMode ? ImportPage(
            apiUrl: widget.apiUrl,
            token: widget.token
          )
          :
          Container(
            child: Center(
              child: Text(AppLocalizations.of(context)!.thisFeatureInDevelopment),
            ),
          ),
          ExportPage(
            apiUrl: widget.apiUrl, 
            token: widget.token
          )
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mindfulguard/crypto/crypto.dart';
import 'package:mindfulguard/localization/localization.dart';
import 'package:mindfulguard/logger/logs.dart';
import 'package:mindfulguard/net/api/admin/create_user.dart';
import 'package:mindfulguard/net/api/admin/delete_user.dart';
import 'package:mindfulguard/net/api/admin/get_users.dart';
import 'package:mindfulguard/net/api/configuration.dart';
import 'package:mindfulguard/view/components/dialog_window.dart';
import 'package:mindfulguard/view/components/qr.dart';
import 'package:mindfulguard/view/components/text_filelds.dart';
import 'package:uuid/uuid.dart';

class UsersSettingsAdminPage extends StatefulWidget {
  final String apiUrl;
  final String token;

  UsersSettingsAdminPage({
    required this.apiUrl,
    required this.token,
    Key? key,
  }) : super(key: key);

  @override
  _UsersSettingsAdminPageState createState() => _UsersSettingsAdminPageState();
}

class _UsersSettingsAdminPageState extends State<UsersSettingsAdminPage> with TickerProviderStateMixin {
  int currentPage = 1;
  Map<String, dynamic> data = {};
  late AnimationController _controller;
  late Animation<double> _animation;
  bool updatingData = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();

    _getData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getData() async {
    var api = AdminUsersGetApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token,
      page: currentPage,
    );

    await api.execute();

    if (api.response.statusCode == 200) {
      var responseJson = json.decode(api.response.body);

      setState(() {
        data = responseJson;
        data['total_pages'] = data['total_pages'] ?? 1;
      });
    }
  }

  void _showUserDetails(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDetailRow(Icons.account_circle, AppLocalizations.of(context)!.username, user['username']),
                Divider(color: Colors.black),
                _buildDetailRow(Icons.language, AppLocalizations.of(context)!.ipAddress, user['ip']),
                Divider(color: Colors.black),
                _buildDetailRow(Icons.access_time, AppLocalizations.of(context)!.dateAndTimeOfCreation, Localization.formatUnixTimestamp(user['created_at'])),
                Divider(color: Colors.black),
                _buildDetailRow(Icons.verified, AppLocalizations.of(context)!.confirmed, user['confirm'] ? AppLocalizations.of(context)!.yes : AppLocalizations.of(context)!.no),
                Divider(color: Colors.black),
                _buildDetailRow(Icons.tag, AppLocalizations.of(context)!.identifier, user['id']),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _deleteUser(user['id']);
                    Navigator.pop(context);
                  },
                  style:ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.black,
                    minimumSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.deleteUser,
                    style: TextStyle(
                      fontSize: 16
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon),
        SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 17)),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildUsersList() {
    if (data['list'] != null && data['list'].length > 0) {
      return ListView.builder(
        itemCount: data['list'].length,
        itemBuilder: (context, index) {
          var user = data['list'][index];
          return ListTile(
            title: Text(user['username']),
            leading: Icon(Icons.account_circle),
            trailing: Text(
              Localization.formatUnixTimestamp(user['created_at'])
            ),
            onTap: () {
              _showUserDetails(user);
            },
          );
        },
      );
    } else {
      return Center(
        child: Text(AppLocalizations.of(context)!.noUsersFound),
      );
    }
  }

  Widget _buildPagination() {
    int totalPages = data['total_pages'] ?? 1;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: currentPage > 1 ? () => _goToPage(currentPage - 1) : null,
        ),
        Text(AppLocalizations.of(context)!.pageValueOfPages(currentPage, totalPages)),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: currentPage < totalPages ? () => _goToPage(currentPage + 1) : null,
        ),
      ],
    );
  }


  void _goToPage(int page) {
    setState(() {
      currentPage = page;
      _getData();
    });
  }

  Future<void> _deleteUser(String userId) async{
    var api = AdminUsersDeleteApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token,
      userId: userId
    );

    await api.execute();

    if (api.response.statusCode == 200){
      await _getData();
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedDeleteAccount),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userManagement),
        actions: [
          IconButton(
            icon: updatingData
                ? Transform.scale(
                    scale: 0.7,
                    child: CircularProgressIndicator(
                      color: Colors.grey[700],
                    ),
                  )
                : Icon(Icons.update),
            onPressed: () async {
              setState(() {
                updatingData = true;
              });
              await _getData();
              setState(() {
                updatingData = false;
              });
            },
          ),
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert),
            onSelected: (int result) {
              switch (result) {
                case 0:
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialogWindow(
                        title: AppLocalizations.of(context)!.information,
                        content: AppLocalizations.of(context)!.usersTotalStorageSizeInfoWithValue(Localization.formatBytes(data['total_storage_size'] ?? 0, context)),
                      );
                    },
                  );
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateUserPage(
                      apiUrl: widget.apiUrl,
                      token: widget.token,
                    )),
                  );
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchUserPage(
                      apiUrl: widget.apiUrl,
                      token: widget.token,
                      deleteUser: _deleteUser,
                    )),
                  );
                  break;
                default:
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              PopupMenuItem<int>(
                value: 0,
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text(AppLocalizations.of(context)!.information),
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.add),
                  title: Text(AppLocalizations.of(context)!.createAUser),
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.search),
                  title: Text(AppLocalizations.of(context)!.userSearch),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialogWindow(
                    title: AppLocalizations.of(context)!.helpReference,
                    content: AppLocalizations.of(context)!.userManagementInfo,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FadeTransition(
              opacity: _animation,
              child: _buildUsersList(),
            ),
          ),
          _buildPagination(),
        ],
      ),
    );
  }
}

class CreateUserPage extends StatefulWidget {
  String apiUrl;
  String token;

  CreateUserPage({
    required this.apiUrl,
    required this.token,
    Key? key
  }) : super(key: key);

  @override
  _CreateUserPageState createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  TextEditingController login = TextEditingController();
  TextEditingController password = TextEditingController();
  String privateKey = "";
  String base32TotpCode = "";
  List<dynamic> backupCodes = [];
  Widget buildInfo = Container();
  bool isRegistered = false;

  @override
  void dispose(){
    super.dispose();
    login.dispose();
    password.dispose();  
  }

  void _buildSignUpInfo(){
    bool isDesktop = false;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS){
      isDesktop = true;
    }

    setState(() {
      buildInfo = Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context)!.privateKey}:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(privateKey),
            SizedBox(height: 8.0),
            Row(
              children: [
                Text(
                  '${AppLocalizations.of(context)!.totpCode}:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                isDesktop 
                ? IconButton(
                  onPressed: (){
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Center(
                          child: QrGenerator(
                            size: 256,
                            data: "otpauth://totp/${login.text}?secret=$base32TotpCode&issuer=MindfulGuard",
                          ),
                        );
                      }
                    );
                  },
                  icon: Icon(Icons.qr_code_rounded)
                )
                : Container()
              ],
            ),
            Text(base32TotpCode),
            SizedBox(height: 8.0),
            Text(
              '${AppLocalizations.of(context)!.backupCodes}:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: backupCodes
                  .map((code) => Text(code.toString()))
                  .toList(),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _createUser() async {
    var configApi = ConfigurationApi(
      apiUrl: widget.apiUrl
    );
    await configApi.execute();

    if (configApi.response.statusCode != 200){
      return;
    }
    Map<String, dynamic> configResponse = json.decode(configApi.response.body);

    RegExp regExp = RegExp(configResponse['password_rule']);
    if (!regExp.hasMatch(password.text)){
      return;
    }

    setState(() {
      privateKey = const Uuid().v4();
    });

    String secretString = Crypto.hash().sha(utf8.encode(login.text+password.text+privateKey)).toString();

    var api = AdminUsersCreateApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token,
      login: login.text,
      secretString: secretString
    );

    await api.execute();

    AppLogger.logger.d(api.response.statusCode);

    if (api.response.statusCode == 200){
      var body = json.decode(api.response.body);
      setState(() {
        base32TotpCode = body['secret_code'];
        backupCodes = body['backup_codes'];
        isRegistered = true;
      });
      _buildSignUpInfo();
    } else if(api.response.statusCode == 503){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.registrationIsDisabled),
          ),
        );
    } else if (api.response.statusCode == 400){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.incorrectData),
          ),
        );
    } else if(api.response.statusCode == 409){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.suchUserAlreadyExists),
          ),
        );
    } else if(api.response.statusCode == 500 || api.response == null){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.failedToRegister),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.createAUser),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AlignTextField(
                    labelText: AppLocalizations.of(context)!.loginUser,
                    controller: login,
                  ),
                  SizedBox(height: 10),
                  AlignTextField(
                    labelText: AppLocalizations.of(context)!.password,
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    controller: password,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    onPressed: () async{
                      isRegistered ? Navigator.pop(context) : _createUser();
                    },
                    child: Text(
                      isRegistered 
                      ? AppLocalizations.of(context)!.next
                      : AppLocalizations.of(context)!.send
                    ),
                  ),
                  SizedBox(height: 20),
                  buildInfo,
                  SizedBox(height: 10),
                  isRegistered
                  ? ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: (){
                        return "Login: ${login.text}\nPassword: ${password.text}\nPrivate Key: $privateKey\n\nTOTP code: $base32TotpCode\n\nBackup Codes: $backupCodes";
                      }()));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.valueCopiedToClipboard),
                        ),
                      );
                    },
                    icon: Icon(Icons.copy),
                    label: Text(AppLocalizations.of(context)!.copy),
                  )
                  : Container()
                ]
            )
          )
        ),
      ),
    );
  }
}

class SearchUserPage extends StatefulWidget {
  final String apiUrl;
  final String token;
  final Future<void> Function(String userId) deleteUser;

  SearchUserPage({
    required this.apiUrl,
    required this.token,
    required this.deleteUser,
    Key? key,
  }) : super(key: key);

  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  Map<String, dynamic> data = {};
  TextEditingController searchController = TextEditingController();
  String searchType = 'id';

  Future<void> _getData(String type, String value) async {
    var api = AdminUsersSearchGetApi(
      buildContext: context,
      apiUrl: widget.apiUrl,
      token: widget.token,
      value: value,
      type: type,
    );

    await api.execute();

    if (api.response.statusCode == 200) {
      var responseJson = json.decode(api.response.body);

      setState(() {
        data = responseJson;
      });
    } else {
      setState(() {
        data = {};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userSearch),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.searchByWithValue(searchType == "id" ? AppLocalizations.of(context)!.identifier : AppLocalizations.of(context)!.username),
                    ),
                  ),
                ),
                DropdownButton<String>(
                  value: searchType,
                  items: [
                    DropdownMenuItem(
                      value: 'id',
                      child: Text(AppLocalizations.of(context)!.identifier),
                    ),
                    DropdownMenuItem(
                      value: 'username',
                      child: Text(AppLocalizations.of(context)!.username),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      searchType = value ?? 'id';
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () async{
                    await _getData(searchType, searchController.text);
                  },
                  child: Text(AppLocalizations.of(context)!.search),
                ),
              ],
            ),
            SizedBox(height: 20),
            data.isNotEmpty
                ? Card(
                    child: ListTile(
                      title: Text(AppLocalizations.of(context)!.usernameWithValue(data["username"])),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.identifierWithValue(data["id"])),
                          Text(AppLocalizations.of(context)!.ipAddressWithValue(data["ip"])),
                          Text(AppLocalizations.of(context)!.createdAtWithValue(Localization.formatUnixTimestamp(data["created_at"]))),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async{
                          await widget.deleteUser(data["id"]);
                          await _getData(searchType, searchController.text);
                        }
                      ),
                    ),
                  )
                : Text(AppLocalizations.of(context)!.noUsersFound),
          ],
        ),
      ),
    );
  }
}
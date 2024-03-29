// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ModelUserTable extends ModelUser
    with TableInfo<$ModelUserTable, ModelUserData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModelUserTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _loginMeta = const VerificationMeta('login');
  @override
  late final GeneratedColumn<String> login = GeneratedColumn<String>(
      'login', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _passwordMeta =
      const VerificationMeta('password');
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _privateKeyMeta =
      const VerificationMeta('privateKey');
  @override
  late final GeneratedColumn<String> privateKey = GeneratedColumn<String>(
      'private_key', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _accessTokenMeta =
      const VerificationMeta('accessToken');
  @override
  late final GeneratedColumn<String> accessToken = GeneratedColumn<String>(
      'access_token', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, login, password, privateKey, accessToken];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'model_user';
  @override
  VerificationContext validateIntegrity(Insertable<ModelUserData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('login')) {
      context.handle(
          _loginMeta, login.isAcceptableOrUnknown(data['login']!, _loginMeta));
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    }
    if (data.containsKey('private_key')) {
      context.handle(
          _privateKeyMeta,
          privateKey.isAcceptableOrUnknown(
              data['private_key']!, _privateKeyMeta));
    }
    if (data.containsKey('access_token')) {
      context.handle(
          _accessTokenMeta,
          accessToken.isAcceptableOrUnknown(
              data['access_token']!, _accessTokenMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ModelUserData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModelUserData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      login: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}login']),
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password']),
      privateKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}private_key']),
      accessToken: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}access_token']),
    );
  }

  @override
  $ModelUserTable createAlias(String alias) {
    return $ModelUserTable(attachedDatabase, alias);
  }
}

class ModelUserData extends DataClass implements Insertable<ModelUserData> {
  final int id;
  final String? login;
  final String? password;
  final String? privateKey;
  final String? accessToken;
  const ModelUserData(
      {required this.id,
      this.login,
      this.password,
      this.privateKey,
      this.accessToken});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || login != null) {
      map['login'] = Variable<String>(login);
    }
    if (!nullToAbsent || password != null) {
      map['password'] = Variable<String>(password);
    }
    if (!nullToAbsent || privateKey != null) {
      map['private_key'] = Variable<String>(privateKey);
    }
    if (!nullToAbsent || accessToken != null) {
      map['access_token'] = Variable<String>(accessToken);
    }
    return map;
  }

  ModelUserCompanion toCompanion(bool nullToAbsent) {
    return ModelUserCompanion(
      id: Value(id),
      login:
          login == null && nullToAbsent ? const Value.absent() : Value(login),
      password: password == null && nullToAbsent
          ? const Value.absent()
          : Value(password),
      privateKey: privateKey == null && nullToAbsent
          ? const Value.absent()
          : Value(privateKey),
      accessToken: accessToken == null && nullToAbsent
          ? const Value.absent()
          : Value(accessToken),
    );
  }

  factory ModelUserData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModelUserData(
      id: serializer.fromJson<int>(json['id']),
      login: serializer.fromJson<String?>(json['login']),
      password: serializer.fromJson<String?>(json['password']),
      privateKey: serializer.fromJson<String?>(json['privateKey']),
      accessToken: serializer.fromJson<String?>(json['accessToken']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'login': serializer.toJson<String?>(login),
      'password': serializer.toJson<String?>(password),
      'privateKey': serializer.toJson<String?>(privateKey),
      'accessToken': serializer.toJson<String?>(accessToken),
    };
  }

  ModelUserData copyWith(
          {int? id,
          Value<String?> login = const Value.absent(),
          Value<String?> password = const Value.absent(),
          Value<String?> privateKey = const Value.absent(),
          Value<String?> accessToken = const Value.absent()}) =>
      ModelUserData(
        id: id ?? this.id,
        login: login.present ? login.value : this.login,
        password: password.present ? password.value : this.password,
        privateKey: privateKey.present ? privateKey.value : this.privateKey,
        accessToken: accessToken.present ? accessToken.value : this.accessToken,
      );
  @override
  String toString() {
    return (StringBuffer('ModelUserData(')
          ..write('id: $id, ')
          ..write('login: $login, ')
          ..write('password: $password, ')
          ..write('privateKey: $privateKey, ')
          ..write('accessToken: $accessToken')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, login, password, privateKey, accessToken);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModelUserData &&
          other.id == this.id &&
          other.login == this.login &&
          other.password == this.password &&
          other.privateKey == this.privateKey &&
          other.accessToken == this.accessToken);
}

class ModelUserCompanion extends UpdateCompanion<ModelUserData> {
  final Value<int> id;
  final Value<String?> login;
  final Value<String?> password;
  final Value<String?> privateKey;
  final Value<String?> accessToken;
  const ModelUserCompanion({
    this.id = const Value.absent(),
    this.login = const Value.absent(),
    this.password = const Value.absent(),
    this.privateKey = const Value.absent(),
    this.accessToken = const Value.absent(),
  });
  ModelUserCompanion.insert({
    this.id = const Value.absent(),
    this.login = const Value.absent(),
    this.password = const Value.absent(),
    this.privateKey = const Value.absent(),
    this.accessToken = const Value.absent(),
  });
  static Insertable<ModelUserData> custom({
    Expression<int>? id,
    Expression<String>? login,
    Expression<String>? password,
    Expression<String>? privateKey,
    Expression<String>? accessToken,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (login != null) 'login': login,
      if (password != null) 'password': password,
      if (privateKey != null) 'private_key': privateKey,
      if (accessToken != null) 'access_token': accessToken,
    });
  }

  ModelUserCompanion copyWith(
      {Value<int>? id,
      Value<String?>? login,
      Value<String?>? password,
      Value<String?>? privateKey,
      Value<String?>? accessToken}) {
    return ModelUserCompanion(
      id: id ?? this.id,
      login: login ?? this.login,
      password: password ?? this.password,
      privateKey: privateKey ?? this.privateKey,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (login.present) {
      map['login'] = Variable<String>(login.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (privateKey.present) {
      map['private_key'] = Variable<String>(privateKey.value);
    }
    if (accessToken.present) {
      map['access_token'] = Variable<String>(accessToken.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModelUserCompanion(')
          ..write('id: $id, ')
          ..write('login: $login, ')
          ..write('password: $password, ')
          ..write('privateKey: $privateKey, ')
          ..write('accessToken: $accessToken')
          ..write(')'))
        .toString();
  }
}

class $ModelSettingsTable extends ModelSettings
    with TableInfo<$ModelSettingsTable, ModelSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModelSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'model_settings';
  @override
  VerificationContext validateIntegrity(Insertable<ModelSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ModelSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModelSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key']),
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value']),
    );
  }

  @override
  $ModelSettingsTable createAlias(String alias) {
    return $ModelSettingsTable(attachedDatabase, alias);
  }
}

class ModelSetting extends DataClass implements Insertable<ModelSetting> {
  final int id;
  final String? key;
  final String? value;
  const ModelSetting({required this.id, this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || key != null) {
      map['key'] = Variable<String>(key);
    }
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  ModelSettingsCompanion toCompanion(bool nullToAbsent) {
    return ModelSettingsCompanion(
      id: Value(id),
      key: key == null && nullToAbsent ? const Value.absent() : Value(key),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
    );
  }

  factory ModelSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModelSetting(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String?>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String?>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  ModelSetting copyWith(
          {int? id,
          Value<String?> key = const Value.absent(),
          Value<String?> value = const Value.absent()}) =>
      ModelSetting(
        id: id ?? this.id,
        key: key.present ? key.value : this.key,
        value: value.present ? value.value : this.value,
      );
  @override
  String toString() {
    return (StringBuffer('ModelSetting(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModelSetting &&
          other.id == this.id &&
          other.key == this.key &&
          other.value == this.value);
}

class ModelSettingsCompanion extends UpdateCompanion<ModelSetting> {
  final Value<int> id;
  final Value<String?> key;
  final Value<String?> value;
  const ModelSettingsCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
  });
  ModelSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
  });
  static Insertable<ModelSetting> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? value,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
    });
  }

  ModelSettingsCompanion copyWith(
      {Value<int>? id, Value<String?>? key, Value<String?>? value}) {
    return ModelSettingsCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModelSettingsCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  late final $ModelUserTable modelUser = $ModelUserTable(this);
  late final $ModelSettingsTable modelSettings = $ModelSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [modelUser, modelSettings];
}

//author: Sang Do
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';

class UserSettingModel {
    String uuid;  //random unique ID
    late String? usr;
    late String? name;
    late String? stocks;  //list of favorited stocks

  UserSettingModel({
    required this.uuid,
    this.usr,
    this.name,
    this.stocks
  });

  UserSettingModel.empty({
    required this.uuid
  });

//
  factory UserSettingModel.fromJson(Map<String, dynamic> json) {
    return UserSettingModel(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      usr: json['usr'] as String,
      stocks: jsonEncode(json['stocks'])
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'usr': usr,
      'stocks': stocks
    };
  }

  factory UserSettingModel.fromMap(Map<String, dynamic> map) {
    return UserSettingModel(
      uuid: map['uuid'],
      name : map['name'],
      usr : map['usr'],
      stocks: map['stocks']
    );
  }
}

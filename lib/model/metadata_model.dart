//author: Sang Do
// ignore_for_file: non_constant_identifier_names

class MetaDataModel {
    String uuid;  //random unique ID because Metadata has only 1 record
    late String fin_key;
    late String fin_uri;
    late String gem_key;
    late String gem_uri;
    late String avatar_uri;
    late String backend_uri;
    late String otc_market_uri;
    late int update_time;

  MetaDataModel({
    required this.uuid,
    required this.fin_key, 
    required this.fin_uri,
    required this.gem_key,
    required this.gem_uri,
    required this.avatar_uri,
    required this.backend_uri,
    required this.otc_market_uri,
    required this.update_time
  });

  MetaDataModel.empty({
    required this.uuid
  });

  factory MetaDataModel.fromJson(Map<String, dynamic> json) {
    return MetaDataModel(
      uuid: json['uuid'] as String,
      fin_key: json['fin_key'] as String,
      fin_uri: json['fin_uri'],
      gem_key: json['gem_key'] as String,
      gem_uri: json['gem_key'] as String,
      avatar_uri: json['gem_key'] as String,
      backend_uri: json['gem_key'] as String,
      otc_market_uri: json['gem_key'] as String,
      update_time: json['update_time'] as int
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'fin_key': fin_key,
      'fin_uri': fin_uri,
      'gem_key': gem_key,
      'gem_uri': gem_uri,
      'avatar_uri': avatar_uri,
      'backend_uri': backend_uri,
      'otc_market_uri': otc_market_uri,
      'update_time': update_time,
      };
  }

  factory MetaDataModel.fromMap(Map<String, dynamic> map) {
    return MetaDataModel(
      uuid: map['uuid'],
      fin_key : map['fin_key'],
      fin_uri : map['fin_uri'],
      gem_key : map['gem_key'],
      gem_uri : map['gem_uri'],
      avatar_uri : map['avatar_uri'],
      backend_uri : map['backend_uri'],
      otc_market_uri : map['otc_market_uri'],
      update_time: map['update_time'],
    );
  }
}
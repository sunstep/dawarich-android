import 'api_point_point.dart';

class RawData {
  int? m;
  int? bs;
  String? sId;
  int? acc;
  int? alt;
  int? cog;
  double? lat;
  double? lon;
  String? tid;
  int? tst;
  int? vac;
  int? vel;
  String? ssid;
  int? batt;
  String? conn;
  String? bssid;
  String? sType;
  ApiPointPoint? point;
  String? topic;
  String? action;
  String? apiKey;
  String? controller;
  int? createdAt;

  RawData(Map<String, dynamic> json) {
    m = json['m'];
    bs = json['bs'];
    sId = json['_id'];
    acc = json['acc'];
    alt = json['alt'];
    cog = json['cog'];
    lat = json['lat'];
    lon = json['lon'];
    tid = json['tid'];
    tst = json['tst'];
    vac = json['vac'];
    vel = json['vel'];
    ssid = json['SSID'];
    batt = json['batt'];
    conn = json['conn'];
    bssid = json['BSSID'];
    sType = json['_type'];
    point = json['point'] != null ?  ApiPointPoint(json['point']) : null;
    topic = json['topic'];
    action = json['action'];
    apiKey = json['api_key'];
    controller = json['controller'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['m'] = m;
    data['bs'] = bs;
    data['_id'] = sId;
    data['acc'] = acc;
    data['alt'] = alt;
    data['lat'] = lat;
    data['lon'] = lon;
    data['tid'] = tid;
    data['tst'] = tst;
    data['vac'] = vac;
    data['vel'] = vel;
    data['batt'] = batt;
    data['conn'] = conn;
    data['_type'] = sType;
    if (point != null) {
      data['point'] = point!.toJson();
    }
    data['topic'] = topic;
    data['action'] = action;
    data['api_key'] = apiKey;
    data['controller'] = controller;
    data['created_at'] = createdAt;
    return data;
  }
}

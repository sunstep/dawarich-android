class ApiPointPoint {
  String? topic;
  int? createdAt;

  ApiPointPoint(Map<String, dynamic> json) {
    topic = json['topic'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['topic'] = topic;
    data['created_at'] = createdAt;
    return data;
  }
}
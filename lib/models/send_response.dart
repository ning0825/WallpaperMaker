class SendResponse {
  final String objectId;
  final String createdAt;

  SendResponse({this.objectId, this.createdAt});

  factory SendResponse.fromJson(Map<String, dynamic> json) {
    return SendResponse(
      objectId: json['objectId'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['objectId'] = this.objectId;
    data['createdAt'] = this.createdAt;
    return data;
  }
}

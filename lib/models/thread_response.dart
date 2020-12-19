import 'package:json_annotation/json_annotation.dart';

part 'thread_response.g.dart';

@JsonSerializable()
class ThreadResponse {
  @JsonKey(name: 'results')
  List<Results> results;

  ThreadResponse({this.results});

  factory ThreadResponse.fromJson(Map<String, dynamic> json) =>
      _$ThreadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadResponseToJson(this);
}

@JsonSerializable()
class Results {
  @JsonKey(name: 'updatedAt')
  String updatedAt;
  @JsonKey(name: 'content')
  String content;
  @JsonKey(name: 'uid')
  String uid;
  @JsonKey(name: 'objectId')
  String objectId;
  @JsonKey(name: 'createdAt')
  String createdAt;
  @JsonKey(name: 'status')
  String status;
  @JsonKey(name: 'deviceType')
  String deviceType;
  @JsonKey(name: 'contact')
  String contact;

  Results(
      {this.updatedAt,
      this.content,
      this.uid,
      this.objectId,
      this.createdAt,
      this.status,
      this.deviceType,
      this.contact});

  factory Results.fromJson(Map<String, dynamic> json) =>
      _$ResultsFromJson(json);

  Map<String, dynamic> toJson() => _$ResultsToJson(this);
}

Results _$ResultsFromJson(Map<String, dynamic> json) {
  return Results(
    updatedAt: json['updatedAt'] as String,
    content: json['content'] as String,
    uid: json['uid'] as String,
    objectId: json['objectId'] as String,
    createdAt: json['createdAt'] as String,
    status: json['status'] as String,
    deviceType: json['deviceType'] as String,
    contact: json['contact'] as String,
  );
}

Map<String, dynamic> _$ResultsToJson(Results instance) => <String, dynamic>{
      'updatedAt': instance.updatedAt,
      'content': instance.content,
      'uid': instance.uid,
      'objectId': instance.objectId,
      'createdAt': instance.createdAt,
      'status': instance.status,
      'deviceType': instance.deviceType,
      'contact': instance.contact,
    };

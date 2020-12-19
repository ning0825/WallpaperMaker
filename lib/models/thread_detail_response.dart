import 'package:json_annotation/json_annotation.dart';
import 'feedback.dart';

part 'thread_detail_response.g.dart';

@JsonSerializable()
class ThreadDetailResponse {
  @JsonKey(name: 'results')
  List<Results> results;

  ThreadDetailResponse({this.results});

  factory ThreadDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$ThreadDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ThreadDetailResponseToJson(this);
}

@JsonSerializable()
class Results {
  @JsonKey(name: 'type')
  String type;
  @JsonKey(name: 'content')
  String content;
  @JsonKey(name: 'feedback')
  Feedback feedback;
  @JsonKey(name: 'createdAt')
  String createdAt;
  @JsonKey(name: 'updatedAt')
  String updatedAt;
  @JsonKey(name: 'objectId')
  String objectId;

  Results(
      {this.type,
      this.content,
      this.feedback,
      this.createdAt,
      this.updatedAt,
      this.objectId});

  factory Results.fromJson(Map<String, dynamic> json) =>
      _$ResultsFromJson(json);

  Map<String, dynamic> toJson() => _$ResultsToJson(this);
}

Results _$ResultsFromJson(Map<String, dynamic> json) {
  return Results(
    type: json['type'] as String,
    content: json['content'] as String,
    feedback: json['feedback'] == null
        ? null
        : Feedback.fromJson(json['feedback'] as Map<String, dynamic>),
    createdAt: json['createdAt'] as String,
    updatedAt: json['updatedAt'] as String,
    objectId: json['objectId'] as String,
  );
}

Map<String, dynamic> _$ResultsToJson(Results instance) => <String, dynamic>{
      'type': instance.type,
      'content': instance.content,
      'feedback': instance.feedback,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'objectId': instance.objectId,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Feedback _$FeedbackFromJson(Map<String, dynamic> json) {
  return Feedback(
    type: json['__type'] as String,
    className: json['className'] as String,
    objectId: json['objectId'] as String,
  );
}

Map<String, dynamic> _$FeedbackToJson(Feedback instance) => <String, dynamic>{
      '__type': instance.type,
      'className': instance.className,
      'objectId': instance.objectId,
    };

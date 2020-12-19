// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadResponse _$ThreadResponseFromJson(Map<String, dynamic> json) {
  return ThreadResponse(
    results: (json['results'] as List)
        ?.map((e) =>
            e == null ? null : Results.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ThreadResponseToJson(ThreadResponse instance) =>
    <String, dynamic>{
      'results': instance.results,
    };

// Results _$ResultsFromJson(Map<String, dynamic> json) {
//   return Results(
//     updatedAt: json['updatedAt'] as String,
//     content: json['content'] as String,
//     uid: json['uid'] as String,
//     objectId: json['objectId'] as String,
//     createdAt: json['createdAt'] as String,
//     status: json['status'] as String,
//     deviceType: json['deviceType'] as String,
//     contact: json['contact'] as String,
//   );
// }

// Map<String, dynamic> _$ResultsToJson(Results instance) => <String, dynamic>{
//       'updatedAt': instance.updatedAt,
//       'content': instance.content,
//       'uid': instance.uid,
//       'objectId': instance.objectId,
//       'createdAt': instance.createdAt,
//       'status': instance.status,
//       'deviceType': instance.deviceType,
//       'contact': instance.contact,
//     };

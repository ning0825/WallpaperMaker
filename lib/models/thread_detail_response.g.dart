// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'thread_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ThreadDetailResponse _$ThreadDetailResponseFromJson(Map<String, dynamic> json) {
  return ThreadDetailResponse(
    results: (json['results'] as List)
        ?.map((e) =>
            e == null ? null : Results.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ThreadDetailResponseToJson(
        ThreadDetailResponse instance) =>
    <String, dynamic>{
      'results': instance.results,
    };

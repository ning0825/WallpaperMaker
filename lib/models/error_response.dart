import 'package:json_annotation/json_annotation.dart';

part 'error_response.g.dart';

@JsonSerializable()
class ErrorResponse  {
	@JsonKey(name: 'code')
	int code;
	@JsonKey(name: 'error')
	String error;

	ErrorResponse({this.code, this.error});

	factory ErrorResponse.fromJson(Map<String, dynamic> json) => _$ErrorResponseFromJson(json);

	Map<String, dynamic> toJson() => _$ErrorResponseToJson(this);


}

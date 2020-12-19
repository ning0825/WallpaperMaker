import 'package:json_annotation/json_annotation.dart';

part 'feedback.g.dart';

@JsonSerializable()
class Feedback  {
	@JsonKey(name: '__type')
	String type;
	@JsonKey(name: 'className')
	String className;
	@JsonKey(name: 'objectId')
	String objectId;

	Feedback({this.type, this.className, this.objectId});

	factory Feedback.fromJson(Map<String, dynamic> json) => _$FeedbackFromJson(json);

	Map<String, dynamic> toJson() => _$FeedbackToJson(this);


}

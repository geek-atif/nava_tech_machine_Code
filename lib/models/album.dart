import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'album.g.dart';

@JsonSerializable()
class Album extends Equatable {
  final int id;
  final int userId;
  final String title;

  const Album({required this.id, required this.userId, required this.title});

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);

  Map<String, dynamic> toJson() => _$AlbumToJson(this);

  @override
  List<Object?> get props => [id, userId, title];
}

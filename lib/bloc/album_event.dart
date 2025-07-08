import 'package:equatable/equatable.dart';

abstract class AlbumEvent extends Equatable {
  const AlbumEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlbums extends AlbumEvent {
  final bool forceRefresh;
  final int page;

  const LoadAlbums({this.forceRefresh = false, this.page = 1});

  @override
  List<Object?> get props => [forceRefresh, page];
}

class LoadMoreAlbums extends AlbumEvent {
  const LoadMoreAlbums();
}

class LoadPhotos extends AlbumEvent {
  final int albumId;
  final bool forceRefresh;
  final int page;

  const LoadPhotos(this.albumId, {this.forceRefresh = false, this.page = 1});

  @override
  List<Object?> get props => [albumId, forceRefresh, page];
}

class LoadMorePhotos extends AlbumEvent {
  final int albumId;

  const LoadMorePhotos(this.albumId);

  @override
  List<Object?> get props => [albumId];
}

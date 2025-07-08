import 'package:equatable/equatable.dart';
import '../models/album.dart';
import '../models/photo.dart';

abstract class AlbumState extends Equatable {
  const AlbumState();

  @override
  List<Object?> get props => [];
}

class AlbumInitial extends AlbumState {}

class AlbumLoading extends AlbumState {}

class AlbumLoaded extends AlbumState {
  final List<Album> albums;
  final Map<int, List<Photo>> photos;
  final int currentAlbumPage;
  final Map<int, int> currentPhotoPages; // Maps albumId to current photo page
  final bool isLoadingMoreAlbums;
  final Map<int, bool> isLoadingMorePhotos; // Maps albumId to loading state
  final bool hasMoreAlbums;
  final Map<int, bool>
  hasMorePhotos; // Maps albumId to whether there are more photos

  const AlbumLoaded({
    required this.albums,
    required this.photos,
    this.currentAlbumPage = 1,
    this.currentPhotoPages = const {},
    this.isLoadingMoreAlbums = false,
    this.isLoadingMorePhotos = const {},
    this.hasMoreAlbums = true,
    this.hasMorePhotos = const {},
  });

  @override
  List<Object?> get props => [
    albums,
    photos,
    currentAlbumPage,
    currentPhotoPages,
    isLoadingMoreAlbums,
    isLoadingMorePhotos,
    hasMoreAlbums,
    hasMorePhotos,
  ];

  AlbumLoaded copyWith({
    List<Album>? albums,
    Map<int, List<Photo>>? photos,
    int? currentAlbumPage,
    Map<int, int>? currentPhotoPages,
    bool? isLoadingMoreAlbums,
    Map<int, bool>? isLoadingMorePhotos,
    bool? hasMoreAlbums,
    Map<int, bool>? hasMorePhotos,
  }) {
    return AlbumLoaded(
      albums: albums ?? this.albums,
      photos: photos ?? this.photos,
      currentAlbumPage: currentAlbumPage ?? this.currentAlbumPage,
      currentPhotoPages: currentPhotoPages ?? this.currentPhotoPages,
      isLoadingMoreAlbums: isLoadingMoreAlbums ?? this.isLoadingMoreAlbums,
      isLoadingMorePhotos: isLoadingMorePhotos ?? this.isLoadingMorePhotos,
      hasMoreAlbums: hasMoreAlbums ?? this.hasMoreAlbums,
      hasMorePhotos: hasMorePhotos ?? this.hasMorePhotos,
    );
  }
}

class AlbumLoadingMore extends AlbumState {
  final List<Album> albums;
  final Map<int, List<Photo>> photos;
  final int currentAlbumPage;
  final Map<int, int> currentPhotoPages;

  const AlbumLoadingMore({
    required this.albums,
    required this.photos,
    required this.currentAlbumPage,
    required this.currentPhotoPages,
  });

  @override
  List<Object?> get props => [
    albums,
    photos,
    currentAlbumPage,
    currentPhotoPages,
  ];
}

class AlbumError extends AlbumState {
  final String message;

  const AlbumError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'album_event.dart';
import 'album_state.dart';
import '../repositories/album_repository.dart';
import '../models/photo.dart';

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final AlbumRepository _albumRepository;

  AlbumBloc(this._albumRepository) : super(AlbumInitial()) {
    print(' AlbumBloc: Initializing bloc');
    on<LoadAlbums>(_onLoadAlbums);
    on<LoadMoreAlbums>(_onLoadMoreAlbums);
    on<LoadPhotos>(_onLoadPhotos);
    on<LoadMorePhotos>(_onLoadMorePhotos);
  }

  Future<void> _onLoadAlbums(LoadAlbums event, Emitter<AlbumState> emit) async {
    print(
      ' AlbumBloc: Received LoadAlbums event (page: ${event.page}, forceRefresh: ${event.forceRefresh})',
    );

    try {
      if (event.page == 1) {
        print(' AlbumBloc: Emitting AlbumLoading state');
        emit(AlbumLoading());
      }

      print('AlbumBloc: Fetching albums page ${event.page} from repository');
      final albums = await _albumRepository.getAlbums(
        page: event.page,
        forceRefresh: event.forceRefresh,
      );
      print('AlbumBloc: Successfully fetched ${albums.length} albums');

      if (albums.isNotEmpty) {
        print('AlbumBloc: Fetching photos for ${albums.length} albums');
        final photos = await _albumRepository.getPhotosForAlbums(albums);
        print(
          'AlbumBloc: Successfully fetched photos for ${photos.length} albums',
        );

        // Check if there are more albums to load
        final hasMoreAlbums = await _albumRepository.hasMoreAlbums(event.page);

        // Initialize photo page tracking
        final currentPhotoPages = <int, int>{};
        final hasMorePhotos = <int, bool>{};

        for (final album in albums) {
          currentPhotoPages[album.id] = 1;
          hasMorePhotos[album.id] = await _albumRepository.hasMorePhotos(
            album.id,
            1,
          );
        }

        print(
          ' AlbumBloc: Emitting AlbumLoaded state with ${albums.length} albums',
        );
        emit(
          AlbumLoaded(
            albums: albums,
            photos: photos,
            currentAlbumPage: event.page,
            currentPhotoPages: currentPhotoPages,
            hasMoreAlbums: hasMoreAlbums,
            hasMorePhotos: hasMorePhotos,
          ),
        );
      } else {
        print(' AlbumBloc: No albums found');
        emit(const AlbumLoaded(albums: [], photos: {}, hasMoreAlbums: false));
      }
    } catch (e) {
      print(' AlbumBloc: Error in _onLoadAlbums: $e');
      print(' AlbumBloc: Stack trace: ${StackTrace.current}');
      emit(AlbumError('Failed to load albums: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMoreAlbums(
    LoadMoreAlbums event,
    Emitter<AlbumState> emit,
  ) async {
    print(' AlbumBloc: Received LoadMoreAlbums event');

    if (state is! AlbumLoaded) {
      print(
        ' AlbumBloc: Current state is not AlbumLoaded, cannot load more albums',
      );
      return;
    }

    final currentState = state as AlbumLoaded;

    if (currentState.isLoadingMoreAlbums || !currentState.hasMoreAlbums) {
      print(
        '⏸ AlbumBloc: Already loading more albums or no more albums available',
      );
      return;
    }

    try {
      print(' AlbumBloc: Setting loading more albums state');
      emit(currentState.copyWith(isLoadingMoreAlbums: true));

      final nextPage = currentState.currentAlbumPage + 1;
      print(' AlbumBloc: Fetching albums page $nextPage from repository');

      final newAlbums = await _albumRepository.getAlbums(page: nextPage);
      print(' AlbumBloc: Successfully fetched ${newAlbums.length} new albums');

      if (newAlbums.isNotEmpty) {
        print(
          '📸 AlbumBloc: Fetching photos for ${newAlbums.length} new albums',
        );
        final newPhotos = await _albumRepository.getPhotosForAlbums(newAlbums);

        // Combine existing and new data
        final allAlbums = [...currentState.albums, ...newAlbums];
        final allPhotos = {...currentState.photos, ...newPhotos};

        // Update photo page tracking
        final updatedPhotoPages = Map<int, int>.from(
          currentState.currentPhotoPages,
        );
        final updatedHasMorePhotos = Map<int, bool>.from(
          currentState.hasMorePhotos,
        );

        for (final album in newAlbums) {
          updatedPhotoPages[album.id] = 1;
          updatedHasMorePhotos[album.id] = await _albumRepository.hasMorePhotos(
            album.id,
            1,
          );
        }

        // Check if there are more albums to load
        final hasMoreAlbums = await _albumRepository.hasMoreAlbums(nextPage);

        print(
          ' AlbumBloc: Emitting updated AlbumLoaded state with ${allAlbums.length} total albums',
        );
        emit(
          AlbumLoaded(
            albums: allAlbums,
            photos: allPhotos,
            currentAlbumPage: nextPage,
            currentPhotoPages: updatedPhotoPages,
            hasMoreAlbums: hasMoreAlbums,
            hasMorePhotos: updatedHasMorePhotos,
          ),
        );
      } else {
        print(' AlbumBloc: No more albums to load');
        emit(
          currentState.copyWith(
            isLoadingMoreAlbums: false,
            hasMoreAlbums: false,
          ),
        );
      }
    } catch (e) {
      print(' AlbumBloc: Error in _onLoadMoreAlbums: $e');
      emit(currentState.copyWith(isLoadingMoreAlbums: false));
    }
  }

  Future<void> _onLoadPhotos(LoadPhotos event, Emitter<AlbumState> emit) async {
    print(
      ' AlbumBloc: Received LoadPhotos event for album ${event.albumId} (page: ${event.page}, forceRefresh: ${event.forceRefresh})',
    );

    try {
      if (state is AlbumLoaded) {
        print('AlbumBloc: Current state is AlbumLoaded, updating photos');
        final currentState = state as AlbumLoaded;

        print(
          ' AlbumBloc: Fetching photos for album ${event.albumId} page ${event.page}',
        );
        final photos = await _albumRepository.getPhotos(
          event.albumId,
          page: event.page,
          forceRefresh: event.forceRefresh,
        );
        print(
          ' AlbumBloc: Successfully fetched ${photos.length} photos for album ${event.albumId}',
        );

        final updatedPhotos = Map<int, List<Photo>>.from(currentState.photos);
        updatedPhotos[event.albumId] = photos;

        final updatedPhotoPages = Map<int, int>.from(
          currentState.currentPhotoPages,
        );
        updatedPhotoPages[event.albumId] = event.page;

        final updatedHasMorePhotos = Map<int, bool>.from(
          currentState.hasMorePhotos,
        );
        updatedHasMorePhotos[event.albumId] = await _albumRepository
            .hasMorePhotos(event.albumId, event.page);

        print(
          ' AlbumBloc: Emitting updated AlbumLoaded state with new photos for album ${event.albumId}',
        );
        emit(
          currentState.copyWith(
            photos: updatedPhotos,
            currentPhotoPages: updatedPhotoPages,
            hasMorePhotos: updatedHasMorePhotos,
          ),
        );
      } else {
        print(
          ' AlbumBloc: Current state is not AlbumLoaded (${state.runtimeType}), cannot update photos',
        );
      }
    } catch (e) {
      print(' AlbumBloc: Error in _onLoadPhotos: $e');
      print('AlbumBloc: Stack trace: ${StackTrace.current}');
      emit(
        AlbumError(
          'Failed to load photos for album ${event.albumId}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onLoadMorePhotos(
    LoadMorePhotos event,
    Emitter<AlbumState> emit,
  ) async {
    print(
      'AlbumBloc: Received LoadMorePhotos event for album ${event.albumId}',
    );

    if (state is! AlbumLoaded) {
      print(
        'AlbumBloc: Current state is not AlbumLoaded, cannot load more photos',
      );
      return;
    }

    final currentState = state as AlbumLoaded;

    final isLoadingMorePhotos =
        currentState.isLoadingMorePhotos[event.albumId] ?? false;
    final hasMorePhotos = currentState.hasMorePhotos[event.albumId] ?? false;

    if (isLoadingMorePhotos || !hasMorePhotos) {
      print(
        'AlbumBloc: Already loading more photos or no more photos available for album ${event.albumId}',
      );
      return;
    }

    try {
      print(
        'AlbumBloc: Setting loading more photos state for album ${event.albumId}',
      );
      final updatedLoadingMorePhotos = Map<int, bool>.from(
        currentState.isLoadingMorePhotos,
      );
      updatedLoadingMorePhotos[event.albumId] = true;

      emit(
        currentState.copyWith(isLoadingMorePhotos: updatedLoadingMorePhotos),
      );

      final currentPage = currentState.currentPhotoPages[event.albumId] ?? 1;
      final nextPage = currentPage + 1;

      print(
        ' AlbumBloc: Fetching photos page $nextPage for album ${event.albumId}',
      );
      final newPhotos = await _albumRepository.getPhotos(
        event.albumId,
        page: nextPage,
      );
      print(
        ' AlbumBloc: Successfully fetched ${newPhotos.length} new photos for album ${event.albumId}',
      );

      if (newPhotos.isNotEmpty) {
        // Combine existing and new photos
        final existingPhotos = currentState.photos[event.albumId] ?? [];
        final allPhotos = [...existingPhotos, ...newPhotos];

        final updatedPhotos = Map<int, List<Photo>>.from(currentState.photos);
        updatedPhotos[event.albumId] = allPhotos;

        final updatedPhotoPages = Map<int, int>.from(
          currentState.currentPhotoPages,
        );
        updatedPhotoPages[event.albumId] = nextPage;

        final updatedHasMorePhotos = Map<int, bool>.from(
          currentState.hasMorePhotos,
        );
        updatedHasMorePhotos[event.albumId] = await _albumRepository
            .hasMorePhotos(event.albumId, nextPage);

        updatedLoadingMorePhotos[event.albumId] = false;

        print(
          ' AlbumBloc: Emitting updated AlbumLoaded state with ${allPhotos.length} total photos for album ${event.albumId}',
        );
        emit(
          currentState.copyWith(
            photos: updatedPhotos,
            currentPhotoPages: updatedPhotoPages,
            hasMorePhotos: updatedHasMorePhotos,
            isLoadingMorePhotos: updatedLoadingMorePhotos,
          ),
        );
      } else {
        print(' AlbumBloc: No more photos to load for album ${event.albumId}');
        updatedLoadingMorePhotos[event.albumId] = false;
        final updatedHasMorePhotos = Map<int, bool>.from(
          currentState.hasMorePhotos,
        );
        updatedHasMorePhotos[event.albumId] = false;

        emit(
          currentState.copyWith(
            isLoadingMorePhotos: updatedLoadingMorePhotos,
            hasMorePhotos: updatedHasMorePhotos,
          ),
        );
      }
    } catch (e) {
      print(' AlbumBloc: Error in _onLoadMorePhotos: $e');
      final updatedLoadingMorePhotos = Map<int, bool>.from(
        currentState.isLoadingMorePhotos,
      );
      updatedLoadingMorePhotos[event.albumId] = false;
      emit(
        currentState.copyWith(isLoadingMorePhotos: updatedLoadingMorePhotos),
      );
    }
  }
}

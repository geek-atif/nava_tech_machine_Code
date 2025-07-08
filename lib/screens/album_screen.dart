import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/album_bloc.dart';
import '../bloc/album_event.dart';
import '../bloc/album_state.dart';
import '../widgets/album_item.dart';
import '../widgets/paginated_list.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  late ScrollController _mainScrollController;

  @override
  void initState() {
    super.initState();
    print(' AlbumScreen: Initializing screen');
    _mainScrollController = ScrollController();

    print('AlbumScreen: Requesting albums to be loaded');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlbumBloc>().add(const LoadAlbums());
    });
  }

  @override
  void dispose() {
    print(' AlbumScreen: Disposing screen');
    _mainScrollController.dispose();
    super.dispose();
  }

  void _loadMoreAlbums() {
    print(' AlbumScreen: Loading more albums');
    context.read<AlbumBloc>().add(const LoadMoreAlbums());
  }

  void _loadMorePhotos(int albumId) {
    print(' AlbumScreen: Loading more photos for album $albumId');
    context.read<AlbumBloc>().add(LoadMorePhotos(albumId));
  }

  @override
  Widget build(BuildContext context) {
    print(' AlbumScreen: Building screen');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Albums'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print(' AlbumScreen: Refresh button pressed');
              context.read<AlbumBloc>().add(
                const LoadAlbums(forceRefresh: true),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AlbumBloc, AlbumState>(
        builder: (context, state) {
          print(
            ' AlbumScreen: BlocBuilder received state: ${state.runtimeType}',
          );

          if (state is AlbumLoading) {
            print(' AlbumScreen: Showing loading indicator');
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading albums...', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          } else if (state is AlbumLoaded) {
            print(' AlbumScreen: Albums loaded successfully');
            print(
              ' AlbumScreen: ${state.albums.length} albums with ${state.photos.length} photo collections',
            );

            if (state.albums.isEmpty) {
              print('AlbumScreen: No albums available');
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No albums available',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Create album items with pagination support
            print(
              ' AlbumScreen: Creating ${state.albums.length} album widgets with pagination',
            );
            final albumItems =
                state.albums.asMap().entries.map((entry) {
                  final index = entry.key;
                  final album = entry.value;
                  final photos = state.photos[album.id] ?? [];
                  final hasMorePhotos = state.hasMorePhotos[album.id] ?? false;
                  final isLoadingMorePhotos =
                      state.isLoadingMorePhotos[album.id] ?? false;

                  print(
                    ' AlbumScreen: Creating album item $index - "${album.title}" with ${photos.length} photos (hasMore: $hasMorePhotos, loading: $isLoadingMorePhotos)',
                  );

                  return AlbumItem(
                    album: album,
                    photos: photos,
                    hasMorePhotos: hasMorePhotos,
                    isLoadingMorePhotos: isLoadingMorePhotos,
                    onLoadMorePhotos: () => _loadMorePhotos(album.id),
                  );
                }).toList();

            print(
              'AlbumScreen: Building PaginatedList with ${albumItems.length} items (hasMoreAlbums: ${state.hasMoreAlbums}, loadingMore: ${state.isLoadingMoreAlbums})',
            );
            return PaginatedList(
              controller: _mainScrollController,
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              hasMore: state.hasMoreAlbums,
              isLoading: state.isLoadingMoreAlbums,
              onLoadMore: _loadMoreAlbums,
              children: albumItems,
            );
          } else if (state is AlbumLoadingMore) {
            print('AlbumScreen: Loading more albums state');
            // Still show the current albums while loading more
            final albumItems =
                state.albums.asMap().entries.map((entry) {
                  final index = entry.key;
                  final album = entry.value;
                  final photos = state.photos[album.id] ?? [];

                  print(
                    'AlbumScreen: Creating album item $index during load more - "${album.title}" with ${photos.length} photos',
                  );

                  return AlbumItem(
                    album: album,
                    photos: photos,
                    hasMorePhotos: false, // Simplified during loading more
                    isLoadingMorePhotos: false,
                  );
                }).toList();

            return PaginatedList(
              controller: _mainScrollController,
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              hasMore: true,
              isLoading: true,
              onLoadMore: _loadMoreAlbums,
              children: albumItems,
            );
          } else if (state is AlbumError) {
            print(' AlbumScreen: Error state received: ${state.message}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading albums',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            print(' AlbumScreen: Retry button pressed');
                            context.read<AlbumBloc>().add(const LoadAlbums());
                          },
                          child: const Text('Retry'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            print(' AlbumScreen: Force refresh button pressed');
                            context.read<AlbumBloc>().add(
                              const LoadAlbums(forceRefresh: true),
                            );
                          },
                          child: const Text('Force Refresh'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }

          print(' AlbumScreen: Unknown state received: ${state.runtimeType}');
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/album.dart';
import '../models/photo.dart';
import '../database/database_helper.dart';

class AlbumRepository {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Pagination constants
  static const int _albumsPerPage = 10;
  static const int _photosPerPage = 20;

  Future<List<Album>> getAlbums({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    print(
      'AlbumRepository: Getting albums page $page (forceRefresh: $forceRefresh)',
    );

    if (!forceRefresh) {
      // Try to get from cache first
      print(' AlbumRepository: Checking cache for albums page $page');
      final cachedAlbums = await _databaseHelper.getAlbums();

      // Calculate pagination for cached data
      final startIndex = (page - 1) * _albumsPerPage;
      final endIndex = startIndex + _albumsPerPage;

      if (cachedAlbums.length > startIndex) {
        final paginatedAlbums = cachedAlbums.sublist(
          startIndex,
          endIndex > cachedAlbums.length ? cachedAlbums.length : endIndex,
        );
        print(
          'AlbumRepository: Found ${paginatedAlbums.length} cached albums for page $page',
        );
        return paginatedAlbums;
      }
      print('AlbumRepository: No cached albums found for page $page');
    }

    // Fetch from API with pagination
    print('AlbumRepository: Fetching albums page $page from API');
    final start = (page - 1) * _albumsPerPage;
    final apiUrl = '$_baseUrl/albums?_start=$start&_limit=$_albumsPerPage';
    print('API REQUEST: GET $apiUrl');

    try {
      final response = await http
          .get(Uri.parse(apiUrl), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      print('API RESPONSE: Status ${response.statusCode}');
      print('API RESPONSE: Headers ${response.headers}');
      print('API RESPONSE: Body length ${response.body.length}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print(
          'AlbumRepository: Successfully parsed ${jsonList.length} albums from API for page $page',
        );

        final albums = jsonList.map((json) => Album.fromJson(json)).toList();

        // Cache the albums (only if it's the first page or force refresh)
        if (page == 1 || forceRefresh) {
          print(
            'AlbumRepository: Caching ${albums.length} albums for page $page',
          );
          await _databaseHelper.insertAlbums(albums);
        }

        return albums;
      } else {
        print(
          'AlbumRepository: API request failed with status ${response.statusCode}',
        );
        print('API ERROR BODY: ${response.body}');
        throw Exception(
          'Failed to load albums page $page: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('AlbumRepository: Exception occurred: $e');
      throw Exception('Failed to load albums page $page: $e');
    }
  }

  Future<List<Photo>> getPhotos(
    int albumId, {
    int page = 1,
    bool forceRefresh = false,
  }) async {
    print(
      'AlbumRepository: Getting photos for album $albumId page $page (forceRefresh: $forceRefresh)',
    );

    if (!forceRefresh) {
      // Try to get from cache first
      print(
        'AlbumRepository: Checking cache for photos of album $albumId page $page',
      );
      final cachedPhotos = await _databaseHelper.getPhotos(albumId);

      // Calculate pagination for cached data
      final startIndex = (page - 1) * _photosPerPage;
      final endIndex = startIndex + _photosPerPage;

      if (cachedPhotos.length > startIndex) {
        final paginatedPhotos = cachedPhotos.sublist(
          startIndex,
          endIndex > cachedPhotos.length ? cachedPhotos.length : endIndex,
        );
        print(
          'AlbumRepository: Found ${paginatedPhotos.length} cached photos for album $albumId page $page',
        );
        return paginatedPhotos;
      }
      print(
        'AlbumRepository: No cached photos found for album $albumId page $page',
      );
    }

    // Fetch from API with pagination
    print(
      'AlbumRepository: Fetching photos for album $albumId page $page from API',
    );
    final start = (page - 1) * _photosPerPage;
    final apiUrl =
        '$_baseUrl/photos?albumId=$albumId&_start=$start&_limit=$_photosPerPage';
    print('API REQUEST: GET $apiUrl');

    try {
      final response = await http
          .get(Uri.parse(apiUrl), headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      print('API RESPONSE: Status ${response.statusCode}');
      print('API RESPONSE: Headers ${response.headers}');
      print('API RESPONSE: Body length ${response.body.length}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print(
          'AlbumRepository: Successfully parsed ${jsonList.length} photos for album $albumId page $page',
        );

        final photos = jsonList.map((json) => Photo.fromJson(json)).toList();

        // Cache the photos (only if it's the first page or force refresh)
        if (page == 1 || forceRefresh) {
          print(
            'AlbumRepository: Caching ${photos.length} photos for album $albumId page $page',
          );
          await _databaseHelper.insertPhotos(photos);
        }

        return photos;
      } else {
        print(
          'AlbumRepository: API request failed with status ${response.statusCode}',
        );
        print('API ERROR BODY: ${response.body}');
        throw Exception(
          'Failed to load photos for album $albumId page $page: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('AlbumRepository: Exception occurred: $e');
      throw Exception(
        'Failed to load photos for album $albumId page $page: $e',
      );
    }
  }

  Future<Map<int, List<Photo>>> getPhotosForAlbums(
    List<Album> albums, {
    int photosPage = 1,
  }) async {
    print(
      'AlbumRepository: Getting photos for ${albums.length} albums (page $photosPage)',
    );
    final Map<int, List<Photo>> result = {};

    for (final album in albums) {
      try {
        print(
          'AlbumRepository: Loading photos for album ${album.id} page $photosPage - "${album.title}"',
        );
        final photos = await getPhotos(album.id, page: photosPage);
        result[album.id] = photos;
        print(
          'AlbumRepository: Loaded ${photos.length} photos for album ${album.id}',
        );
      } catch (e) {
        print(
          'AlbumRepository: Error loading photos for album ${album.id}: $e',
        );
        result[album.id] = [];
      }
    }

    print(
      'AlbumRepository: Completed loading photos for ${albums.length} albums',
    );
    return result;
  }

  // Helper method to check if there are more albums to load
  Future<bool> hasMoreAlbums(int currentPage) async {
    try {
      final nextPageAlbums = await getAlbums(page: currentPage + 1);
      return nextPageAlbums.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Helper method to check if there are more photos to load for an album
  Future<bool> hasMorePhotos(int albumId, int currentPage) async {
    try {
      final nextPagePhotos = await getPhotos(albumId, page: currentPage + 1);
      return nextPagePhotos.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

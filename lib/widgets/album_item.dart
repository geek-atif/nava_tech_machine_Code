import 'package:flutter/material.dart';
import '../models/album.dart';
import '../models/photo.dart';
import 'photo_item.dart';
import 'paginated_list.dart';

class AlbumItem extends StatefulWidget {
  final Album album;
  final List<Photo> photos;
  final VoidCallback? onLoadMorePhotos;
  final bool hasMorePhotos;
  final bool isLoadingMorePhotos;

  const AlbumItem({
    super.key,
    required this.album,
    required this.photos,
    this.onLoadMorePhotos,
    this.hasMorePhotos = false,
    this.isLoadingMorePhotos = false,
  });

  @override
  State<AlbumItem> createState() => _AlbumItemState();
}

class _AlbumItemState extends State<AlbumItem> {
  late ScrollController _photoScrollController;

  @override
  void initState() {
    super.initState();
    print(
      ' AlbumItem: Initializing album ${widget.album.id} - "${widget.album.title}" with ${widget.photos.length} photos',
    );
    _photoScrollController = ScrollController();
  }

  @override
  void dispose() {
    print(' AlbumItem: Disposing album ${widget.album.id}');
    _photoScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
      ' AlbumItem: Building album ${widget.album.id} - "${widget.album.title}"',
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album title
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.album.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // Horizontal scrolling photos with pagination
          _buildPhotoSection(),

          // Divider
          const Padding(
            padding: EdgeInsets.only(top: 16.0),
            child: Divider(thickness: 1, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    if (widget.photos.isNotEmpty) {
      print(
        ' AlbumItem: Building paginated photo list for album ${widget.album.id} with ${widget.photos.length} photos',
      );
      return PaginatedPhotoList(
        controller: _photoScrollController,
        height: 150,
        hasMore: widget.hasMorePhotos,
        isLoading: widget.isLoadingMorePhotos,
        onLoadMore: widget.onLoadMorePhotos,
        children:
            widget.photos
                .map(
                  (photo) => PhotoItem(photo: photo, width: 150, height: 150),
                )
                .toList(),
      );
    } else {
      print(' AlbumItem: No photos available for album ${widget.album.id}');
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'No photos available',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }
  }
}

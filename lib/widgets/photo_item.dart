import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/photo.dart';

class PhotoItem extends StatefulWidget {
  final Photo photo;
  final double? width;
  final double? height;

  const PhotoItem({super.key, required this.photo, this.width, this.height});

  @override
  State<PhotoItem> createState() => _PhotoItemState();
}

class _PhotoItemState extends State<PhotoItem> {
  static const String fallbackImageUrl =
      'https://dummyimage.com/250/ffffff/000000';
  bool _usesFallback = false;

  @override
  Widget build(BuildContext context) {
    final itemWidth = widget.width ?? 150;
    final itemHeight = widget.height ?? 150;

    return Container(
      width: itemWidth,
      height: itemHeight,
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey[400]!, width: 1.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: _buildImage(itemWidth, itemHeight),
      ),
    );
  }

  Widget _buildImage(double itemWidth, double itemHeight) {
    final imageUrl =
        _usesFallback ? fallbackImageUrl : widget.photo.thumbnailUrl;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: itemWidth,
      height: itemHeight,
      memCacheWidth: itemWidth.toInt(),
      memCacheHeight: itemHeight.toInt(),
      placeholder:
          (context, url) => Container(
            width: itemWidth,
            height: itemHeight,
            color: Colors.grey[300],
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      errorWidget: (context, url, error) {
        print('PhotoItem: Error loading image ${widget.photo.id}: $error');

        // If we haven't tried the fallback yet and the current URL is not the fallback
        if (!_usesFallback && imageUrl != fallbackImageUrl) {
          print(
            'PhotoItem: Trying fallback image for photo ${widget.photo.id}',
          );
          // Switch to fallback image on next rebuild
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _usesFallback = true;
              });
            }
          });

          // Show loading indicator while switching
          return Container(
            width: itemWidth,
            height: itemHeight,
            color: Colors.grey[300],
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        // Both original and fallback failed, show error icon
        print(
          'PhotoItem: Both original and fallback images failed for photo ${widget.photo.id}',
        );
        return Container(
          width: itemWidth,
          height: itemHeight,
          color: Colors.grey[300],
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                SizedBox(height: 4),
                Text(
                  'Image unavailable',
                  style: TextStyle(color: Colors.grey, fontSize: 10),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 200),
    );
  }
}

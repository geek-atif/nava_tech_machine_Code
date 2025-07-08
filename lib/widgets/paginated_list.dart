import 'package:flutter/material.dart';

class PaginatedList extends StatefulWidget {
  final List<Widget> children;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final Axis scrollDirection;
  final ScrollController? controller;
  final EdgeInsets? padding;

  const PaginatedList({
    super.key,
    required this.children,
    this.onLoadMore,
    this.hasMore = true,
    this.isLoading = false,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.padding,
  });

  @override
  State<PaginatedList> createState() => _PaginatedListState();
}

class _PaginatedListState extends State<PaginatedList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_scrollListener);
    print(' PaginatedList: Initializing with ${widget.children.length} items');
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_scrollListener);
    }
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * 0.8; // Load more when 80% scrolled

    if (currentScroll >= threshold &&
        widget.hasMore &&
        !widget.isLoading &&
        widget.onLoadMore != null) {
      print(' PaginatedList: Reached 80% scroll, loading more data');
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    print(' PaginatedList: Building with ${widget.children.length} items');

    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      itemCount: widget.children.length + (widget.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < widget.children.length) {
          return widget.children[index];
        } else {
          // Loading indicator at the end
          return _buildLoadingIndicator();
        }
      },
    );
  }

  Widget _buildLoadingIndicator() {
    if (!widget.hasMore) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child:
          widget.isLoading
              ? const CircularProgressIndicator()
              : const SizedBox.shrink(),
    );
  }
}

class PaginatedPhotoList extends StatefulWidget {
  final List<Widget> children;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoading;
  final double height;
  final ScrollController? controller;

  const PaginatedPhotoList({
    super.key,
    required this.children,
    this.onLoadMore,
    this.hasMore = true,
    this.isLoading = false,
    required this.height,
    this.controller,
  });

  @override
  State<PaginatedPhotoList> createState() => _PaginatedPhotoListState();
}

class _PaginatedPhotoListState extends State<PaginatedPhotoList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_scrollListener);
    print(
      ' PaginatedPhotoList: Initializing with ${widget.children.length} photos',
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_scrollListener);
    }
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final threshold = maxScroll * 0.8; // Load more when 80% scrolled

    if (currentScroll >= threshold &&
        widget.hasMore &&
        !widget.isLoading &&
        widget.onLoadMore != null) {
      print(' PaginatedPhotoList: Reached 80% scroll, loading more photos');
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      ' PaginatedPhotoList: Building with ${widget.children.length} photos',
    );

    if (widget.children.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return SizedBox(
      height: widget.height,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.children.length + (widget.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < widget.children.length) {
            return widget.children[index];
          } else {
            // Loading indicator at the end
            return _buildLoadingIndicator();
          }
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    if (!widget.hasMore) return const SizedBox.shrink();

    return Container(
      width: 60,
      padding: const EdgeInsets.all(16.0),
      alignment: Alignment.center,
      child:
          widget.isLoading
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const SizedBox.shrink(),
    );
  }
}

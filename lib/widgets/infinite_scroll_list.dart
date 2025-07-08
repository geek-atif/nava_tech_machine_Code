import 'package:flutter/material.dart';

class InfiniteScrollList extends StatefulWidget {
  final List<Widget> children;
  final Axis scrollDirection;
  final ScrollController? controller;
  final double? itemExtent;
  final EdgeInsets? padding;

  const InfiniteScrollList({
    super.key,
    required this.children,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.itemExtent,
    this.padding,
  });

  @override
  State<InfiniteScrollList> createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<InfiniteScrollList> {
  late ScrollController _scrollController;
  static const int _repetitions = 100; // Reduced from 10000 to prevent ANR

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    print(
      'InfiniteScrollList: Initializing with ${widget.children.length} items',
    );

    // Start at the middle position to allow scrolling in both directions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.children.isNotEmpty && _scrollController.hasClients) {
        final double initialOffset = _getInitialOffset();
        print('InfiniteScrollList: Setting initial offset to $initialOffset');
        _scrollController.jumpTo(initialOffset);
      }
    });
  }

  double _getInitialOffset() {
    if (widget.children.isEmpty) return 0.0;

    // Calculate middle position
    final int totalItems = widget.children.length * _repetitions;
    final int middleIndex = (totalItems / 2).floor();

    if (widget.itemExtent != null) {
      return middleIndex * widget.itemExtent!;
    }

    // Estimate based on average item height/width
    final double estimatedItemSize =
        widget.scrollDirection == Axis.vertical ? 200.0 : 150.0;
    return middleIndex * estimatedItemSize;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
      ' InfiniteScrollList: Building with ${widget.children.length} unique items',
    );

    if (widget.children.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      controller: _scrollController,
      scrollDirection: widget.scrollDirection,
      padding: widget.padding,
      itemCount: widget.children.length * _repetitions,
      itemExtent: widget.itemExtent,
      itemBuilder: (context, index) {
        final int actualIndex = index % widget.children.length;
        return widget.children[actualIndex];
      },
    );
  }
}

class InfiniteScrollPhotoList extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final double height;

  const InfiniteScrollPhotoList({
    super.key,
    required this.children,
    this.controller,
    required this.height,
  });

  @override
  State<InfiniteScrollPhotoList> createState() =>
      _InfiniteScrollPhotoListState();
}

class _InfiniteScrollPhotoListState extends State<InfiniteScrollPhotoList> {
  late ScrollController _scrollController;
  static const int _repetitions = 100; // Reduced from 10000 to prevent ANR

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    print(
      ' InfiniteScrollPhotoList: Initializing with ${widget.children.length} photos',
    );

    // Start at the middle position to allow scrolling in both directions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.children.isNotEmpty && _scrollController.hasClients) {
        final double initialOffset = _getInitialOffset();
        print(
          ' InfiniteScrollPhotoList: Setting initial offset to $initialOffset',
        );
        _scrollController.jumpTo(initialOffset);
      }
    });
  }

  double _getInitialOffset() {
    if (widget.children.isEmpty) return 0.0;

    // Calculate middle position
    final int totalItems = widget.children.length * _repetitions;
    final int middleIndex = (totalItems / 2).floor();

    // Estimate based on photo item width (150px + margin)
    const double estimatedItemWidth = 158.0; // 150 + 8 margin
    return middleIndex * estimatedItemWidth;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
      ' InfiniteScrollPhotoList: Building with ${widget.children.length} unique photos',
    );

    if (widget.children.isEmpty) {
      return SizedBox(height: widget.height);
    }

    return SizedBox(
      height: widget.height,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.children.length * _repetitions,
        itemBuilder: (context, index) {
          final int actualIndex = index % widget.children.length;
          return widget.children[actualIndex];
        },
      ),
    );
  }
}

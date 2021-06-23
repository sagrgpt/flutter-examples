import 'dart:math';

import 'package:flutter/material.dart';
import 'package:interactive_list/repository/dog_repo.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../models/models.dart';
import 'indexed_scrollable_playlist_bloc.dart';

class ScrollPositionedListWidget extends StatefulWidget {
  ScrollPositionedListWidget({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _ScrollPositionedListWidgetState createState() =>
      _ScrollPositionedListWidgetState();
}

class _ScrollPositionedListWidgetState
    extends State<ScrollPositionedListWidget> {
  IndexedScrollablePlaylistBloc _bloc;
  final scrollListener = ItemPositionsListener.create();
  List<double> itemHeights;

  @override
  void initState() {
    super.initState();
    final heightGenerator = Random();
    itemHeights = List<double>.generate(
      4,
      (int _) => heightGenerator.nextDouble() * (250 - 100) + 100,
    );
    _bloc = IndexedScrollablePlaylistBloc(
      Playlist(),
      ItemScrollController(),
      DogRepo(),
    );
    _bloc.itemEventSink.add(InitializePlaylist());
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("asdasd "),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            videoView(),
            playlistView(),
            positionView,
          ],
        ),
      ),
    );
  }

  Widget videoView() {
    return Stack(
      children: [
        StreamBuilder(
          stream: _bloc.currentItem,
          initialData: _bloc.initialCurrentItem,
          builder: (context, snapshot) {
            final String imageUrl = snapshot.data;
            return Container(
              alignment: Alignment.center,
              height: 200.0,
              child: getSimpleImageView(imageUrl),
            );
          },
        ),
        Container(
          height: 200.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: 'prevButton',
                onPressed: () => _bloc.itemEventSink.add(PlayPrevious()),
                backgroundColor: Colors.green,
                mini: true,
                child: Text("Pre"),
              ),
              const SizedBox(),
              FloatingActionButton(
                heroTag: 'nextButton',
                onPressed: () => _bloc.itemEventSink.add(PlayNext()),
                backgroundColor: Colors.green,
                mini: true,
                child: Text("Next"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget playlistView() {
    return Expanded(
      child: StreamBuilder<Playlist>(
          stream: _bloc.playlistUpdates,
          initialData: _bloc.initialPlaylist,
          builder: (context, snapshot) {
            return ScrollablePositionedList.builder(
              itemScrollController: _bloc.controller,
              itemCount: snapshot.data.length,
              itemPositionsListener: scrollListener,
              itemBuilder: (context, index) {
                final String imageUrl = snapshot.data[index];
                final isSelectedContainer =
                    snapshot.data.selectedIndex == index;
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 2),
                  color: Colors.grey,
                  child: GestureDetector(
                    onTap: () => _bloc.itemEventSink.add(ItemSelected(index)),
                    child: isSelectedContainer
                        ? getSelectedImageView(imageUrl)
                        : getSimpleImageView(imageUrl),
                  ),
                );
              },
            );
          }),
    );
  }

  Widget getSimpleImageView(String imageUrl) {
    return imageUrl.isNotEmpty
        ? Image.network(imageUrl, fit: BoxFit.fill)
        : SizedBox();
  }

  Widget getSelectedImageView(String imageUrl) {
    if (imageUrl.isEmpty) return SizedBox();

    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        backgroundBlendMode: BlendMode.color,
        color: Colors.grey,
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.fill,
      ),
    );
  }

  Widget get positionView => ValueListenableBuilder<Iterable<ItemPosition>>(
        valueListenable: scrollListener.itemPositions,
        builder: (context, positions, child) {
          int min;
          int max;
          if (positions.isNotEmpty) {
            // Determine the first visible item by finding the item with the
            // smallest trailing edge that is greater than 0.  i.e. the first
            // item whose trailing edge in visible in the viewport.
            min = positions
                .where((ItemPosition position) => position.itemTrailingEdge > 0)
                .reduce((ItemPosition min, ItemPosition position) =>
                    position.itemTrailingEdge < min.itemTrailingEdge
                        ? position
                        : min)
                .index;
            // Determine the last visible item by finding the item with the
            // greatest leading edge that is less than 1.  i.e. the last
            // item whose leading edge in visible in the viewport.
            max = positions
                .where((ItemPosition position) => position.itemLeadingEdge < 1)
                .reduce((ItemPosition max, ItemPosition position) =>
                    position.itemLeadingEdge > max.itemLeadingEdge
                        ? position
                        : max)
                .index;
          }
          _bloc.itemEventSink.add(ListScrolled(min, max));
          return const SizedBox();
        },
      );
}

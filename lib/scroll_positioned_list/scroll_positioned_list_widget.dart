
import 'package:flutter/material.dart';
import 'package:interactive_list/repository/dog_repo.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

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
  final scrollDirection = Axis.vertical;

  @override
  void initState() {
    super.initState();
    _bloc = IndexedScrollablePlaylistBloc(
      Playlist(),
      AutoScrollController(axis: scrollDirection),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            videoView(),
            playlistView(),
          ],
        ),
      ),
    );
  }

  Widget videoView() {
    return Stack(
      key: Key("video_view"),
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
                key: Key('btn_previous'),
                heroTag: 'prevButton',
                onPressed: () => _bloc.itemEventSink.add(PlayPrevious()),
                backgroundColor: Colors.green,
                mini: true,
                child: Text("Pre"),
              ),
              const SizedBox(),
              FloatingActionButton(
                key: Key('btn_next'),
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
            return ListView.builder(
              itemBuilder: (context, index) {
                final String imageUrl = snapshot.data[index];
                final isSelectedContainer =
                    snapshot.data.selectedIndex == index;
                return AutoScrollTag(
                  key: ValueKey(index),
                  index: index,
                  controller: _bloc.controller,
                  child: Container(
                    key: Key('list_item_$index'),
                    margin: EdgeInsets.symmetric(vertical: 2),
                    color: Colors.grey,
                    child: GestureDetector(
                      onTap: () => _bloc.itemEventSink.add(ItemSelected(index)),
                      child: isSelectedContainer
                          ? getSelectedImageView(imageUrl)
                          : getSimpleImageView(imageUrl),
                    ),
                  ),
                );
              },
              scrollDirection: scrollDirection,
              controller: _bloc.controller,
            );
/*
            return ScrollablePositionedList.builder(
              key: Key('dynamic_height_list'),
              // itemScrollController: _bloc.controller,
              itemCount: snapshot.data.length,
              itemPositionsListener: scrollListener,
              itemBuilder: (context, index) {
                final String imageUrl = snapshot.data[index];
                final isSelectedContainer =
                    snapshot.data.selectedIndex == index;
                return Container(
                  key: Key('list_item_$index'),
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
*/
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
}

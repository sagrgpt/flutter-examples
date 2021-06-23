import 'package:flutter/material.dart';
import 'package:interactive_list/repository/dog_repo.dart';

import '../models/models.dart';
import 'static_height_playlist_bloc.dart';

const ITEM_HEIGHT = 200.0;

class StaticHeightListWidget extends StatefulWidget {
  StaticHeightListWidget({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _StaticHeightListWidgetState createState() => _StaticHeightListWidgetState();
}

class _StaticHeightListWidgetState extends State<StaticHeightListWidget> {
  // List<String> _playList;
  StaticHeightPlaylistBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = StaticHeightPlaylistBloc(
      Playlist(),
      ScrollController(initialScrollOffset: ITEM_HEIGHT),
      DogRepo(),
      ITEM_HEIGHT,
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
      /*appBar: AppBar(
        title: Text(widget.title),
      ),*/
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
      children: [
        StreamBuilder<String>(
          stream: _bloc.currentItem,
          initialData: _bloc.initialCurrentItem,
          builder: (context, snapshot) {
            final String imageUrl = snapshot.data;
            return Container(
              alignment: Alignment.center,
              height: ITEM_HEIGHT,
              child: getSimpleImageView(imageUrl),
            );
          },
        ),
        Container(
          height: ITEM_HEIGHT,
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
            return ListView.builder(
              controller: _bloc.scrollController,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                final String imageUrl = snapshot.data[index];
                final isSelectedContainer =
                    snapshot.data.selectedIndex == index;
                return Container(
                  height: ITEM_HEIGHT - 4,
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
}

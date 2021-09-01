import 'dart:async';

import 'package:interactive_list/models/errors.dart';
import 'package:interactive_list/repository/dog_repo.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../models/models.dart';

const EOF_THRESHOLD = 4;

class IndexedScrollablePlaylistBloc {
  IndexedScrollablePlaylistBloc(
    this._playlist,
    this.controller,
    this.repo,
  ) {
    _eventStreamController.stream.listen((_mapEventToState));
  }

  final Playlist _playlist;
  final AutoScrollController controller;
  final DogRepo repo;
  int _lastVisibleIndex;
  var _repoLock = false;

  //Current Item Stream
  final _currentItemStreamController = StreamController<String>();

  StreamSink<String> get _inCurrentItem => _currentItemStreamController.sink;

  //Playlist Stream
  final _playlistStreamController = StreamController<Playlist>();

  StreamSink<Playlist> get _inPlaylist => _playlistStreamController.sink;

  //Event Stream
  final _eventStreamController = StreamController<PlaylistEvent>();

  Stream<String> get currentItem => _currentItemStreamController.stream;

  String get initialCurrentItem => '';

  Playlist get initialPlaylist => _playlist;

  Sink<PlaylistEvent> get itemEventSink => _eventStreamController.sink;

  Stream<Playlist> get playlistUpdates => _playlistStreamController.stream;

  void dispose() {
    _currentItemStreamController.close();
    _eventStreamController.close();
    _playlistStreamController.close();
  }

  void _mapEventToState(PlaylistEvent event) {
    if (event is InitializePlaylist)
      _handlePlaylistInitialization();
    else if (event is ItemSelected) {
      _handleNewItemSelected(event.index);
    } else if (event is PlayPrevious) {
      _handlePreviousItemSelected();
    } else if (event is PlayNext) {
      _handleNextItemSelected();
    } else if (event is ListScrolled) {
      _handleScrollingOfList(event);
    }
  }

  void _handlePlaylistInitialization() async {
    await _fetchMoreItem();
    _playlist.selectedIndex = 0;
    _inPlaylist.add(_playlist);
    _inCurrentItem.add(_playlist.first);
    Timer(Duration(milliseconds: 100), () => _jumpTo(1));
  }

  void _handleNewItemSelected(int index) {
    assert(index < _playlist.length);
    _playlist.selectedIndex = index;
    _inPlaylist.add(_playlist);
    _inCurrentItem.add(_playlist.selected);
    if (_isIndexCloseToEnd(_playlist.selectedIndex)) {
      _handleLastItemReached();
    }
    _handleScrollOnItemSelect();
  }

  void _handleScrollingOfList(ListScrolled scrollData) {
    _lastVisibleIndex = scrollData.maxVisibleIndex;
    if (_isEndOfList) {
      _handleLastItemReached();
    }
  }

  void _handlePreviousItemSelected() {
    if (_playlist.selectedIndex == 0) return;
    _handleNewItemSelected(_playlist.selectedIndex - 1);
  }

  void _handleNextItemSelected() {
    _handleNewItemSelected(_playlist.selectedIndex + 1);
  }

  void _handleLastItemReached() async {
    await _fetchMoreItem();
    _inPlaylist.add(_playlist);
  }

  void _handleScrollOnItemSelect() {
    _scrollTo(_playlist.selectedIndex + 1);
  }

  void _scrollTo(int index) {
    controller.scrollToIndex(
      index,
      duration: Duration(milliseconds: 300),
      preferPosition: AutoScrollPosition.begin
    );
  }

  void _jumpTo(double index) {
    controller.jumpTo(index);
  }

  Future _fetchMoreItem() async {
    if (_repoLock) return;

    _repoLock = true;
    print("fetching next list of items");
    try{
      final List<String> items = await repo.fetchItem();
      _playlist.addAll(items);
    }on NetworkException {
      print('Failed to load new items');
    }finally {
      _repoLock = false;
    }
  }

  bool get _isEndOfList {
    return (_playlist.length != 0) &&
        (_lastVisibleIndex == _playlist.length - 1);
  }

  bool _isIndexCloseToEnd(int index) {
    return index + 1 >= _playlist.length - EOF_THRESHOLD;
  }
}

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:interactive_list/models/errors.dart';
import 'package:interactive_list/repository/dog_repo.dart';
import '../models/models.dart';

const EOF_THRESHOLD = 4;

class StaticHeightPlaylistBloc {
  final Playlist _playlist;
  final ScrollController scrollController;
  final double listItemHeight;
  final DogRepo repo;

  StaticHeightPlaylistBloc(
    this._playlist,
    this.scrollController,
    this.repo,
    this.listItemHeight,
  )   : assert(_playlist != null),
        assert(scrollController != null) {
    _eventStreamController.stream.listen(_mapEventToState);
  }

  //Current Item Stream
  final _currentItemStreamController = StreamController<String>();

  StreamSink<String> get _inCurrentItem => _currentItemStreamController.sink;

  Stream<String> get currentItem => _currentItemStreamController.stream;

  String get initialCurrentItem => '';

  //Playlist Stream
  final _playlistStreamController = StreamController<Playlist>();

  StreamSink<Playlist> get _inPlaylist => _playlistStreamController.sink;

  Stream<Playlist> get playlistUpdates => _playlistStreamController.stream;

  Playlist get initialPlaylist => _playlist;
  var _repoLock = false;

  //Event Stream
  final _eventStreamController = StreamController<PlaylistEvent>();

  Sink<PlaylistEvent> get itemEventSink => _eventStreamController.sink;

  void _mapEventToState(PlaylistEvent event) {
    if (event is InitializePlaylist)
      _handlePlaylistInitialization();
    else if (event is ItemSelected) {
      _handleNewItemSelected(event.index);
    } else if (event is PlayPrevious) {
      _handlePreviousItemSelected();
    } else if (event is PlayNext) {
      _handleNextItemSelected();
    }
  }

  void _handlePlaylistInitialization() async {
    print('fetching initial list of item');
    await _fetchMoreItem();
    _playlist.selectedIndex = 0;
    _inPlaylist.add(_playlist);
    _inCurrentItem.add(_playlist.first);
    _jumpTo(_playlist.selectedIndex + 1);
    scrollController.addListener(_monitorItemScroll);
  }

  void _handlePreviousItemSelected() {
    if (_playlist.selectedIndex == 0) return;
    _handleNewItemSelected(_playlist.selectedIndex - 1);
  }

  void _handleNextItemSelected() {
    _handleNewItemSelected(_playlist.selectedIndex + 1);
  }

  void _handleNewItemSelected(int selectedIndex) {
    assert(selectedIndex < _playlist.length);
    _playlist.selectedIndex = selectedIndex;
    _inPlaylist.add(_playlist);
    _inCurrentItem.add(_playlist.selected);
    if (_isIndexCloseToEnd(_playlist.selectedIndex)) {
      _handleLastItemReached();
    }
    _handleScrollOnItemSelect();
  }

  void _handleLastItemReached() async {
    await _fetchMoreItem();
    _inPlaylist.add(_playlist);
  }

  void _handleScrollOnItemSelect() {
    _scrollTo(_playlist.selectedIndex + 1);
  }

  Future _fetchMoreItem() async {
    if (_repoLock) return;

    _repoLock = true;
    print("fetching next list of items");
    try {
      final List<String> items = await repo.fetchItem();
      _playlist.addAll(items);
    } on NetworkException {
      print('Failed to load new items');
    } finally {
      _repoLock = false;
    }
  }

  void _monitorItemScroll() {
    if (_isEndOfList) {
      _handleLastItemReached();
    }
  }

  void _scrollTo(int index) {
    scrollController.animateTo(
      index * listItemHeight,
      duration: Duration(milliseconds: 300),
      curve: Curves.decelerate,
    );
  }

  void _jumpTo(int index) {
    scrollController.jumpTo(index * listItemHeight);
  }

  bool get _isEndOfList {
    return (scrollController.position.pixels !=
            scrollController.position.minScrollExtent) &&
        (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent);
  }

  bool _isIndexCloseToEnd(int index) {
    return index + 1 >= _playlist.length - EOF_THRESHOLD;
  }

  void dispose() {
    _currentItemStreamController.close();
    _eventStreamController.close();
    _playlistStreamController.close();
    scrollController.dispose();
  }
}

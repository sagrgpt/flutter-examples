abstract class PlaylistEvent {}

class ItemSelected extends PlaylistEvent {
  ItemSelected(this.index);

  final int index;
}

class InitializePlaylist extends PlaylistEvent {}

class PlayNext extends PlaylistEvent {}

class PlayPrevious extends PlaylistEvent {}

class ListScrolled extends PlaylistEvent {
  ListScrolled(
    this.minVisibleIndex,
    this.maxVisibleIndex,
  );

  final int maxVisibleIndex;
  final int minVisibleIndex;
}

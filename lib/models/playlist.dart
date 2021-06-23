class Playlist {
  final _dataset = List<String>();
  int selectedIndex = -1;

  String get first => length > 0 ? _dataset.first : '';

  int get length => _dataset.length;

  String get selected {
    assert(selectedIndex < _dataset.length);
    return _dataset[selectedIndex];
  }

  String operator [](int index) {
    assert(index < _dataset.length);
    return _dataset[index];
  }

  void add(String value) {
    _dataset.add(value);
  }

  void addAll(Iterable<String> items) {
    _dataset.addAll(items);
  }
}

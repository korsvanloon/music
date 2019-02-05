import 'dart:html';
import 'package:music/music_util.dart';
import 'package:music/state.dart';
import 'package:rxdart/rxdart.dart';

class ToneView {
  ToneView() {
    element.children = [
      Element.header()..text = 'Notes',
      DivElement()
        ..children = [
          _notesContainer
            ..className = 'notes'
            ..children = List.generate(25, (i) => DivElement()),
        ],
    ];

    store.tonic$.listen(update);
  }
  final HtmlElement element = Element.article();

  Observable<int> get note$ => Observable(_notesContainer.onClick)
      .map((e) => _notesContainer.children.indexOf(e.target as Element) - 12);

  void update(Tonic tonic) {
    final notes = Tonic.all
        .skipWhile((k) => k != tonic)
        .followedBy(Tonic.all.takeWhile((k) => k != tonic))
        .toList();

    for (var i = 0; i < _notesContainer.children.length; i++) {
      final note = notes[i % 12];
      _notesContainer.children[i]
        ..text = note.name
        ..style.backgroundColor = 'hsla(${hsl(note.name).h}, 80%, 70%, 1)';
    }
  }

  final _notesContainer = DivElement();
}

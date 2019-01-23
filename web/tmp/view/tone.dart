import 'dart:html';
import 'package:rxdart/rxdart.dart';

import '../instrument/instrument.dart';
import '../music_util.dart';

class ToneView {
  final HtmlElement element = Element.article();

  Observable<int> get note$ => Observable(_notesContainer.onClick)
      .map((e) => _notesContainer.children.indexOf(e.target as Element) - 12);

  ToneView(Stream<MasterData> master$) {
    element
      ..append(Element.header()..text = 'Notes')
      ..append(DivElement()
        ..append(_notesContainer
          ..className = 'notes'
          ..children = List.generate(25, (i) => DivElement())));

    master$.listen(update);
  }

  void update(MasterData master) {
    final notes = Note.all
        .skipWhile((k) => k != master.baseNote)
        .followedBy(Note.all.takeWhile(((k) => k != master.baseNote)))
        .toList();

    for (var i = 0; i < _notesContainer.children.length; i++) {
      final note = notes[i % 12];
      _notesContainer.children[i]
        ..text = note.name
        ..style.backgroundColor = 'hsla(${hsl(note.name).h}, 80%, 70%, 1)';
    }
  }

  MasterData _master;
  final _notesContainer = DivElement();
}

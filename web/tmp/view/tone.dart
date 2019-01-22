import 'dart:html';
import 'package:rxdart/rxdart.dart';

import '../music_util.dart';

class ToneView {
  final HtmlElement element = Element.article();
  Observable<Note> get note$ => Observable(_notesContainer.onClick)
      .map((e) => e.target as HtmlElement)
      .map((e) => Note.all.firstWhere((n) => n.name == e.text));

  ToneView() {
    final keyElements = Note.all
        .map((n) => DivElement()
          ..text = n.name
          ..style.backgroundColor = 'hsla(${hsl(n.name).h}, 100%, 50%, .5)')
        .toList();

    element
      ..append(Element.header()..text = 'Notes')
      ..append(DivElement()
        ..append(_notesContainer
          ..className = 'notes'
          ..children = keyElements));
  }

  void setBaseNote(Note note) {
    final noteElement =
        _notesContainer.children.firstWhere((c) => c.text == note.name);
    final newOrder = _notesContainer.children
        .skipWhile((k) => k != noteElement)
        .followedBy(
            _notesContainer.children.takeWhile(((k) => k != noteElement)));
    _notesContainer.children = newOrder.toList();
    _notesContainer.style.backgroundColor = noteElement.style.backgroundColor;
  }

  final _notesContainer = DivElement();
}

import 'dart:async';
import 'dart:html';

import 'package:rxdart/rxdart.dart';

import '../element_util.dart';

class MetronomeView {
  Observable<int> get resolution$ => Observable(_resolutionSelect.onChange)
      .map((e) => (e.target as SelectElement).selectedIndex)
      .startWith(_resolutionSelect.selectedIndex);

  final HtmlElement element = Element.article();

  MetronomeView() {
    // _thing.style.transition = 'ease-out width .1s';
    _thing.style.width = '10px';
    _thing.style.height = '10px';

    element
      ..append(Element.header()..appendText('Metronome'))
      ..append(selectControl(
        _resolutionSelect,
        label: 'Resolution',
        options: ['16th notes', '8th notes', '4th notes'],
      ))
      ..append(DivElement()..append(_thing));
  }

  void draw(int currentNote) {
    print(currentNote);
    _thing.style.backgroundColor = currentNote == 0
        ? 'red'
        : currentNote % 4 == 0
            ? 'blue'
            : currentNote % 2 == 0 ? 'black' : 'black';
    final factor = currentNote == 0 ? 2.0 : currentNote % 4 == 0 ? 1.0 : 0.5;
    _thing.style.width = '${factor * 20}px';
  }

  final DivElement _thing = DivElement();
  final SelectElement _resolutionSelect = SelectElement()
    ..id = 'metronome_resolution';
}
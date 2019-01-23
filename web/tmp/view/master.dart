import 'dart:html';
import 'package:rxdart/rxdart.dart';
import '../element_util.dart';
import '../music_util.dart';
import '../instrument/instrument.dart';

class MasterView {
  Observable<MasterData> get master$ {
    return Observable.combineLatest3(
        Observable(_baseFrequencySelect.onChange)
            .map((e) => (e.target as SelectElement).selectedIndex)
            .startWith(_baseFrequencySelect.selectedIndex)
            .map((i) => Note.all[i]),
        Observable(_bpmInput.onInput)
            .map((e) => (e.target as InputElement).valueAsNumber)
            .startWith(_bpmInput.valueAsNumber),
        Observable(_playButton.onClick)
            .scan((p, e, i) => !p, false)
            .startWith(false),
        (n, b, p) => MasterData(baseNote: n, bpm: b, isPlaying: p));
  }

  final HtmlElement element = Element.article();

  MasterView() {
    final bpmLabel = Text('120');

    element
      ..append(Element.header()..appendText('Master'))
      ..append(DivElement()..append(_playButton..className = 'play'))
      ..append(DivElement()
        ..className = 'control'
        ..append(LabelElement()
          ..htmlFor = _bpmInput.id
          ..appendText('Tempo ')
          ..append(bpmLabel)
          ..appendText(' bpm'))
        ..append(_bpmInput
          ..min = '30.0'
          ..max = '160.0'
          ..step = '1'
          ..value = '120'))
        ..append(selectControl(_baseFrequencySelect, label: 'Base Note', options: noteNames));

    master$.listen((m) {
      _playButton.text = m.isPlaying ? 'stop' : 'play';
      bpmLabel.text = m.bpm.toString();
    });
  }

  final _playButton = ButtonElement();
  final _bpmInput = RangeInputElement()..id = 'master_bpm_range';
  final _baseFrequencySelect = SelectElement()..id = 'master_frequency';
}

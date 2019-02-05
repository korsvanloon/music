import 'dart:html';
import 'package:music/element_util.dart';
import 'package:music/music_util.dart';
import 'package:music/state.dart';
import 'package:rxdart/rxdart.dart';

class MasterView {
  Observable<Tonic> get tonic$ => Observable(_baseFrequencySelect.onChange)
      .map((e) => (e.target as SelectElement).selectedIndex)
      // .startWith(_baseFrequencySelect.selectedIndex)
      .map((i) => Tonic.all[i]);
  Observable<int> get bpm$ => Observable(_bpmInput.onInput)
          .map((e) => (e.target as InputElement).valueAsNumber.toInt())
      // .startWith(_bpmInput.valueAsNumber.toInt())
      ;
  Stream<bool> get toggle$ =>
      createToggle$(_playButton, offChild: Text('▶'), onChild: Text('■'));

  Stream<Section> get currentSection$ => Observable(_sectionSelect.onChange)
      .map((e) => (e.target as SelectElement).selectedIndex)
      // .startWith(_sectionSelect.selectedIndex)
      .map((i) => store.state.song.sections.list.toList()[i]);

  final HtmlElement element = Element.article();

  MasterView() {
    element
      ..append(Element.header()..appendText('Master'))
      ..append(DivElement()..append(_playButton..className = 'play'))
      ..append(DivElement()
        ..className = 'control'
        ..append(LabelElement()
          ..htmlFor = _bpmInput.id
          ..appendText('Tempo ')
          ..append(_bpmLabel)
          ..appendText(' bpm'))
        ..append(_bpmInput
          ..min = '30.0'
          ..max = '160.0'
          ..step = '1'))
      ..append(selectControl(_baseFrequencySelect,
          label: 'Base Note', options: noteNames))
      ..append(selectControl(_sectionSelect, label: 'Section'));

    store.song$.listen(_updateSong);

    bpm$.listen((e) => _bpmLabel.text = e.toString());
  }

  _updateSong(SongData value) {
    _bpmLabel.text = value.bpm.toString();
    _bpmInput.value = value.bpm.toString();
    _baseFrequencySelect.value = value.tonic.name;
    _sectionSelect
      ..children = value.sections.list
          .map((o) => OptionElement(value: o.name, data: o.name))
          .toList()
      ..value = value.sections.first.name;
  }

  final _bpmLabel = Text('120');
  final _playButton = ButtonElement();
  final _bpmInput = RangeInputElement()..id = 'master_bpm_range';
  final _baseFrequencySelect = SelectElement()..id = 'master_frequency';
  final _sectionSelect = SelectElement()..id = 'master_section';
}

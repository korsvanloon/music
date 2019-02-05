import 'dart:convert';
import 'dart:html';

import 'package:music/element_util.dart';
import 'package:music/instrument/instrument.dart';
import 'package:music/music_util.dart';
import 'package:rxdart/rxdart.dart';

class MetronomeView extends Schedulable {
  MetronomeView(this._animationFrame$) {
    // _thing.style.transition = 'ease-out width .1s';
    _thing.style
      ..width = '10px'
      ..height = '10px';

    element
      ..append(Element.header()..appendText('Metronome'))
      ..append(selectControl(
        _resolutionSelect,
        label: 'Resolution',
        options: _rhythms.keys,
      ))
      ..append(selectControl(_soundSelect, label: 'Sound', options: _fileNames))
      ..append(DivElement()..append(_thing));
  }
  Observable<Rhythm> get resolution$ => Observable(_resolutionSelect.onChange)
      .map((e) => (e.target as SelectElement).value)
      .startWith(_resolutionSelect.value)
      .map((e) => _rhythms[e]);

  Observable<Wave> get wave$ => Observable(_soundSelect.onChange)
      .map((e) => (e.target as SelectElement).value)
      .startWith(_soundSelect.value)
      .asyncMap((e) => HttpRequest.getString('wave-tables/$e.json'))
      .map((s) => Wave.fromMap(json.decode(s)));

  final HtmlElement element = Element.article();

  @override
  void schedule(MeasureWindow window) {
    var i = 0;
    _animationFrame$
        .skipWhile((n) => n <= window.start)
        .takeWhile((n) => n <= window.end)
        .listen((n) {
      final beat = window.start + i * (window.duration / 16);
      if (n <= beat) {
        return;
      }
      _draw(i++);
    });
  }

  void _draw(int currentNote) {
    _thing.style.backgroundColor =
        currentNote == 0 ? 'red' : currentNote % 4 == 0 ? 'blue' : 'black';
    final factor = currentNote == 0 ? 2.0 : currentNote % 4 == 0 ? 1.0 : 0.5;
    _thing.style.width = '${factor * 20}px';
  }

  final Stream<num> _animationFrame$;
  static const _rhythms = {
    'onBeat': Rhythm.onBeat,
    'doubled': Rhythm.doubled,
    'continous': Rhythm.continous,
    'gallop': Rhythm.gallop,
    'fullOn': Rhythm.fullOn,
    'offBeat': Rhythm.offBeat,
  };
  final DivElement _thing = DivElement();
  final SelectElement _resolutionSelect = SelectElement()
    ..id = 'metronome_resolution';
  final SelectElement _soundSelect = SelectElement()..id = 'metronome_sound';
}

const _fileNames = [
  'Brass',
  'BritBlues',
  'BritBluesDriven',
  'Buzzy1',
  'Buzzy2',
  'Celeste',
  'ChorusStrings',
  'Dissonant1',
  'Dissonant2',
  'DissonantPiano',
  'DroppedSaw',
  'DroppedSquare',
  'DynaEPBright',
  'DynaEPMed',
  'Ethnic33',
  'Full1',
  'Full2',
  'GuitarFuzz',
  'Harsh',
  'MklHard',
  'Noise',
  'Organ2',
  'Organ3',
  'PhonemeAh',
  'PhonemeBah',
  'PhonemeEe',
  'PhonemeO',
  'PhonemeOoh',
  'PhonemePopAhhhs',
  'Piano',
  'Pulse',
  'PutneyWavering',
  'Saw',
  'Square',
  'TB303Square',
  'Throaty',
  'Triangle',
  'Trombone',
  'TwelveOpTines',
  'TwelveStringGuitar1',
  'WarmSaw',
  'WarmSquare',
  'WarmTriangle',
  'Wurlitzer',
  'Wurlitzer2',
];

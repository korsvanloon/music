import 'dart:convert';
import 'dart:html';
import 'dart:web_audio';

import 'package:music/element_util.dart';
import 'package:music/instrument/instrument.dart';
import 'package:music/music_util.dart';
import 'package:music/state.dart';
import 'package:rxdart/rxdart.dart';

class Bass extends Schedulable {
  Bass(this._context)
      : _gain = _context.createGain()..connectNode(_context.destination) {
    element
      ..append(Element.header()..appendText('Bass'))
      ..append(selectControl(
        _resolutionSelect,
        label: 'Rhythm',
        // defaultValue: _rhythms.first.name,
        options: _rhythms.keys,
      ))
      ..append(
          selectControl(_soundSelect, label: 'Sound', options: _fileNames));

    Observable(_soundSelect.onChange)
        .map((e) => (e.target as SelectElement).value)
        .startWith(_soundSelect.value)
        .asyncMap((e) => HttpRequest.getString('wave-tables/$e.json'))
        .map((s) => Wave.fromMap(json.decode(s)))
        .listen((w) => _wave = w);

    Observable(_resolutionSelect.onChange)
        .map((e) => (e.target as SelectElement).value)
        .startWith(_resolutionSelect.value)
        .map((e) => _rhythms[e])
        .listen((r) => _rhythm = r);
  }
  final HtmlElement element = Element.article();

  void _playNote(RelativeNote note, double time) {
    _gain.gain.setValueAtTime(0, time);
    _gain.gain.linearRampToValueAtTime(1, time + 0.05);
    _context.createOscillator()
      ..connectNode(_gain)
      ..frequency.value = note.asFrequency(store.state.tonic.baseFrequency)
      ..setPeriodicWave(_context.createPeriodicWave(_wave.real, _wave.imag))
      ..start2(time)
      ..stop(time + note.length);
  }

  @override
  void schedule(MeasureWindow window) {
    const bassOctave = -2;
    final currentSection = store.state.currentSection;

    for (final h in _rhythm.hits) {
      final chord = currentSection.chords[
          (h + window.index * 4).toInt() % currentSection.chords.length];
      final note = RelativeNote(chord.offset, window.beat / 2, h);
      final time = window.start + (note.position / 4) * window.duration;
      _playNote(note + (12 * bassOctave), time);
    }
  }

  static const _rhythms = {
    'onBeat': Rhythm.onBeat,
    'doubled': Rhythm.doubled,
    'continous': Rhythm.continous,
    'gallop': Rhythm.gallop,
    'fullOn': Rhythm.fullOn,
    'offBeat': Rhythm.offBeat,
  };
  Rhythm _rhythm = Rhythm.doubled;
  Wave _wave;
  final SelectElement _resolutionSelect = SelectElement()
    ..id = 'bass_resolution';
  final SelectElement _soundSelect = SelectElement()..id = 'bass_sound';
  final AudioContext _context;
  final GainNode _gain;
}

const _fileNames = [
  'Bass',
  'BassAmp360',
  'BassFuzz',
  'BassFuzz2',
  'BassSubDub',
  'BassSubDub2',
  'Brass',
  'BritBlues',
  'BritBluesDriven',
  'Buzzy1',
  'Buzzy2',
  'Celeste',
  'Dissonant1',
  'Dissonant2',
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
  'PhonemeAh',
  'PhonemeBah',
  'PhonemeEe',
  'PhonemeO',
  'PhonemeOoh',
  'PhonemePopAhhhs',
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

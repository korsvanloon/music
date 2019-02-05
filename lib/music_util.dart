import 'dart:math';

import 'package:color/color.dart';

const List<String> noteNames = <String>[
  'A',
  'Ais',
  'B',
  'C',
  'Cis',
  'D',
  'Dis',
  'E',
  'F',
  'Fis',
  'G',
  'Gis',
];

// const baseFrequency = 432.0;
double toFrequency(int offset, num base) {
  return base * pow(2, offset / 12);
}

double bpmToMeasureDurationInSeconds(int bpm) => 1 / (bpm / 60) * 4;

class Tonic {
  const Tonic(this.name, this.baseFrequency);

  final String name;
  final double baseFrequency;

  static const Tonic A = Tonic('A', 432.0); // 2^4 * 3^3
  static const Tonic Ais = Tonic('Ais', 457.6880567632);
  static const Tonic Bes = Ais;
  static const Tonic B = Tonic('B', 484.9036048696);
  static const Tonic C = Tonic('C', 513.7374736812);
  static const Tonic Cis = Tonic('Cis', 576.6508170015);
  static const Tonic Des = Cis;
  static const Tonic D = Tonic('D', 576.6508170015);
  static const Tonic Dis = Tonic('Dis', 610.9402589452);
  static const Tonic Es = Dis;
  static const Tonic E = Tonic('E', 647.2686572107);
  static const Tonic F = Tonic('F', 685.7572544503);
  static const Tonic Fis = Tonic('Fis', 726.5345027792);
  static const Tonic Ges = Fis;
  static const Tonic G = Tonic('G', 769.7364924733);
  static const Tonic Gis = Tonic('Gis', 815.507406157);
  static const Tonic As = Gis;

  static const List<Tonic> all = [A, Ais, B, C, Cis, D, Dis, E, F, Fis, G, Gis];
}

class RelativeNote {
  RelativeNote(this.offset, this.length, this.position);

  /// 0 = baseNote
  final int offset;

  /// in beats
  final double length;

  /// in beats
  final double position;

  double asFrequency(double base) => toFrequency(offset, base);

  RelativeNote operator +(int offset) =>
      RelativeNote(this.offset + offset, length, position);
}

HslColor hsl(String s) => HslColor(360 * noteNames.indexOf(s) / 12, 100, 50);

class Rhythm {
  const Rhythm(this.hits);

  final Iterable<double> hits;

  Rhythm operator *(int x) =>
      Rhythm(List.filled(x, hits).reduce((a, b) => a.followedBy(b)));

  Rhythm operator +(Rhythm x) => Rhythm(hits.followedBy(x.hits));

  static const onBeat = Rhythm([0, 1, 2, 3]);
  static const offBeat = Rhythm([0.5, 1.5, 2.5, 3.5]);
  static const doubled = Rhythm([0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5]);
  static const gallop = Rhythm([0.5, 0.75, 1.5, 1.75, 2.5, 2.75, 3.5, 3.75]);
  static const fullOn = Rhythm(
      [0.25, 0.5, 0.75, 1.25, 1.5, 1.75, 2.25, 2.5, 2.75, 3.25, 3.5, 3.75]);
  static const continous = Rhythm([
    0,
    0.25,
    0.5,
    0.75,
    1,
    1.25,
    1.5,
    1.75,
    2,
    2.25,
    2.5,
    2.75,
    3,
    3.25,
    3.5,
    3.75
  ]);
}

class Chord {
  Chord(this.offset, {this.mayor});
  Chord.fromString(String s)
      : offset = int.parse(s.replaceAll(RegExp('[mM]'), '')),
        mayor = s.endsWith('M');

  final int offset;
  final bool mayor;

  bool get minor => !mayor;
}

List<Chord> generateChords(String s, [int chordLength = 1]) {
  return s
      .split(' ')
      .map((s) => Chord.fromString(s))
      .expand((c) => List.generate(chordLength, (i) => c))
      .toList();
}

abstract class Measure {
  Measure(this.rhythm, this.chord, this.generateNotes);
  final Rhythm rhythm;
  final Chord chord;
  final List<RelativeNote> Function(Rhythm r, Chord c) generateNotes;

  List<RelativeNote> get notes => generateNotes(rhythm, chord);
}

class MeasureWindow {
  /// in seconds
  final double start;

  /// in seconds
  final double duration;
  final int index;

  double get end => start + duration;
  double get beat => duration / 4;
  MeasureWindow(this.start, this.duration, this.index);

  String toString() => 'Window($start, $duration)';
}

class Wave {
  Wave(this.real, this.imag);

  Wave.fromMap(Map m)
      : real = (m['real'] as List).cast<num>().toList(),
        imag = (m['imag'] as List).cast<num>().toList();

  final List<num> real;
  final List<num> imag;
}

class Section {
  const Section.intro(this.chords, {this.periods = 1})
      : name = 'intro',
        next = const ['verse', 'chorus'];
  const Section.verse(this.chords, {this.periods = 1})
      : name = 'verse',
        next = const ['verse', 'chorus'];
  const Section.chorus(this.chords, {this.periods = 1})
      : name = 'chorus',
        next = const ['chorus', 'verse', 'bridge', 'outro'];
  const Section.bridge(this.chords, {this.periods = 1})
      : name = 'bridge',
        next = const ['chorus'];
  const Section.outro(this.chords, {this.periods = 1})
      : name = 'outro',
        next = const [];

  final String name;
  final List<Chord> chords;
  final List<String> next;
  final int periods;
}

class Sections<T> {
  const Sections(
      {this.intro, this.verse, this.chorus, this.bridge, this.outro});
  final T intro;
  final T verse;
  final T chorus;
  final T bridge;
  final T outro;

  Iterable<T> get list =>
      [intro, verse, chorus, bridge, outro].where((l) => l != null);

  T get first => intro ?? verse;
}

class Instruments {
  Instruments(this.bass, this.body, this.lead, this.drums);
  final String bass;
  final String body;
  final String lead;
  final String drums;
}

class SongData {
  const SongData({
    this.tonic,
    this.title,
    this.bpm,
    this.sections,
    this.instruments,
  });
  final int bpm;
  final Tonic tonic;
  final String title;
  final Sections<Section> sections;
  final Instruments instruments;
}

/*
global
  - sections used
  - section length
  - section chords

per instrument
  - rhythm
  - relative notes
*/

// class Instrument {
//   final String sound;
//   final Sections<List<int>> notes;
//   final Sections<List<Rhythm>> rhythms;
// }

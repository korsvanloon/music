import 'dart:math';

import 'package:color/color.dart';

const noteNames = <String>[
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
double toFrequency(int a, num base) {
  return base * pow(2, a / 12);
}

class Note {
  final String name;
  final double baseFrequency;

  const Note(this.name, this.baseFrequency);

  static const Note A = Note('A', 432.0);
  static const Note Ais = Note('Ais', 484.9036048696);
  static const Note Bes = Ais;
  static const Note B = Note('B', 484.9036048696);
  static const Note C = Note('C', 513.7374736812);
  static const Note Cis = Note('Cis', 576.6508170015);
  static const Note Des = Cis;
  static const Note D = Note('D', 576.6508170015);
  static const Note Dis = Note('Dis', 610.9402589452);
  static const Note Es = Dis;
  static const Note E = Note('E', 647.2686572107);
  static const Note F = Note('F', 685.7572544503);
  static const Note Fis = Note('Fis', 726.5345027792);
  static const Note Ges = Fis;
  static const Note G = Note('G', 769.7364924733);
  static const Note Gis = Note('Gis', 815.507406157);
  static const Note As = Gis;

  static const all = [A, Ais, B, C, Cis, D, Dis, E, F, Fis, G, Gis];
}

class RelativeNote {
  /// 0 = baseNote
  final int offset;

  /// in beats
  final double length;

  /// in beats
  final double position;

  RelativeNote(this.offset, this.length, this.position);

  double asFrequency(double base) => toFrequency(offset, base);
}

HslColor hsl(String s) => HslColor(360 * noteNames.indexOf(s) / 12, 100, 50);

class Rhythm {
  final String name;
  final Iterable<num> hits;

  const Rhythm(this.name, this.hits);

  static const onBeat = Rhythm('on beat', const [0, 1, 2, 3]);
  static const offBeat = Rhythm('offBeat', const [0.5, 1.5, 2.5, 3.5]);
  static const doubled =
      Rhythm('doubled', const [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5]);
  static const gallop =
      Rhythm('gallop', const [0.5, 0.75, 1.5, 1.75, 2.5, 2.75, 3.5, 3.75]);
  static const fullOn = Rhythm('fullOn', const [
    0.25,
    0.5,
    0.75,
    1.25,
    1.5,
    1.75,
    2.25,
    2.5,
    2.75,
    3.25,
    3.5,
    3.75
  ]);
  static const continous = Rhythm('continous', const [
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

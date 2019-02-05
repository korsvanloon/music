import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'dart:web_audio';
import 'package:rxdart/rxdart.dart';


const baseFrequency = 432; // A4

void main() {
  final song = SongData(
    title: 'Strychnine',
    baseNote: Notes.Bes,
    verse: [
      Chord(0, minor),
      null,
      Chord(-4, mayor),
      null,
      Chord(-2, mayor),
      null,
      Chord(-5, mayor),
      null,
    ],
    chorus: [
      Chord(5, mayor),
      null,
      null,
      null,
      Chord(0, minor),
      null,
      null,
      null,
      Chord(5, mayor),
      null,
      null,
      null,
      Chord(7, mayor),
      null,
      null,
      null,
    ],
  );

  final context = AudioContext();
  final oscillator = Oscillator(context);

  querySelector('#output').text = 'Your Dart app is running.';
  final play = playSong(song, oscillator);
  play.pause();

  final button = ButtonElement()
    ..text = 'start'
    ..onClick.listen((e) {
      final b = e.target as ButtonElement;
      if (b.text == 'start') {
        play.resume();
        b.text = 'stop';
      } else {
        play.pause();
        oscillator.stop();
        b.text = 'start';
      }
    });
  document.body.append(button);
}

StreamSubscription<int> playSong(SongData song, Oscillator oscillator) {
  var beatDuration = ((song.bpm / 60) * 1000 / 4).round();

  return Observable.periodic(Duration(milliseconds: beatDuration), (i) => i).listen((i) {
    var chord = song.verse[i % song.verse.length];
    if (chord != null) oscillator.start(toFrequency(song.baseNote + chord.note));
  });
}

double toFrequency(int a) {
  return baseFrequency * pow(2, a / 12);
}

class Oscillator {
  final AudioContext context;
  OscillatorNode node;

  Oscillator(this.context);

  start(num frequency) {
    node?.stop();
    node = context.createOscillator();
    node.type = 'sine';
    node.frequency.setValueAtTime(frequency, context.currentTime);
    node.connectNode(context.destination);
    node.start2();
  }

  stop() => node.stop();
}

class Notes {
  static const A = 0;
  static const Ais = 1;
  static const Bes = 1;
  static const B = 2;
  static const C = 3;
  static const Cis = 4;
  static const Des = 4;
  static const D = 5;
  static const Dis = 6;
  static const Es = 6;
  static const E = 7;
  static const F = 8;
  static const Fis = 9;
  static const Ges = 9;
  static const G = 10;
  static const Gis = 11;
  static const As = 11;
}

const mayor = true;
const minor = false;

class FingerNotes {
  final List<int> left;
  final List<int> right;

  FingerNotes(this.left, this.right);

  factory FingerNotes.penta(bool mayor) => FingerNotes(
        [-12, _mayor(mayor, -8), -7, -5, -2],
        [0, _mayor(mayor, 4), 5, 7, 10],
      );

  factory FingerNotes.chord(bool mayor) => FingerNotes(
        [_mayor(mayor, -20), -17, -12, _mayor(mayor, -8), -5],
        [0, _mayor(mayor, 4), 7, 12, _mayor(mayor, 16)],
      );

  factory FingerNotes.walk(bool mayor) => FingerNotes(
        [_mayor(mayor, 8), -7, -5, _mayor(mayor, -3), _mayor(mayor, -1)],
        [0, 2, _mayor(mayor, 4), 5, 7],
      );

  factory FingerNotes.tight(bool mayor) => FingerNotes(
        [-5, -4, -3, -2, -1],
        [0, 1, 2, 3, 4],
      );

  factory FingerNotes.blues(bool mayor) => FingerNotes(
        [-14, -12, _mayor(mayor, -8), -5, -2],
        [0, _mayor(mayor, 4), 7, 10, 12],
      );
}

int _mayor(bool mayor, int note) => mayor ? note : note - 1;

class Measure {

}
class Chord {
  final int note;
  final bool mayor;

  Chord(this.note, this.mayor);
}

class SongData {
  int bpm;
  int baseNote;
  String title;

  SongData({
    this.baseNote = 0,
    this.title,
    this.bpm = 120,
    this.intro,
    this.verse,
    this.chorus,
    this.bridge,
    this.outro,
  });

  // schemas
  List<Chord> intro;
  List<Chord> verse;
  List<Chord> chorus;
  List<Chord> bridge;
  List<Chord> outro;
}

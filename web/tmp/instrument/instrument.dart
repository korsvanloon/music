import '../music_util.dart';

abstract class Instrument {}

class MasterData {
  final Note baseNote;
  // measures per milli second 500 ms = 120 bpm
  // final Duration mpms = Duration(milliseconds: 500);
  // double get bpm => mpms.inMilliseconds * 0.240;
  final double bpm;
  final bool isPlaying;
  MasterData({this.baseNote = Note.A, this.bpm = 120.0, this.isPlaying = false});

  String toString() => '${isPlaying ? 'playing' : 'stopped'} $bpm $baseNote';
}

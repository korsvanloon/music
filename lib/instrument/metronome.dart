import 'dart:web_audio';
import 'package:music/instrument/instrument.dart';
import 'package:music/music_util.dart';
import 'package:music/state.dart';

class Metronome extends Schedulable {
  Metronome(this._context, Stream<Wave> wave$)
      : gain = _context.createGain()..connectNode(_context.destination) {
    wave$.listen((w) => _wave = w);
  }
  Wave _wave;
  final GainNode gain;

  void _scheduleNotes(MeasureWindow window) {
    // final offset = (h) => h == 0 ? 12 : h % 1 == 0 ? 0 : -12;
    final currentSection = store.state.currentSection;

    for (final h in rhythm.hits) {
      final chord = currentSection.chords[
          (h + window.index * 4).toInt() % currentSection.chords.length];
      final note = RelativeNote(chord.offset, window.beat / 2, h);
      final time = window.start + (note.position / 4) * window.duration;
      _playNote(note, time);
      _playNote(note + (chord.mayor ? 4 : 3), time);
      _playNote(note + 7, time);
    }
  }

  void _playNote(RelativeNote note, double time) {
    gain.gain.setValueAtTime(0, time);
    gain.gain.linearRampToValueAtTime(1, time + 0.05);
    _context.createOscillator()
      ..connectNode(gain)
      ..frequency.value = note.asFrequency(store.state.tonic.baseFrequency)
      ..setPeriodicWave(_context.createPeriodicWave(_wave.real, _wave.imag))
      ..start2(time)
      ..stop(time + note.length);
  }

  Rhythm rhythm = Rhythm.doubled;
  final AudioContext _context;

  @override
  void schedule(MeasureWindow window) {
    _scheduleNotes(window);
  }
}

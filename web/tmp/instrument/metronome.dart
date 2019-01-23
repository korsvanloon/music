import '../music_util.dart';
import 'instrument.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:web_audio';

class Metronome extends Instrument {
  PublishSubject<int> note$ = PublishSubject<int>();

  Metronome(this._audioContext, Stream<MasterData> master$) {
    master$.listen((m) => _master = m);
  }

  void _scheduleNotes(double startTime, double noteLength) {
    final secondsPerBeat = 60.0 / _master.bpm;
    final delay = Duration(microseconds: (startTime).toInt());
    final period = Duration(microseconds: secondsPerBeat * 1000 * 1000 ~/ 4);

    Observable<int>.periodic(period, (i) => i)
        // .delay(delay)
        .take(16)
        .listen(note$.add);

    final offset = (h) => h == 0 ? 12 : h % 1 == 0 ? 0 : -12;
    final notes = rhythm.hits.map((h) => RelativeNote(offset(h), noteLength, h));
    for (final note in notes) {

      final time = startTime + note.position * secondsPerBeat;
      _audioContext.createOscillator()
        ..connectNode(_audioContext.destination)
        ..frequency.value = note.asFrequency(_master.baseNote.baseFrequency)
        ..start2(time)
        ..stop(time + note.length);
    }
  }

  void scheduler() {
    while (_loopStart < _audioContext.currentTime + 0.1) {
      final startTime = _loopStart;
      final secondsPerBeat = 60.0 / _master.bpm;
      _loopStart += 4 * secondsPerBeat;
      _scheduleNotes(startTime, 0.05);
    }
  }

  void play(bool isPlaying) {
    if (isPlaying) {
      _loopStart = _audioContext.currentTime;
    }
  }

  double _loopStart;
  Rhythm rhythm = Rhythm.doubled;
  MasterData _master;
  final AudioContext _audioContext;
}

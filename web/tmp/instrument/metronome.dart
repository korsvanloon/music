import 'instrument.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:web_audio';

class Metronome extends Instrument {
  double _loopStart;
  int noteResolution = 0; // 0 == 16th, 1 == 8th, 2 == quarter note

  MasterData master;
  
  final AudioContext audioContext;
  PublishSubject<int> note$ = PublishSubject<int>();

  Metronome(this.audioContext);

  void _scheduleNotes(double startTime, double noteLength) {
    final secondsPerBeat = 60.0 / master.bpm;
    final delay = Duration(microseconds: (startTime).toInt());
    final period = Duration(microseconds: secondsPerBeat * 1000 * 1000 ~/ 4);

    Observable<int>.periodic(period, (i) => i)
        // .delay(delay)
        .take(16)
        .listen(note$.add);

    for (var i = 0; i < 16 - noteResolution; i++) {
      if ((noteResolution == 1) && (i % 2 != 0)) continue;
      if ((noteResolution == 2) && (i % 4 != 0)) continue;

      final time = startTime + i * 0.25 * secondsPerBeat;
      final frequency = master.baseNote.baseFrequency;
      audioContext.createOscillator()
        ..connectNode(audioContext.destination)
        ..frequency.value = (i == 0
            ? frequency * 2
            : i % 4 == 0 ? frequency : frequency / 2)
        ..start2(time)
        ..stop(time + noteLength);
    }
  }

  void scheduler() {
    while (_loopStart < audioContext.currentTime + 0.1) {
      final startTime = _loopStart;
      final secondsPerBeat = 60.0 / master.bpm;
      _loopStart += 4 * secondsPerBeat;
      _scheduleNotes(startTime, 0.05);
    }
  }

  void play(bool isPlaying) {
    if (isPlaying) {
      _loopStart = audioContext.currentTime;
    }
  }
}

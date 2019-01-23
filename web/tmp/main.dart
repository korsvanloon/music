import 'dart:html';
import 'dart:web_audio';
import 'instrument/metronome.dart';
import 'view/tone.dart';
import 'view/master.dart';
import 'view/metronome.dart';
import 'package:rxdart/rxdart.dart';
import 'music_util.dart';

void main() {
  final timerWorker = Worker("tmp/metronomeworker.js");
  final metronomeView = MetronomeView();
  final masterView = MasterView();
  final toneView = ToneView(masterView.master$);
  final audioContext = AudioContext();
  final metronome = Metronome(audioContext, masterView.master$);

  document.body
    ..append(masterView.element)
    ..append(metronomeView.element)
    ..append(toneView.element);

  metronomeView.resolution$.listen((e) => metronome.rhythm = e);

  masterView.master$.map((e) => e.isPlaying).distinct().listen((b) {
    if (b) {
      timerWorker.postMessage("start");
    } else {
      timerWorker.postMessage("stop");
    }
    metronome.play(b);
  });

  metronome.note$.listen(metronomeView.draw);

  Observable.combineLatest2(masterView.master$, toneView.note$, (m, n) => [m,n]).listen((e) {
    final m = e.first;
    final n = e.last;
    audioContext.createOscillator()
        ..connectNode(audioContext.destination)
        ..frequency.value = toFrequency(n, m.baseNote.baseFrequency)
        ..start2(audioContext.currentTime)
        ..stop(audioContext.currentTime + .5);
  });

  timerWorker.onMessage.where((e) => e.data == 'tick').listen((e) {
    metronome.scheduler();
  });

  // timerWorker.postMessage({"interval": 25.0});
}
import 'dart:html';
import 'dart:web_audio';
import 'instrument/metronome.dart';
import 'view/tone.dart';
import 'view/master.dart';
import 'view/metronome.dart';

void main() {
  final metronomeView = MetronomeView();
  final timerWorker = Worker("tmp/metronomeworker.js");
  final masterView = MasterView();
  final audioContext = AudioContext();
  final metronome = Metronome(audioContext);

  final toneView = ToneView();

  document.body
    ..append(masterView.element)
    ..append(metronomeView.element)
    ..append(toneView.element);

  masterView.output$.listen((e) {
    metronome.master = e;
    toneView.setBaseNote(e.baseNote);
  });

  metronomeView.resolution$.listen((e) => metronome.noteResolution = e);

  masterView.output$.map((e) => e.isPlaying).distinct().listen((b) {
    if (b) {
      timerWorker.postMessage("start");
    } else {
      timerWorker.postMessage("stop");
    }
    metronome.play(b);
  });

  metronome.note$.listen(metronomeView.draw);

  toneView.note$.listen((n) {
    print(n.name);
    audioContext.createOscillator()
        ..connectNode(audioContext.destination)
        ..frequency.value = n.baseFrequency
        ..start2(audioContext.currentTime)
        ..stop(audioContext.currentTime + .5);
  });

  timerWorker.onMessage.where((e) => e.data == 'tick').listen((e) {
    metronome.scheduler();
  });

  // timerWorker.postMessage({"interval": 25.0});
}
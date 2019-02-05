import 'dart:async';
import 'dart:html';
import 'dart:web_audio';
import 'package:music/instrument/bass.dart';
import 'package:music/state.dart';
import 'package:music/view/master.dart';
import 'package:music/instrument/instrument.dart';
import 'package:music/instrument/metronome.dart';
import 'package:music/view/chords.dart';
import 'package:music/view/tone.dart';
import 'package:music/view/metronome.dart';
import 'package:rxdart/rxdart.dart';
import 'package:music/music_util.dart';

final SongData strychnine = SongData(
  title: 'Strychnine',
  bpm: 150,
  tonic: Tonic.Bes,
  sections: Sections(
    intro: Section.intro(generateChords('-3m 4M 9m 14m', 4)),
    verse: Section.verse(generateChords('0m -4M -2M -5M', 2), periods: 2),
    chorus: Section.chorus(generateChords('5M 0m 5M 7M', 4)),
  ),
);

void main() async {
  final context = AudioContext();

  final frame$ = generateSyncedAnimationFrames(context).asBroadcastStream();
  final masterView = MasterView();
  final chordsView = ChordsView(frame$);
  final metronomeView = MetronomeView(frame$);
  final bassView = Bass(context);
  final toneView = ToneView();
  final metronome = Metronome(context, metronomeView.wave$);
  final body = Metronome(context, metronomeView.wave$);

  final scheduler = Scheduler(context, masterView.toggle$, [
    metronome,
    chordsView,
    metronomeView,
    body,
    bassView,
  ]);

  document.body.children = [
    masterView.element,
    chordsView.element,
    bassView.element,
    metronomeView.element,
    toneView.element,
  ];
  masterView.tonic$.listen(store.changeTonic);
  masterView.bpm$.listen(store.changeBpm);
  masterView.currentSection$.listen(store.changeCurrentSection);

  metronomeView.resolution$.listen((e) => metronome.rhythm = e);

  Observable.combineLatest2(masterView.tonic$, toneView.note$, (m, n) => [m, n])
      .listen((e) {
    final m = e.first;
    final n = e.last;
    context.createOscillator()
      ..connectNode(context.destination)
      ..frequency.value = toFrequency(n, m.baseFrequency)
      ..start2(context.currentTime)
      ..stop(context.currentTime + .5);
  });

  store.loadSong(strychnine);
}

Iterable<double> measureStart(double startTime, double measureDuration) sync* {
  var currentTime = startTime;
  yield currentTime;
  while (true) {
    currentTime += measureDuration;
    yield currentTime;
  }
}

class Scheduler {
  Iterable<Schedulable> schedulables;

  Scheduler(this._context, Stream<bool> toggle$, this.schedulables) {
    toggle$.listen((isOn) {
      if (isOn) {
        _sub = _window$().listen((window) {
          schedulables.forEach((s) => s.schedule(window));
        });
      } else {
        _sub?.cancel();
      }
    });
  }

  Stream<MeasureWindow> _window$() async* {
    var startTime = _context.currentTime;
    var index = 0;
    while (true) {
      final measureDuration = bpmToMeasureDurationInSeconds(store.state.bpm);

      yield MeasureWindow(startTime, measureDuration, index++);

      final buffer = measureDuration / 8;
      final seconds =
          startTime - _context.currentTime - buffer + measureDuration;
      await Future.delayed(Duration(milliseconds: (seconds * 1000).toInt()));
      startTime += measureDuration;
    }
  }

  final AudioContext _context;
  StreamSubscription _sub;
}

Stream<num> generateSyncedAnimationFrames(AudioContext context) async* {
  while (true) {
    await window.animationFrame;
    yield context.currentTime;
  }
}

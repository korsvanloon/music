import 'dart:html';
import 'dart:web_audio';
import 'package:rxdart/rxdart.dart';

final audioContext = new AudioContext();
const baseFrequency = 432.0;

bool isPlaying = false;
int startTime;
int current16thNote;
double bpm = 120.0;
double lookaheadMs = 25.0;
double scheduleAheadSeconds = 0.1;
double nextNoteTime = 0.0;
int noteResolution = 0; // 0 == 16th, 1 == 8th, 2 == quarter note
double noteLength = 0.05;

int last16thNoteDrawn = -1; // the last "box" we drew on the screen

final notesInQueue = <Note>[];
final timerWorker = new Worker("js/metronomeworker.js");

void main() {
//  blaat();

  final metronomeView = MetronomeView(window);

  document.body
    ..append(DivElement()
      ..id = 'controls'
      ..children = [
        DivElement()
          ..children = [
            ButtonElement()
              ..className = 'play'
              ..onClick.listen(play)
              ..text = 'play'
          ],
        DivElement()
          ..id = 'tempoBox'
          ..append(Text('Tempo: '))
          ..append(SpanElement()
            ..id = 'showTempo'
            ..text = '120')
          ..append(Text('BPM '))
          ..append(RangeInputElement()
            ..min = '30.0'
            ..max = '160.0'
            ..step = '1'
            ..value = '120'
            ..onInput.listen((e) {
              bpm = (e.target as RangeInputElement).valueAsNumber;
              document.getElementById('showTempo').text = bpm.toString();
            })),
        DivElement()
          ..append(Text('Resolution:'))
          ..append(SelectElement()
            ..onChange.listen((e) {
              noteResolution = (e.target as SelectElement).selectedIndex;
            })
            ..children = [
              OptionElement()..text = '16th notes',
              OptionElement()..text = '8th notes',
              OptionElement()..text = '4th notes',
            ])
      ])
    ..append(DivElement()
      ..className = 'container'
      ..append(metronomeView.canvas));

  timerWorker.onMessage.listen((e) {
    if (e.data == "tick") {
      scheduler();
    } else
      print("message: " + e.data);
  });
  timerWorker.postMessage({"interval": lookaheadMs});
}

void nextNote() {
  // Advance current note and time by a 16th note...
  final secondsPerBeat = 60.0 / bpm;
  nextNoteTime += 0.25 * secondsPerBeat;

  current16thNote++;
  if (current16thNote == 16) {
    current16thNote = 0;
  }
}

class Note {
  final int note;
  final double time;

  Note(this.note, this.time);
}

void scheduleNote(int beatNumber, double time) {
  // push the note on the queue, even if we're not playing.
  notesInQueue.add(Note(beatNumber, time));

  if ((noteResolution == 1) && (beatNumber % 2 != 0))
    return;
  if ((noteResolution == 2) && (beatNumber % 4 != 0))
    return;

  // create an oscillator
  final osc = audioContext.createOscillator();
  osc.connectNode(audioContext.destination);
  if (beatNumber % 16 == 0) // beat 0 == low pitch
    osc.frequency.value = baseFrequency * 2;
  else if (beatNumber % 4 == 0) // quarter notes = medium pitch
    osc.frequency.value = baseFrequency;
  else // other 16th notes = high pitch
    osc.frequency.value = baseFrequency / 2;

  osc.start2(time);
  osc.stop(time + noteLength);
}

void scheduler() {
  while (nextNoteTime < audioContext.currentTime + scheduleAheadSeconds) {
    scheduleNote(current16thNote, nextNoteTime);
    nextNote();
  }
}

void play(Event e) {
  isPlaying = !isPlaying;

  final button = e.target as ButtonElement;
  if (isPlaying) {
    // start playing
    current16thNote = 0;
    nextNoteTime = audioContext.currentTime;
    timerWorker.postMessage("start");
    button.text = "stop";
  } else {
    timerWorker.postMessage("stop");
    button.text = "play";
  }
}


class MetronomeView {
  final Window window;
  final canvas = CanvasElement();
  CanvasRenderingContext2D get canvasContext => canvas.context2D;

  MetronomeView(this.window) {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;

    canvasContext.strokeStyle = "#ffffff";
    canvasContext.lineWidth = 2;

    window.onDeviceOrientation.listen(resetCanvas);
    window.onResize.listen(resetCanvas);

    window.requestAnimationFrame(draw);
  }

  void resetCanvas(Event e) {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
    window.scrollTo(0, 0);
  }

  void draw(num e) {
    var currentNote = last16thNoteDrawn;
    var currentTime = audioContext.currentTime;

    while (notesInQueue.isNotEmpty && notesInQueue.first.time < currentTime) {
      currentNote = notesInQueue.removeAt(0).note;
    }

    if (last16thNoteDrawn != currentNote) {
      final x = (canvas.width / 18).floor();
      canvasContext.clearRect(0, 0, canvas.width, canvas.height);
      for (var i = 0; i < 16; i++) {
        canvasContext.fillStyle = (currentNote == i)
            ? ((currentNote % 4 == 0) ? "red" : "blue")
            : "black";
        canvasContext.fillRect(x * (i + 1), x, x / 2, x / 2);
      }
      last16thNoteDrawn = currentNote;
    }

    window.requestAnimationFrame(draw);
  }
}

//blaat() {
//  final dragTarget = querySelector('#dragTarget');
//  final mouseUp$ = Observable(document.onMouseUp);
//  final mouseMove$ = Observable(document.onMouseMove);
//  final mouseDown$ = Observable(document.onMouseDown);
//
//  final mousePath$ = mouseDown$
//      .map((event) => event.client - dragTarget.offset.topLeft)
//      .switchMap((startPosition) => mouseMove$
//          .map((event) => event.client - startPosition)
//          .takeUntil(mouseUp$));
//
//  mousePath$.listen((position) {
//    dragTarget.style.left = '${position.x}px';
//    dragTarget.style.top = '${position.y}px';
//  });
//}

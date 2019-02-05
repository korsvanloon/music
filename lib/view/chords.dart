import 'dart:html';

import 'package:music/instrument/instrument.dart';
import 'package:music/music_util.dart';
import 'package:music/state.dart';

/*
period:  2 phrases (antecedent, consequent), both starts with same motif
phrase:  4 measures
measure: 4 beats
beat:    4 tick
*/
class ChordsView extends Schedulable {
  ChordsView(this._animationFrame$) {
    element.children = [
      Element.header()..text = 'Chords',
      _section,
    ];
    store.currentSection$.listen(update);

    _section.onKeyDown.where((e) => e.target is InputElement).listen((e) {
      final input = e.target as InputElement;
      final index = int.parse(input.id.substring(1));
      final c = store.state.currentSection.chords[index];
      switch (e.key) {
        case 'ArrowUp':
          e.preventDefault();
          assignChord(index, Chord(c.offset + 1, mayor: c.mayor), input);
          break;
        case 'ArrowDown':
          e.preventDefault();
          assignChord(index, Chord(c.offset - 1, mayor: c.mayor), input);
          break;
        case 'ArrowLeft':
        case 'ArrowRight':
          e.preventDefault();
          assignChord(index, Chord(c.offset, mayor: c.minor), input);
          break;
      }
    });
  }

  final Element element = Element.article();
  final Stream<num> _animationFrame$;

  void update(Section currentSection) {
    final builder = _SectionBuilder(currentSection);
    _section.children = List.generate(currentSection.periods, builder.period);
  }

  void assignChord(int index, Chord chord, InputElement input) {
    store.state.currentSection.chords[index] = chord;
    _SectionBuilder.updateInput(chord, input);
  }

  final Element _section = Element.section()..id = 'chords';

  @override
  void schedule(MeasureWindow window) {
    final currentSection = store.state.currentSection;
    var i = 0;
    _animationFrame$
        .skipWhile((n) => n <= window.start)
        .takeWhile((n) => n <= window.end)
        .listen((n) {
      final beat = window.start + i * window.duration / 4;
      if (n <= beat) {
        return;
      }
      element.querySelector('.current')?.classes?.remove('current');
      final chordIndex = (i + window.index * 4) %
          (currentSection.chords.length * currentSection.periods) %
          currentSection.chords.length;
      element.querySelectorAll('input')[chordIndex].classes.add('current');
      i++;
    });
  }
}

class _SectionBuilder {
  _SectionBuilder(this.currentSection);
  Section currentSection;

  Element period(int p) {
    return DivElement()
      ..className = 'period'
      ..children = [
        phrase(p * 2 * 4)..classes.add('antecedent'),
        phrase((p * 2 + 1) * 4)..classes.add('consequent'),
      ];
  }

  Element phrase(int p) {
    return DivElement()
      ..className = 'row phrase'
      ..children = List.generate(4, (i) => measure((i + p) * 4));
  }

  Element measure(int p) {
    return DivElement()
      ..className = 'measure'
      ..children = List.generate(
        4,
        (i) {
          final index = (i + p) % currentSection.chords.length;
          final chord = currentSection.chords[index];
          final input = TextInputElement()
            ..id = 'b${i + p}'
            ..readOnly = true;
          updateInput(chord, input);
          return input;
        },
      );
  }

  static void updateInput(Chord chord, InputElement input) {
    input
      ..value = '${chord.minor ? 'm' : 'M'}'
      ..title = '${chord.offset}${chord.minor ? 'm' : 'M'}'
      ..style.backgroundColor =
          'hsl(${360 * chord.offset / 12}, ${chord.minor ? 60 : 100}%, 80%)';
  }
}

import 'package:music/music_util.dart';

abstract class Schedulable {
  void schedule(MeasureWindow window);
}

abstract class Instrument extends Schedulable {
  Instrument(Stream<Tonic> tonic$) {
    tonic$.listen((t) => _tonic = t);
  }
  Tonic _tonic;
  Tonic get tonic => _tonic;
}

import 'package:rxdart/rxdart.dart';
import 'package:music/music_util.dart';

enum ActionType {
  newSong,
  bpmChanged,
  playingChanged,
  sectionChanged,
  tonicChanged,
}

class Store {
  final AppState state = AppState();

  Observable<AppState> get state$ => _action.map((_) => state);
  Observable<SongData> get song$ =>
      _action.where((t) => t == ActionType.newSong).map((_) => state.song);
  Observable<int> get bpm$ =>
      _action.where((t) => t == ActionType.bpmChanged).map((_) => state.bpm);
  Observable<bool> get isPlaying$ => _action
      .where((t) => t == ActionType.playingChanged)
      .map((_) => state.isPlaying);
  Observable<Section> get currentSection$ => _action
      .where((t) => t == ActionType.sectionChanged)
      .map((_) => state.currentSection);
  Observable<Tonic> get tonic$ => _action
      .where((t) => t == ActionType.tonicChanged)
      .map((_) => state.tonic);

  void loadSong(SongData data) {
    state._song = data;
    _action.add(ActionType.newSong);
    changeBpm(data.bpm);
    changeCurrentSection(data.sections.first);
    changeTonic(data.tonic);
  }

  void changeBpm(int data) {
    state._bpm = data;
    _action.add(ActionType.bpmChanged);
  }

  void changeTonic(Tonic data) {
    state._tonic = data;
    _action.add(ActionType.tonicChanged);
  }

  void changePlaying(bool data) {
    state._isPlaying = data;
    _action.add(ActionType.playingChanged);
  }

  void changeCurrentSection(Section data) {
    state._currentSection = data;
    _action.add(ActionType.sectionChanged);
  }

  final Subject<ActionType> _action = PublishSubject<ActionType>();
}

class AppState {
  SongData get song => _song;
  int get bpm => _bpm;
  bool get isPlaying => _isPlaying;
  Section get currentSection => _currentSection;
  Tonic get tonic => _tonic;

  SongData _song;
  int _bpm;
  bool _isPlaying = false;
  Section _currentSection;
  Tonic _tonic;
}

final Store store = Store();

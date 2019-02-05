import 'dart:html';

DivElement selectControl(
  SelectElement select, {
  String label,
  Iterable<String> options,
  String defaultValue,
}) {
  final result = DivElement()
    ..className = 'control'
    ..append(LabelElement()
      ..text = label
      ..htmlFor = select.id)
    ..append(select);
  if (defaultValue != null) {
    select.value = defaultValue;
  }
  if (options != null) {
    select.children =
        options.map((o) => OptionElement(data: o, value: o)).toList();
  }
  return result;
}

Stream<bool> createToggle$(ButtonElement element,
    {Node offChild, Node onChild, bool isOn = false}) async* {
  void updateElement(bool toggled) {
    element.children.clear();
    if (toggled) {
      if (onChild != null) {
        element.append(onChild);
      }
      element.classes.add('active');
    } else {
      if (offChild != null) {
        element.append(offChild);
      }
      element.classes.remove('active');
    }
  }

  var toggled = isOn;
  yield toggled;
  updateElement(toggled);

  await for (final _ in element.onClick) {
    toggled = !toggled;
    yield toggled;
    updateElement(toggled);
  }
}

class SelectControl<T> {
  SelectControl(this._toOption, String id, String label) {
    element
      ..className = 'control'
      ..append(LabelElement()
        ..text = label
        ..htmlFor = id)
      ..append(_input..id = id);
  }
  final DivElement element = DivElement();
  final _input = SelectElement();
  final OptionElement Function(T i) _toOption;
  Stream<T> get selected$ =>
      _input.onChange.map((e) => _options[_input.selectedIndex]);

  List<T> _options;

  set options(List<T> value) {
    _options = value;
    _input.children = value.map(_toOption).toList();
  }
}

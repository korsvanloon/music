import 'dart:html';

DivElement selectControl( SelectElement select,
    {String label, Iterable<String> options, }) {
  return DivElement()
    ..className = 'control'
    ..append(LabelElement()
      ..text = label
      ..htmlFor = select.id)
    ..append(select
      ..children = options.map((o) => OptionElement(data: o)).toList());
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A custom hook react.js-like that allows to select a state from the state manager (provider).
/// * `context` - The build context.
/// * `listen` - Whether the widget should listen to changes. (Optional)
/// * `return` - the selected state of type [T].
T useProvider<T>(BuildContext context, [bool listen = true]) {
  return Provider.of<T>(context, listen: listen);
}

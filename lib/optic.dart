import 'package:flutter/material.dart';
import 'package:obmin_concept/lens.dart';
import 'package:obmin_concept/utils/optional.dart';

final class Optic<T> {
  final (T, void Function(T Function(T))) Function(BuildContext context) _data;

  Optic._(this._data);

  Optic<V> zoom<V>(Lens<T, V> lens) {
    return Optic._(
      (context) {
        final (state, setState) = _data(context);

        final newState = lens.get(state);

        return (
          newState,
          (transition) {
            setState((whole) {
              final part = transition(lens.get(whole));

              return lens.put(whole, part);
            });
          },
        );
      },
    );
  }

  Widget build({
    required Widget Function(
      BuildContext context,
      T state,
      void Function(T Function(T state) transition) setState,
    ) builder,
  }) {
    return Builder(
      builder: (context) {
        final (state, setState) = _data(context);
        return builder(context, state, setState);
      },
    );
  }

  Widget calculate({
    required void Function(
      BuildContext context,
      Optional<T> oldState,
      T newState,
      void Function(T Function(T state) transition) setState,
    ) calculate,
    required Widget child,
  }) {
    return _CalculateWidget(
      optic: this,
      calculate: calculate,
      child: child,
    );
  }
}

class _CalculateWidget<T> extends StatefulWidget {
  final Optic<T> optic;
  final void Function(
    BuildContext context,
    Optional<T> oldState,
    T newState,
    void Function(T Function(T state) transition) setState,
  ) calculate;
  final Widget child;

  const _CalculateWidget({
    super.key,
    required this.optic,
    required this.calculate,
    required this.child,
  });

  @override
  State<_CalculateWidget<T>> createState() => _CalculateWidgetState<T>();
}

class _CalculateWidgetState<T> extends State<_CalculateWidget<T>> {
  late Optional<T> _old;
  late T _state;

  bool _isInitial = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitial) {
      _old = None();
      final (data, _) = widget.optic._data(context);
      _state = data;
      _isInitial = false;
    } else {
      _old = Some(_state);
      final (data, setData) = widget.optic._data(context);
      _state = data;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.calculate(context, _old, data, setData);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class OpticWidget<T> extends InheritedWidget {
  final T state;
  final void Function(T Function(T state) transition) setState;

  OpticWidget({
    super.key,
    required this.state,
    required this.setState,
    required Widget Function(BuildContext context, Optic<T> optic) builder,
  }) : super(child: _OpticStatelessWidget<T>(builder: builder));

  static OpticWidget<T> _of<T>(BuildContext context) {
    final OpticWidget<T>? result = context.dependOnInheritedWidgetOfExactType<OpticWidget<T>>();
    return result!;
  }

  @override
  bool updateShouldNotify(OpticWidget<T> oldWidget) {
    return state != oldWidget.state;
  }
}

class _OpticStatelessWidget<T> extends StatelessWidget {
  final Widget Function(BuildContext context, Optic<T> optic) builder;

  const _OpticStatelessWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final optic = Optic<T>._((context) {
      final widget = OpticWidget._of<T>(context);
      final state = widget.state;
      final setState = widget.setState;

      return (state, setState);
    });

    return builder(context, optic);
  }
}

import 'package:flutter/material.dart';
import 'package:obmin_concept/a_foundation/types/lens.dart';
import 'package:obmin_concept/a_foundation/types/optional.dart';

class ZoomableWidget<T> extends InheritedWidget {
  final T state;
  final void Function(T Function(T state) transition) setState;

  ZoomableWidget({
    super.key,
    required this.state,
    required this.setState,
    required Widget Function(BuildContext context, Zoomable<T> zoomable) builder,
  }) : super(child: _ZoomableStatelessWidget<T>(builder: builder));

  static ZoomableWidget<T> _of<T>(BuildContext context) {
    final ZoomableWidget<T>? result = context.dependOnInheritedWidgetOfExactType<ZoomableWidget<T>>();
    return result!;
  }

  @override
  bool updateShouldNotify(ZoomableWidget<T> oldWidget) {
    return state != oldWidget.state;
  }
}

class _ZoomableStatelessWidget<T> extends StatelessWidget {
  final Widget Function(BuildContext context, Zoomable<T> zoomable) builder;

  const _ZoomableStatelessWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final zoomable = Zoomable<T>._((context) {
      final widget = ZoomableWidget._of<T>(context);
      final state = widget.state;
      final setState = widget.setState;

      return (state, setState);
    });

    return builder(context, zoomable);
  }
}

final class Zoomable<T> {
  final (T, void Function(T Function(T))) Function(BuildContext context) _data;

  Zoomable._(this._data);

  Zoomable<V> zoom<V>(Lens<T, V> lens) {
    return Zoomable._(
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
    Key? key,
    required Widget Function(
      BuildContext context,
      T state,
      void Function(T Function(T state) transition) setState,
    ) builder,
  }) {
    return Builder(
      key: key,
      builder: (context) {
        final (state, setState) = _data(context);
        return builder(context, state, setState);
      },
    );
  }

  Widget calculate({
    Key? key,
    required void Function(
      BuildContext context,
      Optional<T> oldState,
      T newState,
      void Function(T Function(T state) transition) setState,
    ) calculate,
    required Widget child,
  }) {
    return _CalculateWidget(
      key: key,
      zoomable: this,
      calculate: calculate,
      child: child,
    );
  }
}

class _CalculateWidget<T> extends StatefulWidget {
  final Zoomable<T> zoomable;
  final void Function(
    BuildContext context,
    Optional<T> oldState,
    T newState,
    void Function(T Function(T state) transition) setState,
  ) calculate;
  final Widget child;

  const _CalculateWidget({
    super.key,
    required this.zoomable,
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
      final (data, _) = widget.zoomable._data(context);
      _state = data;
      _isInitial = false;
    } else {
      _old = Some(_state);
      final (data, setData) = widget.zoomable._data(context);
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

// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class NavItem {
  final String tag;
  final Widget child;

  const NavItem({
    required this.tag,
    required this.child,
  });
}

class NavBox extends InheritedWidget {
  final bool Function(bool isForced) onPopTriggered;
  final NavItem main;
  final List<NavItem> others;

  NavBox({
    super.key,
    required this.onPopTriggered,
    required this.main,
    required this.others,
  }) : super(child: _NavBox());

  static NavBox _of(BuildContext context) {
    final NavBox? box = context.dependOnInheritedWidgetOfExactType<NavBox>();
    assert(box != null, 'No NavBox found in context');
    return box!;
  }

  @override
  bool updateShouldNotify(NavBox oldWidget) {
    return main != oldWidget.main || others.map((value) => value.tag) != oldWidget.others.map((value) => value.tag);
  }
}

class _ProxyNavBox extends InheritedWidget {
  const _ProxyNavBox({
    required super.child,
  });

  static bool isRoot(BuildContext context) {
    final _ProxyNavBox? result = context.dependOnInheritedWidgetOfExactType<_ProxyNavBox>();
    return result == null;
  }

  @override
  bool updateShouldNotify(_ProxyNavBox old) {
    return false;
  }
}

class _NavBox extends StatefulWidget {
  @override
  State<_NavBox> createState() => _NavBoxState();
}

class _NavBoxState extends State<_NavBox> {
  bool _isInit = true;

  BackButtonDispatcher? _backButtonDispatcher;

  late _TheRouterDelegate _delegate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;

      final isRoot = _ProxyNavBox.isRoot(context);
      _delegate = _TheRouterDelegate(isRoot: isRoot);
      if (isRoot) {
        _backButtonDispatcher = RootBackButtonDispatcher();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final BackButtonDispatcher? backButtonDispatcher = _backButtonDispatcher;

    final BackButtonDispatcher proxyBackButtonDispatcher;
    if (backButtonDispatcher != null) {
      proxyBackButtonDispatcher = backButtonDispatcher;
    } else {
      proxyBackButtonDispatcher = ChildBackButtonDispatcher(Router.of(context).backButtonDispatcher!);
      proxyBackButtonDispatcher.takePriority();
    }

    return _ProxyNavBox(
      child: Router(
        routerDelegate: _delegate,
        backButtonDispatcher: proxyBackButtonDispatcher,
      ),
    );
  }
}

final class _TheRouterDelegate extends RouterDelegate {
  final bool isRoot;

  final GlobalKey<NavigatorState> _key = GlobalKey();

  _TheRouterDelegate({
    required this.isRoot,
  });

  @override
  Widget build(BuildContext context) {
    final NavBox box = NavBox._of(context);

    final List<NavItem> tuples = [];
    tuples.add(box.main);
    tuples.addAll(box.others);

    final List<Page<dynamic>> pages = tuples.map((tuple) {
      final tag = tuple.tag;
      final widget = tuple.child;
      return MaterialPage(
        key: ValueKey(tag),
        child: widget,
      );
    }).toList();

    final navigator = Navigator(
      key: _key,
      pages: pages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        } else {
          box.onPopTriggered(true); // we don't care about result in this case
          return true;
        }
      },
    );

    if (isRoot) {
      return navigator;
    } else {
      if (defaultTargetPlatform == TargetPlatform.iOS && navigator.pages.length > 1) {
        return PopScope(
          canPop: false,
          child: navigator,
        );
      } else {
        return navigator;
      }
    }
  }

  @override
  Future<bool> popRoute() async {
    final context = _key.currentContext;
    if (context == null) {
      return false;
    } else {
      final isHandled = NavBox._of(context).onPopTriggered(false);
      if (isHandled) {
        return true;
      } else {
        if (isRoot) {
          SystemNavigator.pop();
          return true;
        } else {
          return false;
        }
      }
    }
  }

  @override
  Future<void> setNewRoutePath(configuration) async {}

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}
}

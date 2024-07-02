// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

import 'package:obmin/types/transition.dart';
import 'package:obmin/ui_tools/zoomable/zoomable_widget.dart';

typedef ValueZoomableWidget<T> = ZoomableWidget<T, Transition<T>>;

// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.

final class MachineLogger<Loggable> {
  final String id;
  final void Function(Loggable loggable) log;

  MachineLogger({
    required this.id,
    required this.log,
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is MachineLogger<Loggable> && runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return "MachineLogger<$Loggable>{ id=$id }";
  }
}

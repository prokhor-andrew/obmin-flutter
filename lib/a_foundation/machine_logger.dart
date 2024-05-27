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

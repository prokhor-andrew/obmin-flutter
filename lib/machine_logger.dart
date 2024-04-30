final class MachineLogger<Loggable> {
  final void Function(Loggable loggable) log;

  MachineLogger(this.log);
}

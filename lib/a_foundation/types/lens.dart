final class Lens<Whole, Part> {
  final Part Function(Whole whole) get;
  final Whole Function(Whole whole, Part part) put;

  Lens({
    required this.get,
    required this.put,
  });
}

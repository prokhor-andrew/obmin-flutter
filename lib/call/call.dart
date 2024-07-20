// Copyright (c) 2024 Andrii Prokhorenko
// This file is part of Obmin, licensed under the MIT License.
// See the LICENSE file in the project root for license information.



sealed class Call<Req, Res> {
  const Call();

  @override
  String toString() {
    switch (this) {
      case Launched<Req, Res>(value: var value):
        return "Launched<$Req, $Res> { value=$value }";
      case Returned<Req, Res>(value: var value):
        return "Returned<$Req, $Res> { value=$value }";
    }
  }
}

final class Launched<Req, Res> extends Call<Req, Res> {
  final Req value;

  const Launched(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Launched<Req, Res> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

final class Returned<Req, Res> extends Call<Req, Res> {
  final Res value;

  const Returned(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Returned<Req, Res> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

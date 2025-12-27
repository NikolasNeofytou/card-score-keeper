/// Card suits in Tichu
enum Suit {
  jade,
  sword,
  pagoda,
  star;

  String get symbol {
    switch (this) {
      case Suit.jade:
        return '🟢';
      case Suit.sword:
        return '⚔️';
      case Suit.pagoda:
        return '🏯';
      case Suit.star:
        return '⭐';
    }
  }
}

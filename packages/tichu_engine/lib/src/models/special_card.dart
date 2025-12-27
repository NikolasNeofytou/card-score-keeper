/// Special cards in Tichu
enum SpecialCard {
  mahjong,  // 1 - Always leads, wish for a rank
  dog,      // 0 - Passes turn to partner
  phoenix,  // 1.5 - Wild card, -25 points
  dragon;   // Highest card, +25 points, but loses to Tichu

  int get sortOrder {
    switch (this) {
      case SpecialCard.dog:
        return 0;
      case SpecialCard.mahjong:
        return 1;
      case SpecialCard.phoenix:
        return 15; // Between Ace and Dragon
      case SpecialCard.dragon:
        return 16;
    }
  }

  String get symbol {
    switch (this) {
      case SpecialCard.mahjong:
        return '🀄';
      case SpecialCard.dog:
        return '🐕';
      case SpecialCard.phoenix:
        return '🦅';
      case SpecialCard.dragon:
        return '🐉';
    }
  }

  String get name {
    switch (this) {
      case SpecialCard.mahjong:
        return 'Mahjong';
      case SpecialCard.dog:
        return 'Dog';
      case SpecialCard.phoenix:
        return 'Phoenix';
      case SpecialCard.dragon:
        return 'Dragon';
    }
  }
}

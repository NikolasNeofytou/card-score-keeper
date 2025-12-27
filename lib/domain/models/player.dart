// lib/domain/models/player.dart
class Player {
  final String id;
  final String name;

  const Player({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  static Player fromJson(Map<String, dynamic> json) =>
      Player(id: json['id'] as String, name: json['name'] as String);
}

class Room {
  final String id;
  final String name;
  final List<String> users;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.name,
    required this.users,
    required this.createdAt,
  });

  bool userJoined(String userId) => users.contains(userId);

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      users: List<String>.from(map['users'] ?? []),
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'users': users,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

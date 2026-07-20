class Photo {
  final String id;
  final String name;
  final String base64;
  final String type;
  final int size;
  final DateTime createdAt;

  const Photo({
    required this.id,
    required this.name,
    required this.base64,
    required this.type,
    required this.size,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'base64': base64,
      'type': type,
      'size': size,
      'createdAt': createdAt.toString(),
    };
  }

  factory Photo.fromMap(String id, Map<dynamic, dynamic> map) {
    return Photo(
      id: id,
      name: map['name'] ?? '',
      base64: map['base64'] ?? '',
      type: map['type'] ?? '',
      size: map['size'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

class Task {
  final int? id;
  final String title;
  final bool isDone;
  final String createdAt;

  Task({
    this.id,
    required this.title,
    this.isDone = false,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Task copyWith({
    int? id, 
    String? title, 
    bool? isDone,
    String? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
        'id': id,
        'title': title,
        'isDone': isDone ? 1 : 0,
        'createdAt': createdAt,
      };
    }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      title: map['title'] as String,
      isDone: (map['isDone'] as int) == 1,
      createdAt: map['createdAt'] as String,
    );
  }
}

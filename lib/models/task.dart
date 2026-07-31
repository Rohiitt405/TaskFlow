class Task {
  Task({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  final String id;
  String title;
  bool isDone;

  Task copyWith({String? id, String? title, bool? isDone}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'isDone': isDone,
      };

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: map['title'] as String? ?? '',
      isDone: map['isDone'] as bool? ?? false,
    );
  }
}

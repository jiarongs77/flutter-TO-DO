class Task {
  int id;
  String title;
  String description;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'is_done': isDone ? 1 : 0, // Store boolean as int
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isDone: _parseBool(json['is_done']), // Use flexible boolean conversion
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is int) {
      return value != 0; // Non-zero integers are considered true
    }
    if (value is String) {
      return value.toLowerCase() == 'true' || value.toLowerCase() == 'yes';
    }
    // Default to false if the value is none of the above
    return false;
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, description: $description, isDone: $isDone}';
  }
}
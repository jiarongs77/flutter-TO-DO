class Task {
  int id;
  String title;
  String description;
  bool isDone;

  Task({required this.id, required this.title, required this.description, this.isDone = false});

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
      isDone: json['is_done'] == 1, // Convert int to boolean
    );
  }

  @override
  String toString() {
    return 'Task{id: $id, title: $title, description: $description, isDone: $isDone}';
  }
}

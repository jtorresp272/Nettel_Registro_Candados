class Note {
  final int id;
  final String title;
  final dynamic description;

  const Note(
      {required this.id, required this.title, required this.description});

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
      };
}

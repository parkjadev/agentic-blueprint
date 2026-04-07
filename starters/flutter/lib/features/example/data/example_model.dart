/// Example project model matching the Next.js projects table.
class ExampleProject {
  const ExampleProject({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.ownerId,
  });

  final String id;
  final String name;
  final String? description;
  final String? ownerId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ExampleProject.fromJson(Map<String, dynamic> json) {
    return ExampleProject(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      ownerId: json['ownerId'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
    };
  }
}

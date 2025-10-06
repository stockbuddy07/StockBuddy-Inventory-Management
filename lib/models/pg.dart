class PG {
  final String id;
  final String name;

  PG({required this.id, required this.name});
  factory PG.fromMap(String id, Map<String, dynamic> map) => PG(id: id, name: map['name']);
  Map<String, dynamic> toMap() => {'name': name};
}

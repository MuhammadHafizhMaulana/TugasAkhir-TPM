class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? favorite;
  final String createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.favorite = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'favorite': favorite,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      favorite: map['favorite'],
      createdAt: map['created_at'],
    );
  }
}

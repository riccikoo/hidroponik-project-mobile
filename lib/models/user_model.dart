class User {
  final String? id;
  final String name;
  final String email;
  final String? token;
  // 🔑 Fields updated/added to match the Python model and new requirements
  final String? role; 
  final String? status; 
  final String? createdAt; // New field for creation time
  final String? updatedAt; // New field for update time

  User({
    this.id,
    required this.name,
    required this.email,
    this.token,
    // 🔑 Required in constructor (assuming optional for now based on '?' in declaration)
    this.role, 
    this.status, 
    this.createdAt, // Include new field
    this.updatedAt, // Include new field
  });

  // --- fromJson: Reads data from the API response ---
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      token: json['token'],
      // 🔑 Reading the fields from JSON, including the new ones
      role: json['role']?.toString(), 
      status: json['status']?.toString(),
      createdAt: json['create_at']?.toString(), // Reading from 'created_at'
      updatedAt: json['updated_at']?.toString(), // Reading from 'updated_at'
    );
  }

  // --- toJson: Converts the model back to a Map for saving/sending ---
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
      // 🔑 Including the new fields in the JSON map
      'role': role,
      'status': status,
      'create_at': createdAt, // Using 'created_at' key
      'updated_at': updatedAt, // Using 'updated_at' key
    };
  }
}
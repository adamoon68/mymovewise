class User {
  String? id;
  String? name;
  String? email;
  String? password;
  String? phone;
  // MMR-F-01-03: Critical field for safety filtering logic
  String? chronicCondition; 
  String? role; // 'user' or 'admin'
  String? datereg;

  User({
    this.id,
    this.name,
    this.email,
    this.password,
    this.phone,
    this.chronicCondition,
    this.role,
    this.datereg,
  });

  // Adapted from PawPal's JSON structure style
  User.fromJson(Map<String, dynamic> json) {
    id = json['user_id'];
    name = json['user_name'];
    email = json['user_email'];
    password = json['user_password'];
    phone = json['user_phone'];
    // Ensures the app knows if the user has a safety requirement
    chronicCondition = json['chronic_condition']; 
    role = json['user_role'] ?? 'user';
    datereg = json['user_datereg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = id;
    data['user_name'] = name;
    data['user_email'] = email;
    data['user_password'] = password;
    data['user_phone'] = phone;
    data['chronic_condition'] = chronicCondition;
    data['user_role'] = role;
    data['user_datereg'] = datereg;
    return data;
  }
}
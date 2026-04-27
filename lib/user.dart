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
  int wellnessPoints = 0;
  int comfortStreak = 0;
  String? lastQuestClaim;

  User({
    this.id,
    this.name,
    this.email,
    this.password,
    this.phone,
    this.chronicCondition,
    this.role,
    this.datereg,
    this.wellnessPoints = 0,
    this.comfortStreak = 0,
    this.lastQuestClaim,
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
    wellnessPoints = int.tryParse(json['wellness_points'].toString()) ?? 0;
    comfortStreak = int.tryParse(json['comfort_streak'].toString()) ?? 0;
    lastQuestClaim = json['last_quest_claim'];
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
    data['wellness_points'] = wellnessPoints;
    data['comfort_streak'] = comfortStreak;
    data['last_quest_claim'] = lastQuestClaim;
    return data;
  }
}

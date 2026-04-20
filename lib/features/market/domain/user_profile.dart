class UserProfile {
  const UserProfile({
    required this.email,
    this.nickname = '',
    this.gender = '',
    this.shoeSize = '',
    this.topSize = '',
    this.bottomSize = '',
    this.heightCm = '',
    this.region = '',
    this.preferredCategories = const [],
  });

  final String email;
  final String nickname;
  final String gender;
  final String shoeSize;
  final String topSize;
  final String bottomSize;
  final String heightCm;
  final String region;
  final List<String> preferredCategories;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      shoeSize: json['shoeSize'] as String? ?? '',
      topSize: json['topSize'] as String? ?? '',
      bottomSize: json['bottomSize'] as String? ?? '',
      heightCm: json['heightCm'] as String? ?? '',
      region: json['region'] as String? ?? '',
      preferredCategories: ((json['preferredCategories'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
    );
  }

  bool get isComplete =>
      nickname.trim().isNotEmpty &&
      gender.trim().isNotEmpty &&
      shoeSize.trim().isNotEmpty &&
      topSize.trim().isNotEmpty &&
      bottomSize.trim().isNotEmpty;

  UserProfile copyWith({
    String? email,
    String? nickname,
    String? gender,
    String? shoeSize,
    String? topSize,
    String? bottomSize,
    String? heightCm,
    String? region,
    List<String>? preferredCategories,
  }) {
    return UserProfile(
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      gender: gender ?? this.gender,
      shoeSize: shoeSize ?? this.shoeSize,
      topSize: topSize ?? this.topSize,
      bottomSize: bottomSize ?? this.bottomSize,
      heightCm: heightCm ?? this.heightCm,
      region: region ?? this.region,
      preferredCategories: preferredCategories ?? this.preferredCategories,
    );
  }
}

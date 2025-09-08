class ProfileModel {
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final int? age;
  final double? height; // in cm
  final double? weight; // in kg
  final String? bloodGroup;
  final String? gender;
  ProfileModel(
      {required this.name,
      required this.email,
      required this.phone,
      required this.photoUrl,
      this.age,
      this.height,
      this.weight,
      this.bloodGroup,
      this.gender});

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      age: map['age'] ?? '',
      height: map['height'] ?? '',
      weight: map['weight'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      gender: map['gender'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'age': age,
      'height': height,
      'weight': weight,
      'bloodGroup': bloodGroup,
    };
  }
}

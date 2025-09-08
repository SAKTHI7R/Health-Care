// profile_event.dart

import '../models/profile_model.dart';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class LoadUserProfile extends ProfileEvent {
  final String uid;
  LoadUserProfile(this.uid);
}

class UpdateProfile extends ProfileEvent {
  final ProfileModel profile;
  UpdateProfile(this.profile);
}

class InternalProfileUpdated extends ProfileEvent {
  final Map<String, dynamic> data;
  InternalProfileUpdated(this.data);
}

class SaveUserProfile extends ProfileEvent {
  final String name;
  final String phone;
  final String? photoUrl;
  final int? age;
  final double? height;
  final double? weight;
  final String? bloodGroup;
  final String? gender;

  SaveUserProfile({
    required this.name,
    required this.phone,
    this.photoUrl,
    this.age,
    this.height,
    this.weight,
    this.bloodGroup,
    this.gender,
  });
}

class DeleteUserProfile extends ProfileEvent {
  final String uid;
  DeleteUserProfile(this.uid);
}

class LogoutRequested extends ProfileEvent {}

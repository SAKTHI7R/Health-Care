// lib/profile/bloc/profile_bloc.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/profile_model.dart';
import '../repository/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(ProfileInitial()) {
    on<LoadUserProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final data = await profileRepository.getUserProfile();
        if (data == null) throw Exception("Profile not found.");
        final profile = ProfileModel.fromMap(data);
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<SaveUserProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        await profileRepository.saveUserProfile(
          name: event.name,
          phone: event.phone,
          photoUrl: event.photoUrl,
          age: event.age,
          height: event.height,
          weight: event.weight,
          bloodGroup: event.bloodGroup,
          gender: event.gender,
        );

        final data = await profileRepository.getUserProfile();
        final profile = ProfileModel.fromMap(data!);
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileError("Failed to save profile: ${e.toString()}"));
      }
    });

    on<DeleteUserProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await profileRepository.deleteUserProfile(uid);
        emit(ProfileDeleted());
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<UpdateProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        // final uid = FirebaseAuth.instance.currentUser!.uid;
        await profileRepository.saveUserProfile(
          name: event.profile.name,
          phone: event.profile.phone,
          photoUrl: event.profile.photoUrl,
          age: event.profile.age,
          height: event.profile.height,
          weight: event.profile.weight,
          bloodGroup: event.profile.bloodGroup,
          gender: event.profile.gender,
        );
        emit(ProfileLoaded(event.profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });
  }
}

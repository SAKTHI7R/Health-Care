import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../profile/bloc/profile_bloc.dart';
import '../../profile/bloc/profile_event.dart';
import '../../profile/bloc/profile_state.dart';
import '../../profile/repository/storage_repository.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _selectedImage;
  String? _existingPhotoUrl;
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _selectedBloodGroup;
  String? _selectedGender;

  final List<String> _genders = [
    'Male',
    'Female',
    'Other',
  ];

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  final _storageRepo = StorageRepository();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<ProfileBloc>().add(LoadUserProfile(uid));
    }
  }

  Future<void> _pickImage() async {
    final file = await _storageRepo.pickImageFromGallery();
    if (file != null) {
      setState(() => _selectedImage = file);
    }
  }

  void _saveProfile() async {
    String? photoUrl = _existingPhotoUrl;

    if (_selectedImage != null) {
      final uploadedUrl =
          await _storageRepo.uploadProfilePicture(_selectedImage!);
      if (uploadedUrl.isNotEmpty) {
        photoUrl = uploadedUrl;
      }
    }

    final int? age = int.tryParse(_ageController.text.trim());
    final double? height = double.tryParse(_heightController.text.trim());
    final double? weight = double.tryParse(_weightController.text.trim());

    // ✅ Safe check before using context
    if (age == null || height == null || weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please enter valid numeric values for age, height, and weight.')),
      );
      return; // Prevent submission if any value is invalid
    }
    context.read<ProfileBloc>().add(
          SaveUserProfile(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            photoUrl: _selectedImage != null ? photoUrl : null,
            age: age,
            height: height,
            weight: weight,
            bloodGroup: _selectedBloodGroup.toString(),
            gender: _selectedGender.toString(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        elevation: 1,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded && !_isInitialized) {
            _nameController.text = state.profile.name;
            _phoneController.text = state.profile.phone;
            _existingPhotoUrl = state.profile.photoUrl;
            _ageController.text = state.profile.age?.toString() ?? '';
            _heightController.text = state.profile.height?.toString() ?? '';
            _weightController.text = state.profile.weight?.toString() ?? '';
            _selectedBloodGroup = state.profile.bloodGroup;
            _selectedGender = state.profile.gender;
            _isInitialized = true;
          } else if (state is ProfileInitial) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully!')),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Hero(
                    tag: 'profile-pic-$uid',
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor:
                          const Color(0xFFE0E0E0), // light neutral background
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (_existingPhotoUrl != null
                              ? NetworkImage(_existingPhotoUrl!)
                              : null) as ImageProvider?,
                      child: (_selectedImage == null &&
                              (_existingPhotoUrl == null ||
                                  _existingPhotoUrl!.isEmpty))
                          ? const Icon(Icons.camera_alt,
                              size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _buildTextField(_nameController, "Name"),
                      const Divider(height: 1),
                      _buildTextField(_phoneController, "Phone",
                          keyboardType: TextInputType.phone),
                      const Divider(height: 1),
                      _buildTextField(_ageController, "Age",
                          keyboardType: TextInputType.number),
                      const Divider(height: 1),
                      _buildTextField(_heightController, "Height (cm)",
                          keyboardType: TextInputType.number),
                      const Divider(height: 1),
                      _buildTextField(_weightController, "Weight (kg)",
                          keyboardType: TextInputType.number),
                      const Divider(height: 1),
                      DropdownButtonFormField<String>(
                        value: _bloodGroups.contains(_selectedBloodGroup)
                            ? _selectedBloodGroup
                            : null,
                        decoration: const InputDecoration(
                          labelText: "Blood Group",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        items: _bloodGroups
                            .map((group) => DropdownMenuItem(
                                  value: group,
                                  child: Text(group),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedBloodGroup = value);
                        },
                      ),
                      const Divider(height: 1),
                      DropdownButtonFormField<String>(
                        value: _genders.contains(_selectedGender)
                            ? _selectedGender
                            : null,
                        decoration: const InputDecoration(
                          labelText: "Gender",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        items: _genders
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedGender = value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state is ProfileLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: state is ProfileLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text("Save Changes",
                            style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

Widget _buildTextField(
  TextEditingController controller,
  String label, {
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: InputBorder.none,
    ),
    keyboardType: keyboardType,
  );
}

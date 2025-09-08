import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/profile/bloc/profile_bloc.dart';
import 'package:health_care/profile/bloc/profile_event.dart';
import 'package:health_care/profile/bloc/profile_state.dart';
import 'package:shimmer/shimmer.dart';

import '../auth/bloc/auth_event.dart';
import '../auth/bloc/auth_bloc.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<ProfileBloc>().add(LoadUserProfile(uid));
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Profile'),
        content: const Text(
            'Are you sure you want to delete your account? This action is irreversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<ProfileBloc>().add(DeleteUserProfile(uid));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [],
        ),
        body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFDEE9FF), Color(0xFFE4F1F9)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: BlocConsumer<ProfileBloc, ProfileState>(
                listener: (context, state) {
                  if (!mounted) return;
                  if (state is ProfileDeleted || state is ProfileLoggedOut) {
                    context.go('/login');
                  } else if (state is ProfileError) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return _buildShimmerLoading();
                  } else if (state is ProfileLoaded) {
                    final userData = state.profile;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Hero(
                            tag: 'profile-pic-$uid',
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: userData.photoUrl.isNotEmpty
                                  ? NetworkImage(userData.photoUrl)
                                  : null,
                              backgroundColor: const Color(0xFFE0E0E0),
                              child: userData.photoUrl.isEmpty
                                  ? const Icon(Icons.person,
                                      size: 48, color: Colors.grey)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(236, 255, 255, 255),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _infoTile("Name", userData.name),
                                _infoTile("Email", userData.email),
                                _infoTile("Phone", userData.phone),
                                _infoTile("Age",
                                    userData.age?.toString() ?? 'Not Provided'),
                                _infoTile(
                                    "Height",
                                    userData.height != null
                                        ? '${userData.height} cm'
                                        : 'N/A'),
                                _infoTile(
                                    "Weight",
                                    userData.weight != null
                                        ? '${userData.weight} kg'
                                        : 'N/A'),
                                _infoTile("Blood Group",
                                    userData.bloodGroup ?? 'N/A'),
                                _infoTile("Gender", userData.gender ?? 'N/A'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          _actionButton(
                            context,
                            icon: Icons.edit,
                            label: "Edit Profile",
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );
                              final reloadUid =
                                  FirebaseAuth.instance.currentUser?.uid;
                              if (reloadUid != null) {
                                context
                                    .read<ProfileBloc>()
                                    .add(LoadUserProfile(reloadUid));
                              }
                            },
                            color: const Color(0xFF4B7BE5),
                          ),
                          const SizedBox(height: 12),
                          _actionButton(
                            context,
                            icon: Icons.logout,
                            label: "Logout",
                            onPressed: () {
                              context
                                  .read<AuthBloc>()
                                  .add((SignOutRequested()));
                              context.go('/login');
                            },
                            color: Colors.blueAccent,
                          ),
                          const SizedBox(height: 12),
                          _actionButton(
                            context,
                            icon: Icons.delete,
                            label: "Delete Profile",
                            onPressed: () => _confirmDelete(context),
                            color: Colors.red.shade400,
                          ),
                        ],
                      ),
                    );
                  } else if (state is ProfileError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No profile found. Please complete your profile.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profile'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              ).then((_) {
                                final uid =
                                    FirebaseAuth.instance.currentUser?.uid;
                                if (uid != null) {
                                  context
                                      .read<ProfileBloc>()
                                      .add(LoadUserProfile(uid));
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  } else if (state is ProfileError) {
                    return Center(
                        child: Text('Error loading profile: ${state.message}'));
                  }

                  return const Center(child: Text('Unexpected state.'));
                },
              ),
            )));
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.white,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}

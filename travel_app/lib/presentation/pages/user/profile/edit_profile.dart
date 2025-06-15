import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_app/presentation/pages/user/profile/profile.dart';
import 'dart:io';
import 'dart:convert';
import '../../../../services/user_service.dart';

class EditProfilePage extends StatefulWidget {
  final int userId;
  final String currentName;
  final String currentUsername;
  final String currentEmail;
  final String currentImageUrl;
  final String currentRole;
  final double currentBalance;

  const EditProfilePage({
    Key? key,
    required this.userId,
    required this.currentName,
    required this.currentUsername,
    required this.currentEmail,
    required this.currentImageUrl,
    required this.currentRole,
    required this.currentBalance,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool isSaving = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String imageUrl = '';
  File? imageFile;
  String? base64Image;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    nameController.text = widget.currentName;
    usernameController.text = widget.currentUsername;
    emailController.text = widget.currentEmail;
    imageUrl = widget.currentImageUrl;
  }

  void _resetFormData() {
    setState(() {
      nameController.text = widget.currentName;
      usernameController.text = widget.currentUsername;
      emailController.text = widget.currentEmail;
      imageUrl = widget.currentImageUrl;
      passwordController.clear();
      imageFile = null;
      base64Image = null;
    });
  }

  Future<void> _handleImageUpload() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        final file = File(image.path);
        final fileSize = await file.length();

        if (fileSize > 2 * 1024 * 1024) {
          _showErrorDialog('Ukuran gambar maksimal 2MB');
          return;
        }

        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);

        setState(() {
          imageFile = file;
          base64Image = 'data:image/jpeg;base64,$base64String';
        });

        print('Image selected successfully');
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorDialog('Gagal memilih gambar');
    }
  }

  Future<void> _handleSave() async {
    if (!mounted) return;

    // Validate required fields
    if (nameController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      _showErrorDialog('Nama, username, dan email tidak boleh kosong');
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // Prepare form data
      final formData = <String, dynamic>{
        'name': nameController.text.trim(),
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'role': widget.currentRole,
        'balance': widget.currentBalance.toString(),
      };

      // Only include password if it's provided
      if (passwordController.text.isNotEmpty) {
        formData['password'] = passwordController.text;
      }

      // Add image if selected
      if (base64Image != null) {
        formData['image'] = base64Image;
        print('Sending image data: ${base64Image!.substring(0, 50)}...');
      }

      print('Sending update request with data: ${formData.keys.toList()}');

      final updatedUser =
          await UserService.updateUserProfile(widget.userId, formData);
      print('Update success: ${updatedUser.toJson()}');

      if (!mounted) return;

      // Check if the response is valid
      if (updatedUser.userId <= 0 ||
          updatedUser.name.isEmpty ||
          updatedUser.username.isEmpty ||
          updatedUser.email.isEmpty) {
        print(
            'Warning: Server returned invalid user data, but update likely succeeded');

        // Server response is invalid, but update might have succeeded
        // Update SharedPreferences with our form data to maintain consistency
        final prefs = await SharedPreferences.getInstance();

        // Keep the original userId (don't use the invalid 0 from server)
        final currentUserId = widget.userId;

        // Create updated user data from our form
        final updatedUserData = {
          'userId': currentUserId,
          'name': nameController.text.trim(),
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'role': widget.currentRole,
          'balance': widget.currentBalance,
          'image': base64Image ?? widget.currentImageUrl,
          'password': '', // Don't store password
        };

        // Update SharedPreferences with our corrected data
        await prefs.setInt('userId', currentUserId);
        await prefs.setString('user', json.encode(updatedUserData));

        print('Updated SharedPreferences with corrected user data');

        _showSuccessDialog('Profile berhasil diupdate!', redirect: true);
      } else {
        // Server returned valid data, use it
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', updatedUser.userId);
        await prefs.setString('user', json.encode(updatedUser.toJson()));

        print('Updated SharedPreferences with valid server response');

        _showSuccessDialog('Profile berhasil diupdate!');

        // Return to profile page with success flag
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      print('Update error: $e');
      if (mounted) {
        setState(() {
          isSaving = false;
        });
        _showErrorDialog('Gagal update profile: ${e.toString()}');
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message, {bool redirect = false}) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Berhasil'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog

              setState(() {
                isSaving = false; // Stop loading
              });

              if (redirect) {
                // Kembali ke halaman sebelumnya dengan flag success
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: GestureDetector(
        onTap: _handleImageUpload,
        child: Stack(
          children: [
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue.shade500,
                  width: 4,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(64),
                child: _buildImage(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    // Priority: 1. New selected image file, 2. Server image URL, 3. Default avatar
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
        width: 128,
        height: 128,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading local image: $error');
          return _buildDefaultAvatar();
        },
      );
    } else if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('data:image')) {
        try {
          final base64String = imageUrl.split(',')[1];
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: 128,
            height: 128,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading base64 image: $error');
              return _buildDefaultAvatar();
            },
          );
        } catch (e) {
          print('Error decoding base64 image: $e');
          return _buildDefaultAvatar();
        }
      } else if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading network image: $error');
            return _buildDefaultAvatar();
          },
        );
      }
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 128,
      height: 128,
      color: Colors.grey.shade300,
      child: Icon(
        Icons.person,
        size: 64,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue.shade500),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E40AF),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1E40AF),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileImage(),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildFormField(
                      label: 'Username',
                      controller: usernameController,
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'Full Name',
                      controller: nameController,
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'Email',
                      controller: emailController,
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'New Password (Optional)',
                      controller: passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSaving ? null : _handleSave,
                        icon: isSaving
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save, size: 20),
                        label: Text(
                          isSaving ? 'Saving...' : 'Save Profile',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    if (!isSaving) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _resetFormData,
                          child: const Text('Reset Changes'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

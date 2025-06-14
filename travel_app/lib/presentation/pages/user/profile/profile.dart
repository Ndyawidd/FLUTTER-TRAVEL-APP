import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

// Import your service classes
import '../../../../services/user_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? userId;
  bool isEditing = false;
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String imageUrl = '';
  File? imageFile;
  String role = '';
  double balance = 0.0;

  final ImagePicker _picker = ImagePicker();

  // Helper method untuk format mata uang
  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');

      print('SharedPreferences user data: $userString'); // Debug log

      if (userString != null) {
        final userData = json.decode(userString);
        print('Decoded user data: $userData'); // Debug log

        // Try different possible keys for userId
        userId = userData['userId'] ?? userData['id'] ?? userData['user_id'];
        print('Extracted userId: $userId'); // Debug log

        if (userId != null) {
          await _fetchUserDetails();
        } else {
          print('No userId found in stored data');
          // Set mock data for testing
          _setMockData();
        }
      } else {
        print('No user data found in SharedPreferences');
        // Set mock data for testing
        _setMockData();
      }
    } catch (e) {
      print('Error loading user data: $e');
      _setMockData(); // Fallback to mock data
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _setMockData() {
    setState(() {
      nameController.text = 'John Doe';
      usernameController.text = 'johndoe';
      emailController.text = 'john@example.com';
      role = 'user';
      imageUrl = '';
      balance = 150000.0;
    });
    print('Mock data set for testing');
  }

  Future<void> _fetchUserDetails() async {
    if (userId == null) return;

    try {
      print('Fetching user details for userId: $userId'); // Debug log
      final user = await UserService.getUserById(userId!);
      print('API Response - User data: ${user.toJson()}'); // Debug log

      setState(() {
        nameController.text = user.name;
        usernameController.text = user.username;
        emailController.text = user.email;
        role = user.role;
        imageUrl = user.image ?? '';
        balance = user.balance;
      });

      print('UI Updated with user data'); // Debug log
    } catch (e) {
      print('Error fetching user details: $e');
      // Don't show error dialog, just use mock data for now
      _setMockData();
    }
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

        // Check file size (2MB limit)
        if (fileSize > 2 * 1024 * 1024) {
          _showErrorDialog('Ukuran gambar maksimal 2MB');
          return;
        }

        setState(() {
          imageFile = file;
          imageUrl = file.path; // For local preview
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorDialog('Failed to pick image');
    }
  }

  Future<void> _handleSave() async {
    if (userId == null) return;

    try {
      // Prepare form data
      final formData = <String, dynamic>{
        'name': nameController.text,
        'username': usernameController.text,
        'email': emailController.text,
        'role': role,
        'password': passwordController.text,
        'balance': balance.toString(),
      };

      // Add image if selected
      if (imageFile != null) {
        final bytes = await imageFile!.readAsBytes();
        final base64Image = base64Encode(bytes);
        formData['imageFile'] = 'data:image/jpeg;base64,$base64Image';
      }

      final updatedUser =
          await UserService.updateUserProfile(userId!, formData);

      print('Update success: ${updatedUser.toJson()}');
      _showSuccessDialog('Profile updated!');

      setState(() {
        isEditing = false;
        passwordController.clear(); // Clear password field after save
        // Update local data with response
        balance = updatedUser.balance;
        imageUrl = updatedUser.image ?? '';
      });
    } catch (e) {
      print('Update error: $e');
      _showErrorDialog('Gagal update profile');
    }
  }

  Future<void> _handleDelete() async {
    if (userId == null) return;

    final confirmed = await _showConfirmDialog(
      'Konfirmasi Hapus',
      'Are you sure you want to delete your account?',
    );

    if (!confirmed) return;

    try {
      await UserService.deleteUser(userId!);

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _showSuccessDialog('Account deleted.');

      // Navigate to login page
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      print('Failed to delete user: $e');
      _showErrorDialog('Failed to delete account.');
    }
  }

  void _navigateToAddSaldo() {
    Navigator.of(context).pushNamed('/profile/addSaldo');
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showErrorDialog(String message) {
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
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

  Widget _buildProfileImage() {
    return Center(
      child: GestureDetector(
        onTap: isEditing ? _handleImageUpload : null,
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
            if (isEditing)
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
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
      );
    } else if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
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
        if (isEditing)
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
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              controller.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E40AF),
                ),
              ),
              const SizedBox(height: 32),

              // Profile Image
              _buildProfileImage(),
              const SizedBox(height: 32),

              // Form Container
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

                    // Debug info - remove this later
                    if (!isEditing) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Debug Info:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('UserId: $userId'),
                            Text('Name: ${nameController.text}'),
                            Text('Username: ${usernameController.text}'),
                            Text('Email: ${emailController.text}'),
                            Text('Balance: $balance'),
                          ],
                        ),
                      ),
                    ],

                    if (isEditing) ...[
                      _buildFormField(
                        label: 'New Password',
                        controller: passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isEditing
                            ? _handleSave
                            : () => setState(() => isEditing = true),
                        icon: Icon(
                          isEditing ? Icons.save : Icons.edit,
                          size: 20,
                        ),
                        label: Text(
                          isEditing ? 'Save Profile' : 'Edit Profile',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEditing
                              ? Colors.blue.shade600
                              : Colors.blue.shade300,
                          foregroundColor:
                              isEditing ? Colors.white : Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo Anda',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade100,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatCurrency(balance),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    FloatingActionButton(
                      onPressed: _navigateToAddSaldo,
                      backgroundColor: Colors.orange.shade500,
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Delete Account Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleDelete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Delete Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

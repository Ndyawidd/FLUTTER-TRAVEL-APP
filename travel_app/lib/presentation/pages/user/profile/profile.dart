import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../../../../services/user_service.dart';
import 'package:travel_app/routes/app_routes.dart';

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
  String? base64Image; // Store base64 image separately
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
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      print('SharedPreferences userId: $userId');

      if (userId != null) {
        this.userId = userId;
        await _fetchUserDetails();
      } else {
        throw Exception('No userId found in SharedPreferences');
      }
    } catch (e) {
      print('Error loading user data: $e');
      _showErrorDialog('Gagal memuat data user. Silakan login kembali.');
      _redirectToLogin();
    }
  }

  Future<void> _fetchUserDetails() async {
    if (userId == null) return;

    try {
      print('Fetching user details for userId: $userId');
      final user = await UserService.getUserById(userId!);
      print('API Response - User data: ${user.toJson()}');

      setState(() {
        nameController.text = user.name;
        usernameController.text = user.username;
        emailController.text = user.email;
        role = user.role;
        imageUrl = user.image ?? '';
        balance = user.balance;
        isLoading = false;
        // Reset file and base64 when fetching fresh data
        imageFile = null;
        base64Image = null;
      });

      print('UI Updated with user data successfully');
      print('Image URL from API: $imageUrl');
    } catch (e) {
      print('Error fetching user details: $e');
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Gagal memuat detail user dari server.');
    }
  }

  void _redirectToLogin() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.clear();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    });
  }

  Future<void> _handleLogout() async {
    final confirmed = await _showConfirmDialog(
      'Konfirmasi Logout',
      'Apakah Anda yakin ingin keluar dari aplikasi?',
    );

    if (!confirmed) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      _showErrorDialog('Gagal logout. Silakan coba lagi.');
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

        // Convert to base64 for upload
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);

        setState(() {
          imageFile = file;
          base64Image = 'data:image/jpeg;base64,$base64String';
        });

        print('Image selected successfully');
        print('File path: ${file.path}');
        print('Base64 length: ${base64String.length}');
      }
    } catch (e) {
      print('Error picking image: $e');
      _showErrorDialog('Gagal memilih gambar');
    }
  }

  Future<void> _handleSave() async {
    if (userId == null) return;

    // Validate required fields
    if (nameController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      _showErrorDialog('Nama, username, dan email tidak boleh kosong');
      return;
    }

    // Show loading
    setState(() {
      isLoading = true;
    });

    try {
      // Prepare form data
      final formData = <String, dynamic>{
        'name': nameController.text.trim(),
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'role': role,
        'balance': balance.toString(),
      };

      // Only include password if it's provided
      if (passwordController.text.isNotEmpty) {
        formData['password'] = passwordController.text;
      }

      // Add image if selected (use base64Image instead of imageFile)
      if (base64Image != null) {
        formData['image'] = base64Image;
        print('Sending image data: ${base64Image!.substring(0, 50)}...');
      }

      final updatedUser =
          await UserService.updateUserProfile(userId!, formData);

      print('Update success: ${updatedUser.toJson()}');

      // Update SharedPreferences with new user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', updatedUser.userId);
      await prefs.setString('user', json.encode(updatedUser.toJson()));

      setState(() {
        isEditing = false;
        passwordController.clear();
        balance = updatedUser.balance;
        imageUrl = updatedUser.image ?? '';
        isLoading = false;
        // Clear temporary image data after successful update
        imageFile = null;
        base64Image = null;
      });

      _showSuccessDialog('Profile berhasil diupdate!');
    } catch (e) {
      print('Update error: $e');
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Gagal update profile: $e');
    }
  }

  Future<void> _handleDelete() async {
    if (userId == null) return;

    final confirmed = await _showConfirmDialog(
      'Konfirmasi Hapus',
      'Apakah Anda yakin ingin menghapus akun ini? Tindakan ini tidak dapat dibatalkan.',
    );

    if (!confirmed) return;

    setState(() {
      isLoading = true;
    });

    try {
      await UserService.deleteUser(userId!);

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _showSuccessDialog('Akun berhasil dihapus.');

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      print('Failed to delete user: $e');
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Gagal menghapus akun: $e');
    }
  }

  void _navigateToAddSaldo() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.topup);

    if (result == true) {
      _loadUserData();
    }
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
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Konfirmasi',
                    style: TextStyle(color: Colors.red)),
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
        title: const Text('Berhasil'),
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
    print('Building image widget...');
    print('imageFile: $imageFile');
    print('base64Image: ${base64Image != null ? 'Present' : 'Null'}');
    print('imageUrl: $imageUrl');

    // Priority: 1. New selected image file, 2. Server image URL, 3. Default avatar
    if (imageFile != null) {
      print('Displaying local file image');
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
      print('Displaying network image: $imageUrl');
      // Handle both HTTP URLs and base64 data URLs
      if (imageUrl.startsWith('data:image')) {
        // It's a base64 data URL
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
        // It's a regular HTTP URL
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading network image: $error');
            return _buildDefaultAvatar();
          },
        );
      }
    }

    print('Displaying default avatar');
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            tooltip: 'Logout',
          ),
        ],
      ),
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

                    if (isEditing) ...[
                      _buildFormField(
                        label: 'New Password (Optional)',
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

                    // Cancel button when editing
                    if (isEditing) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              isEditing = false;
                              passwordController.clear();
                              // Reset image selection
                              imageFile = null;
                              base64Image = null;
                            });
                            // Reset form data
                            _fetchUserDetails();
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
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

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout, size: 20),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

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

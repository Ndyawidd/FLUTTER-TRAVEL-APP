import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../services/user_service.dart';
import 'package:travel_app/routes/app_routes.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int? userId;
  bool isLoading = true;
  bool isRefreshing = false;

  String name = '';
  String username = '';
  String email = '';
  String imageUrl = '';
  String role = '';
  double balance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getInt('userId');

      if (storedUserId != null && storedUserId > 0) {
        userId = storedUserId;
        await _fetchUserDetails();
      } else {
        _handleAuthError('Session expired. Please login again.');
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _handleAuthError('Failed to load user data. Please login again.');
    }
  }

  Future<void> _fetchUserDetails() async {
    if (userId == null || userId! <= 0 || !mounted) return;

    try {
      final user = await UserService.getUserById(userId!);

      if (_isValidUserData(user)) {
        await _updateUserData(user);
      } else {
        // Try fallback from SharedPreferences
        await _loadFromSharedPreferences();
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      // Try fallback from SharedPreferences
      await _loadFromSharedPreferences();
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isRefreshing = false;
        });
      }
    }
  }

  bool _isValidUserData(dynamic user) {
    return user != null &&
        user.userId > 0 &&
        user.name.isNotEmpty &&
        user.username.isNotEmpty &&
        user.email.isNotEmpty;
  }

  Future<void> _updateUserData(dynamic user) async {
    if (!mounted) return;

    setState(() {
      name = user.name ?? '';
      username = user.username ?? '';
      email = user.email ?? '';
      role = user.role ?? '';
      imageUrl = user.image ?? '';
      balance = (user.balance ?? 0.0).toDouble();
    });

    // Update SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(user.toJson()));
  }

  Future<void> _loadFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');

      if (userJson != null) {
        final userData = json.decode(userJson);

        if (mounted) {
          setState(() {
            name = userData['name'] ?? '';
            username = userData['username'] ?? '';
            email = userData['email'] ?? '';
            role = userData['role'] ?? '';
            imageUrl = userData['image'] ?? '';
            balance = (userData['balance'] ?? 0.0).toDouble();
          });
        }
      } else {
        _handleAuthError('No user data found. Please login again.');
      }
    } catch (e) {
      debugPrint('Error loading from SharedPreferences: $e');
      _handleAuthError('Failed to load user data. Please login again.');
    }
  }

  void _handleAuthError(String message) {
    if (!mounted) return;

    _showErrorDialog(message, onConfirm: _redirectToLogin);
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

  Future<void> _refreshData() async {
    if (isRefreshing) return;

    setState(() {
      isRefreshing = true;
    });

    await _fetchUserDetails();
  }

  Future<void> _handleLogout() async {
    final confirmed = await _showConfirmDialog(
      'Confirm Logout',
      'Are you sure you want to logout?',
    );

    if (!confirmed) return;

    _showLoadingDialog();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog('Failed to logout. Please try again.');
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    if (userId == null || userId! <= 0) return;

    final confirmed = await _showConfirmDialog(
      'Delete Account',
      'Are you sure you want to delete your account? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (!confirmed) return;

    _showLoadingDialog();

    try {
      await UserService.deleteUser(userId!);

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showSuccessDialog('Account deleted successfully.', onConfirm: () {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        });
      }
    } catch (e) {
      debugPrint('Failed to delete user: $e');
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorDialog('Failed to delete account: ${e.toString()}');
      }
    }
  }

  void _navigateToTopUp() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.topup);
    if (result == true && mounted) {
      _refreshData();
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          userId: userId!,
          currentName: name,
          currentUsername: username,
          currentEmail: email,
          currentImageUrl: imageUrl,
          currentRole: role,
          currentBalance: balance,
        ),
      ),
    );

    if (result == true && mounted) {
      _refreshData();
    }
  }

  // Dialog Methods
  void _showLoadingDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Please wait...'),
          ],
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog(
    String title,
    String message, {
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    if (!mounted) return false;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  confirmText,
                  style: TextStyle(
                    color: isDestructive ? Colors.red : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showErrorDialog(String message, {VoidCallback? onConfirm}) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message, {VoidCallback? onConfirm}) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm?.call();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // UI Builder Methods
  Widget _buildProfileImage() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.blue.shade500,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60),
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('data:image')) {
        try {
          final base64String = imageUrl.split(',')[1];
          final bytes = base64Decode(base64String);
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: 120,
            height: 120,
            errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
          );
        } catch (e) {
          debugPrint('Error decoding base64 image: $e');
          return _buildDefaultAvatar();
        }
      } else if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: 120,
          height: 120,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
        );
      }
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: 60,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoField('Username', username, Icons.alternate_email),
          const SizedBox(height: 16),
          _buildInfoField('Full Name', name, Icons.person),
          const SizedBox(height: 16),
          _buildInfoField('Email', email, Icons.email),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToEditProfile,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isEmpty ? 'Not set' : value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: value.isEmpty ? Colors.grey.shade400 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Balance',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade100,
                    fontWeight: FontWeight.w500,
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
          ),
          FloatingActionButton(
            onPressed: _navigateToTopUp,
            backgroundColor: Colors.orange.shade500,
            heroTag: "topup_fab",
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _handleDeleteAccount,
            icon: const Icon(Icons.delete_forever, size: 18),
            label: const Text('Delete Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E40AF),
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: _refreshData,
        //     icon: isRefreshing
        //         ? const SizedBox(
        //             width: 20,
        //             height: 20,
        //             child: CircularProgressIndicator(strokeWidth: 2),
        //           )
        //         : const Icon(Icons.refresh),
        //     tooltip: 'Refresh',
        //   ),
        // ],
      ),  
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProfileImage(),
                const SizedBox(height: 24),
                _buildInfoCard(),
                const SizedBox(height: 20),
                _buildBalanceCard(),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

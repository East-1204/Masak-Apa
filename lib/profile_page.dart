import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:masakapa/database_helper.dart';
import 'package:masakapa/models.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _currentUser;
  int _favoriteCount = 0;
  bool _isEditing = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await DatabaseHelper.getCurrentUser();
    final favorites = await DatabaseHelper.getFavoriteRecipes();
    
    setState(() {
      _currentUser = user;
      _favoriteCount = favorites.length;
      if (user != null) {
        _usernameController.text = user.username;
        _emailController.text = user.email;
      }
    });
  }

  Future<void> _saveProfile() async {
    if (_currentUser == null) return;

    final updatedUser = _currentUser!.copyWith(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
    );

    await DatabaseHelper.saveUser(updatedUser);
    await DatabaseHelper.setCurrentUser(updatedUser);

    setState(() {
      _currentUser = updatedUser;
      _isEditing = false;
    });

    Fluttertoast.showToast(msg: 'Profil berhasil diperbarui');
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.logout();
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/', 
                  (route) => false
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 30, color: const Color(0xFFFF5722)),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? const Color(0xFFFF5722)).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor ?? const Color(0xFFFF5722)),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final memberSince = _currentUser!.createdAt;
    final formattedDate = '${memberSince.day}/${memberSince.month}/${memberSince.year}';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Text(
                            _currentUser!.username.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF5722),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _currentUser!.username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentUser!.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isEditing ? Icons.check : Icons.edit,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (_isEditing) {
                    _saveProfile();
                  } else {
                    setState(() => _isEditing = true);
                  }
                },
                tooltip: _isEditing ? 'Simpan' : 'Edit Profil',
              ),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats Cards
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statistik Anda',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildStatCard(Icons.restaurant_menu, 'Total Resep', '5'),
                              const SizedBox(width: 12),
                              _buildStatCard(Icons.favorite, 'Favorit', '$_favoriteCount'),
                              const SizedBox(width: 12),
                              _buildStatCard(Icons.calendar_today, 'Bergabung', formattedDate),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Profile Form (if editing)
                  if (_isEditing)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Edit Profil',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Lengkap',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() => _isEditing = false);
                                      _usernameController.text = _currentUser!.username;
                                      _emailController.text = _currentUser!.email;
                                    },
                                    child: const Text('Batal'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _saveProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF5722),
                                    ),
                                    child: const Text('Simpan'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Menu Items
                  Card(
                    child: Column(
                      children: [
                        _buildMenuItem(
                          icon: Icons.settings,
                          title: 'Pengaturan',
                          onTap: () {
                            Fluttertoast.showToast(msg: 'Fitur pengaturan akan segera hadir');
                          },
                        ),
                        const Divider(height: 0),
                        _buildMenuItem(
                          icon: Icons.notifications,
                          title: 'Notifikasi',
                          onTap: () {
                            Fluttertoast.showToast(msg: 'Fitur notifikasi akan segera hadir');
                          },
                        ),
                        const Divider(height: 0),
                        _buildMenuItem(
                          icon: Icons.privacy_tip,
                          title: 'Privasi & Keamanan',
                          onTap: () {
                            Fluttertoast.showToast(msg: 'Fitur privasi akan segera hadir');
                          },
                        ),
                        const Divider(height: 0),
                        _buildMenuItem(
                          icon: Icons.help,
                          title: 'Bantuan & Dukungan',
                          onTap: () {
                            Fluttertoast.showToast(msg: 'Fitur bantuan akan segera hadir');
                          },
                        ),
                        const Divider(height: 0),
                        _buildMenuItem(
                          icon: Icons.info,
                          title: 'Tentang Aplikasi',
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Tentang MasakApa?'),
                                content: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Versi: 1.0.0'),
                                    SizedBox(height: 8),
                                    Text('Pengembang: Roy Yogi Saputra'),
                                    SizedBox(height: 8),
                                    Text('NPM: 23670085'),
                                    SizedBox(height: 8),
                                    Text('Sistem cerdas rekomendasi resep berdasarkan bahan yang dimiliki'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Tutup'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Keluar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  
                  // Footer
                  Text(
                    'MasakApa? v1.0.0',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '© 2024 Roy Yogi Saputra',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
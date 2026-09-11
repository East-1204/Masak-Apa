import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models.dart';
import 'recommendation_page.dart';
import 'favorite_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await DatabaseHelper.getCurrentUser();
    setState(() {
      _currentUser = user;
    });
  }

  static final List<Widget> _widgetOptions = <Widget>[
    const RecommendationPage(),
    const FavoritePage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.restaurant_menu,
              color: Color(0xFFFF5722),
              size: 28,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MasakApa?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF5722),
                    fontSize: 18,
                  ),
                ),
                if (_currentUser != null)
                  Text(
                    'Halo, ${_currentUser!.username}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey[200],
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {
              // TODO: Implement search
              showSearch(
                context: context,
                delegate: RecipeSearchDelegate(),
              );
            },
            tooltip: 'Cari resep',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {
              // TODO: Implement notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur notifikasi akan segera hadir')),
              );
            },
            tooltip: 'Notifikasi',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorit',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFFF5722),
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class RecipeSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: DatabaseHelper.searchRecipes(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ditemukan resep dengan kata kunci: "$query"',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        final recipes = snapshot.data!;
        
        return ListView.builder(
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF5722).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Color(0xFFFF5722),
                ),
              ),
              title: Text(
                recipe.title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                '${recipe.category} • ${recipe.totalTime} menit • ${recipe.difficulty}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to recipe detail
                close(context, recipe.title);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Kategori Populer',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          FutureBuilder<List<String>>(
            future: DatabaseHelper.getAllCategories(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final categories = snapshot.data!;
              
              return SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 16 : 8,
                        right: index == categories.length - 1 ? 16 : 8,
                      ),
                      child: Chip(
                        label: Text(category),
                        backgroundColor: const Color(0xFFFF5722).withOpacity(0.1),
                        labelStyle: const TextStyle(color: Color(0xFFFF5722)),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Saran Pencarian',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          ...['Nasi Goreng', 'Mie', 'Ayam', 'Sayur', 'Kue'].map((suggestion) {
            return ListTile(
              leading: const Icon(Icons.search, size: 20),
              title: Text(suggestion),
              onTap: () {
                query = suggestion;
                showResults(context);
              },
            );
          }).toList(),
        ],
      );
    }
    
    return FutureBuilder<List<Recipe>>(
      future: DatabaseHelper.searchRecipes(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container();
        }
        
        final recipes = snapshot.data!.take(5).toList();
        
        return ListView(
          children: recipes.map((recipe) {
            return ListTile(
              title: Text(recipe.title),
              subtitle: Text(recipe.category),
              onTap: () {
                query = recipe.title;
                showResults(context);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:masakapa/database_helper.dart';
import 'package:masakapa/models.dart';
import 'recipe_detail_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Recipe> _favoriteRecipes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favorites = await DatabaseHelper.getFavoriteRecipes();
    setState(() {
      _favoriteRecipes = favorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFromFavorites(Recipe recipe) async {
    await DatabaseHelper.toggleFavorite(recipe.id);
    await _loadFavorites();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Favorit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Tambahkan resep ke favorit dengan menekan ikon hati pada halaman detail resep',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to home
              DefaultTabController.of(context).animateTo(0);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5722),
            ),
            child: const Text('Temukan Resep'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailPage(recipe: recipe),
            ),
          );
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Recipe Icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Color(0xFFFF5722),
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Recipe Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.totalTime} menit',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.category, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              recipe.category,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.people, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${recipe.servings} porsi',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Remove button
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                onPressed: () => _removeFromFavorites(recipe),
                tooltip: 'Hapus dari favorit',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF5722)))
          : Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5722).withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Color(0xFFFF5722),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Resep Favorit',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFFFF5722),
                            ),
                          ),
                          Text(
                            '${_favoriteRecipes.length} resep tersimpan',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (_favoriteRecipes.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.delete_sweep),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Semua Favorit'),
                                content: const Text(
                                  'Apakah Anda yakin ingin menghapus semua resep dari favorit?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // TODO: Implement clear all favorites
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Fitur hapus semua akan segera hadir'),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text('Hapus Semua'),
                                  ),
                                ],
                              ),
                            );
                          },
                          tooltip: 'Hapus semua favorit',
                        ),
                    ],
                  ),
                ),
                
                // List of favorites
                Expanded(
                  child: _favoriteRecipes.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadFavorites,
                          color: const Color(0xFFFF5722),
                          child: ListView.builder(
                            itemCount: _favoriteRecipes.length,
                            itemBuilder: (context, index) {
                              return _buildRecipeCard(_favoriteRecipes[index]);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }
}
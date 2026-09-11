import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:masakapa/database_helper.dart';
import 'package:masakapa/models.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  final RecipeRecommendation? recommendation;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
    this.recommendation,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  bool _isFavorite = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final isFav = await DatabaseHelper.isFavorite(widget.recipe.id);
    setState(() => _isFavorite = isFav);
  }

  Future<void> _toggleFavorite() async {
    await DatabaseHelper.toggleFavorite(widget.recipe.id);
    final newStatus = await DatabaseHelper.isFavorite(widget.recipe.id);
    
    setState(() => _isFavorite = newStatus);
    
    Fluttertoast.showToast(
      msg: _isFavorite ? 'Ditambahkan ke favorit' : 'Dihapus dari favorit',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildIngredientItem(String ingredient, int index) {
    final hasIngredient = widget.recommendation?.matchingIngredients
        .any((ing) => ing.toLowerCase() == ingredient.toLowerCase()) ?? false;
    
    return ListTile(
      leading: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: hasIngredient ? Colors.green[50] : Colors.orange[50],
          shape: BoxShape.circle,
          border: Border.all(
            color: hasIngredient ? Colors.green[200]! : Colors.orange[200]!,
          ),
        ),
        child: Icon(
          hasIngredient ? Icons.check : Icons.close,
          size: 16,
          color: hasIngredient ? Colors.green : Colors.orange,
        ),
      ),
      title: Text(
        ingredient,
        style: TextStyle(
          color: hasIngredient ? Colors.green[800] : Colors.orange[800],
        ),
      ),
      trailing: hasIngredient
          ? Chip(
              label: const Text(
                'Tersedia',
                style: TextStyle(fontSize: 11),
              ),
              backgroundColor: Colors.green[100],
              labelStyle: const TextStyle(color: Colors.green),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            )
          : Chip(
              label: const Text(
                'Kurang',
                style: TextStyle(fontSize: 11),
              ),
              backgroundColor: Colors.orange[100],
              labelStyle: const TextStyle(color: Colors.orange),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFFF5722).withOpacity(0.1),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.restaurant_menu,
                        size: 120,
                        color: const Color(0xFFFF5722).withOpacity(0.3),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(
                widget.recipe.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black45,
                    ),
                  ],
                ),
                maxLines: 2,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Score Badge
                  if (widget.recommendation != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5722).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFF5722).withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star, color: Color(0xFFFF5722)),
                              const SizedBox(width: 8),
                              Text(
                                'Kecocokan: ${widget.recommendation!.scorePercentage}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFF5722),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${widget.recommendation!.matchingIngredients.length} dari ${widget.recipe.ingredients.length} bahan tersedia',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                  // Basic Info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfoRow(Icons.timer, '${widget.recipe.totalTime} min'),
                              _buildInfoRow(Icons.people, '${widget.recipe.servings} porsi'),
                              _buildInfoRow(Icons.assessment, widget.recipe.difficulty),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildInfoRow(Icons.category, widget.recipe.category),
                              _buildInfoRow(Icons.local_fire_department, '450 cal'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => setState(() => _selectedTab = 0),
                            style: TextButton.styleFrom(
                              backgroundColor: _selectedTab == 0
                                  ? const Color(0xFFFF5722)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Bahan',
                              style: TextStyle(
                                color: _selectedTab == 0 ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => setState(() => _selectedTab = 1),
                            style: TextButton.styleFrom(
                              backgroundColor: _selectedTab == 1
                                  ? const Color(0xFFFF5722)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cara Masak',
                              style: TextStyle(
                                color: _selectedTab == 1 ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => setState(() => _selectedTab = 2),
                            style: TextButton.styleFrom(
                              backgroundColor: _selectedTab == 2
                                  ? const Color(0xFFFF5722)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Info',
                              style: TextStyle(
                                color: _selectedTab == 2 ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab Content
                  if (_selectedTab == 0)
                    Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Daftar Bahan (${widget.recipe.ingredients.length})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          ...widget.recipe.ingredients.asMap().entries.map(
                            (entry) => _buildIngredientItem(entry.value, entry.key),
                          ),
                        ],
                      ),
                    ),

                  if (_selectedTab == 1)
                    Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Langkah-langkah',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          ...widget.recipe.steps.asMap().entries.map(
                            (entry) => ListTile(
                              leading: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF5722),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(entry.value),
                              minVerticalPadding: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (_selectedTab == 2)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informasi Gizi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.recipe.nutritionInfo.isNotEmpty
                                    ? widget.recipe.nutritionInfo
                                    : 'Informasi gizi tidak tersedia',
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Tags',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: widget.recipe.tags.map((tag) {
                                return Chip(
                                  label: Text(tag),
                                  backgroundColor: Colors.blue[50],
                                  labelStyle: TextStyle(color: Colors.blue[800]),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement share
                            Fluttertoast.showToast(
                              msg: 'Berbagi resep: ${widget.recipe.title}',
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Bagikan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // TODO: Implement shopping list
                            Fluttertoast.showToast(
                              msg: 'Menambahkan ke daftar belanja',
                            );
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Daftar Belanja'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
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
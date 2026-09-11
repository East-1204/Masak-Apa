import 'package:flutter/material.dart';
import 'package:masakapa/database_helper.dart';
import 'package:masakapa/models.dart';
import 'recipe_detail_page.dart';

class RecommendationPage extends StatefulWidget {
  const RecommendationPage({super.key});

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  final TextEditingController _ingredientsController = TextEditingController();
  List<String> _ingredientsList = [];
  List<RecipeRecommendation> _recommendations = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Contoh bahan untuk testing
    _ingredientsController.text = 'nasi, telur, bawang merah, bawang putih, kecap, garam, minyak';
    _updateIngredientsList();
  }

  void _updateIngredientsList() {
    final text = _ingredientsController.text;
    if (text.isNotEmpty) {
      setState(() {
        _ingredientsList = text
            .split(',')
            .map((ingredient) => ingredient.trim())
            .where((ingredient) => ingredient.isNotEmpty)
            .toList();
      });
    } else {
      setState(() => _ingredientsList = []);
    }
  }

  Future<void> _getRecommendations() async {
    if (_ingredientsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan minimal 1 bahan')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    // Tambahkan delay untuk efek loading
    await Future.delayed(const Duration(milliseconds: 500));

    final recommendations = await DatabaseHelper.recommendRecipes(_ingredientsList);
    
    setState(() {
      _recommendations = recommendations;
      _isLoading = false;
    });

    if (recommendations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tidak ditemukan resep yang cocok'),
          action: SnackBarAction(
            label: 'Reset',
            onPressed: () {
              _ingredientsController.clear();
              _updateIngredientsList();
            },
          ),
        ),
      );
    }

    // Hilangkan keyboard setelah pencarian
    _focusNode.unfocus();
  }

  void _clearSearch() {
    setState(() {
      _ingredientsController.clear();
      _ingredientsList.clear();
      _recommendations.clear();
      _hasSearched = false;
    });
    _focusNode.unfocus();
  }

  Widget _buildIngredientChip(String ingredient) {
    return Chip(
      label: Text(ingredient),
      backgroundColor: const Color(0xFFFF5722).withOpacity(0.1),
      labelStyle: const TextStyle(color: Color(0xFFFF5722)),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () {
        setState(() {
          _ingredientsList.remove(ingredient);
          _ingredientsController.text = _ingredientsList.join(', ');
        });
      },
    );
  }

  Widget _buildRecipeCard(RecipeRecommendation recommendation, int index) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailPage(
                recipe: recommendation.recipe,
                recommendation: recommendation,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5722).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Color(0xFFFF5722),
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Recipe Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.recipe.title,
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
                              '${recommendation.recipe.totalTime} menit',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.people, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              '${recommendation.recipe.servings} porsi',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Score Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getScoreColor(recommendation.score),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      recommendation.scorePercentage,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Progress Bar
              LinearProgressIndicator(
                value: recommendation.score / 100,
                backgroundColor: Colors.grey[200],
                color: _getScoreColor(recommendation.score),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              
              const SizedBox(height: 12),
              
              // Matching Info
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '${recommendation.matchingIngredients.length} bahan cocok',
                    style: TextStyle(color: Colors.green[700], fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.warning, size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    '${recommendation.missingIngredients.length} bahan kurang',
                    style: TextStyle(color: Colors.orange[700], fontSize: 12),
                  ),
                ],
              ),
              
              if (recommendation.missingIngredients.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: recommendation.missingIngredients.take(3).map((ingredient) {
                    return Chip(
                      label: Text(
                        ingredient,
                        style: const TextStyle(fontSize: 11),
                      ),
                      backgroundColor: Colors.orange[50],
                      labelStyle: TextStyle(color: Colors.orange[800]),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                if (recommendation.missingIngredients.length > 3)
                  Text(
                    '+${recommendation.missingIngredients.length - 3} lebih...',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFFF5722),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MasakApa?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Masukkan bahan yang Anda miliki, dapatkan rekomendasi resep',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Input Field
                TextField(
                  controller: _ingredientsController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Contoh: nasi, telur, bawang merah, minyak...',
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFFF5722)),
                    suffixIcon: _ingredientsList.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF5722)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  maxLines: 3,
                  minLines: 1,
                  onChanged: (value) => _updateIngredientsList(),
                  onSubmitted: (value) => _getRecommendations(),
                ),

                const SizedBox(height: 12),

                // Ingredients Chips
                if (_ingredientsList.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _ingredientsList.map(_buildIngredientChip).toList(),
                  ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _getRecommendations,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5722),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.restaurant_menu, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'CARI RESEP',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    if (_hasSearched) ...[
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _clearSearch,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: Color(0xFFFF5722)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        child: const Text('Reset'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Results Section
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Color(0xFFFF5722)),
                        SizedBox(height: 16),
                        Text('Mencari resep terbaik...'),
                      ],
                    ),
                  )
                : _hasSearched
                    ? _recommendations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant_menu_outlined,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Tidak ada resep yang cocok',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    'Coba tambahkan lebih banyak bahan atau gunakan bahan yang berbeda',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _clearSearch,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF5722),
                                  ),
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _recommendations.length,
                            itemBuilder: (context, index) {
                              return _buildRecipeCard(_recommendations[index], index);
                            },
                          )
                    : Column(
                        children: [
                          const SizedBox(height: 40),
                          Icon(
                            Icons.restaurant_menu,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Mulai Pencarian Resep',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Masukkan bahan-bahan yang Anda miliki di kotak pencarian di atas untuk mendapatkan rekomendasi resep',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 32),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange[100]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb_outline,
                                      color: Colors.orange[700],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Tips Pencarian',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ...[
                                  'Pisahkan bahan dengan koma (,)',
                                  'Gunakan nama bahan yang umum',
                                  'Semakin banyak bahan yang dimasukkan, semakin akurat rekomendasinya',
                                  'Minimal kecocokan 40% untuk ditampilkan',
                                ].map((tip) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: Colors.green[400],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(tip)),
                                    ],
                                  ),
                                )).toList(),
                              ],
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
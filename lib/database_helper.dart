import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'models.dart';

class DatabaseHelper {
  static const String _usersKey = 'users';
  static const String _recipesKey = 'recipes';
  static const String _currentUserKey = 'current_user';
  static const Uuid uuid = Uuid();

  // ========== USER MANAGEMENT ==========
  
  static Future<List<User>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? raw = prefs.getStringList(_usersKey);
    
    if (raw == null) return [];
    
    return raw.map((s) => User.fromMap(jsonDecode(s))).toList();
  }

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();
    
    final existingIndex = users.indexWhere((u) => u.email == user.email);
    
    if (existingIndex >= 0) {
      users[existingIndex] = user;
    } else {
      users.add(user);
    }
    
    final List<String> raw = users.map((u) => jsonEncode(u.toMap())).toList();
    await prefs.setStringList(_usersKey, raw);
  }

  static Future<User?> getUserByEmail(String email) async {
    final users = await getUsers();
    return users.firstWhere((user) => user.email == email, orElse: () => null);
  }

  static Future<User?> getUserById(String id) async {
    final users = await getUsers();
    return users.firstWhere((user) => user.id == id, orElse: () => null);
  }

  static Future<bool> validateLogin(String email, String password) async {
    final user = await getUserByEmail(email);
    return user != null && user.password == password;
  }

  static Future<void> setCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user.toMap()));
  }

  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_currentUserKey);
    
    if (raw == null) return null;
    
    try {
      return User.fromMap(jsonDecode(raw));
    } catch (e) {
      return null;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  static Future<void> toggleFavorite(String recipeId) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return;

    final List<String> favorites = List.from(currentUser.favorites);
    
    if (favorites.contains(recipeId)) {
      favorites.remove(recipeId);
    } else {
      favorites.add(recipeId);
    }

    final updatedUser = currentUser.copyWith(favorites: favorites);
    await saveUser(updatedUser);
    await setCurrentUser(updatedUser);
  }

  static Future<bool> isFavorite(String recipeId) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return false;
    
    return currentUser.favorites.contains(recipeId);
  }

  // ========== RECIPE MANAGEMENT ==========

  static Future<List<Recipe>> getRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? raw = prefs.getStringList(_recipesKey);
    
    if (raw == null) {
      await _seedRecipes();
      return await getRecipes();
    }
    
    return raw.map((s) => Recipe.fromMap(jsonDecode(s))).toList();
  }

  static Future<List<Recipe>> getFavoriteRecipes() async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return [];
    
    final allRecipes = await getRecipes();
    return allRecipes.where((recipe) => currentUser.favorites.contains(recipe.id)).toList();
  }

  static Future<Recipe?> getRecipeById(String id) async {
    final recipes = await getRecipes();
    return recipes.firstWhere((recipe) => recipe.id == id, orElse: () => null);
  }

  static Future<void> saveRecipe(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final recipes = await getRecipes();
    
    final existingIndex = recipes.indexWhere((r) => r.id == recipe.id);
    
    if (existingIndex >= 0) {
      recipes[existingIndex] = recipe;
    } else {
      recipes.add(recipe);
    }
    
    final List<String> raw = recipes.map((r) => jsonEncode(r.toMap())).toList();
    await prefs.setStringList(_recipesKey, raw);
  }

  static Future<void> deleteRecipe(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final recipes = await getRecipes();
    
    recipes.removeWhere((recipe) => recipe.id == id);
    
    final List<String> raw = recipes.map((r) => jsonEncode(r.toMap())).toList();
    await prefs.setStringList(_recipesKey, raw);
  }

  static Future<void> _seedRecipes() async {
    final List<Recipe> sampleRecipes = [
      Recipe(
        id: uuid.v4(),
        title: 'Nasi Goreng Spesial',
        ingredients: [
          'nasi',
          'telur ayam',
          'bawang merah',
          'bawang putih',
          'kecap manis',
          'kecap asin',
          'garam',
          'merica',
          'minyak goreng',
          'daun bawang',
          'wortel',
          'sosis',
          'ayam suwir'
        ],
        steps: [
          'Panaskan minyak goreng dalam wajan',
          'Tumis bawang merah dan bawang putih hingga harum',
          'Masukkan telur, orak-arik hingga matang',
          'Tambahkan wortel, sosis, dan ayam suwir, tumis sebentar',
          'Masukkan nasi putih, aduk rata',
          'Tambahkan kecap manis, kecap asin, garam, dan merica',
          'Aduk terus hingga semua bumbu tercampur rata',
          'Masukkan daun bawang, aduk sebentar',
          'Angkat dan sajikan hangat dengan pelengkap'
        ],
        category: 'Nasi',
        imageUrl: '',
        prepTime: 15,
        cookTime: 10,
        servings: 2,
        difficulty: 'Mudah',
        nutritionInfo: 'Kalori: 450 | Protein: 20g | Karbohidrat: 60g',
        tags: ['nasi', 'cepat', 'sehari-hari', 'indonesia'],
      ),
      Recipe(
        id: uuid.v4(),
        title: 'Mie Goreng Jawa',
        ingredients: [
          'mie telur',
          'kol',
          'wortel',
          'bawang merah',
          'bawang putih',
          'kecap manis',
          'saus tiram',
          'garam',
          'merica',
          'minyak goreng',
          'telur ayam',
          'ayam suwir',
          'udang',
          'tauge'
        ],
        steps: [
          'Rebus mie telur hingga setengah matang, tiriskan',
          'Panaskan minyak, tumis bawang merah dan bawang putih',
          'Masukkan telur, orak-arik hingga matang',
          'Tambahkan ayam suwir dan udang, tumis hingga matang',
          'Masukkan wortel dan kol, tumis hingga layu',
          'Tambahkan mie yang sudah direbus',
          'Beri kecap manis, saus tiram, garam, dan merica',
          'Aduk rata hingga semua tercampur',
          'Tambahkan tauge di akhir, aduk sebentar',
          'Sajikan hangat dengan acar'
        ],
        category: 'Mie',
        imageUrl: '',
        prepTime: 20,
        cookTime: 15,
        servings: 3,
        difficulty: 'Sedang',
        nutritionInfo: 'Kalori: 500 | Protein: 25g | Karbohidrat: 70g',
        tags: ['mie', 'cepat', 'goreng', 'indonesia'],
      ),
      Recipe(
        id: uuid.v4(),
        title: 'Sayur Bayam',
        ingredients: [
          'bayam',
          'bawang merah',
          'bawang putih',
          'garam',
          'kaldu ayam',
          'air',
          'jagung manis',
          'wortel',
          'labu siam'
        ],
        steps: [
          'Didihkan air dalam panci',
          'Masukkan bawang merah dan bawang putih yang sudah diiris',
          'Tambahkan wortel dan labu siam, masak hingga setengah matang',
          'Masukkan jagung manis, masak sebentar',
          'Tambahkan bayam, masak sebentar hingga layu',
          'Beri garam dan kaldu ayam, koreksi rasa',
          'Matikan api, sajikan hangat'
        ],
        category: 'Sayur',
        imageUrl: '',
        prepTime: 10,
        cookTime: 10,
        servings: 4,
        difficulty: 'Mudah',
        nutritionInfo: 'Kalori: 120 | Protein: 5g | Karbohidrat: 25g',
        tags: ['sayur', 'sehat', 'vegetarian', 'cepat'],
      ),
      Recipe(
        id: uuid.v4(),
        title: 'Ayam Goreng Kremes',
        ingredients: [
          'ayam potong',
          'bawang putih',
          'ketumbar',
          'kunyit',
          'jahe',
          'garam',
          'tepung beras',
          'tepung tapioka',
          'santan',
          'minyak goreng',
          'air'
        ],
        steps: [
          'Haluskan bumbu: bawang putih, ketumbar, kunyit, jahe, garam',
          'Lumuri ayam dengan bumbu halus, diamkan 30 menit',
          'Rebus ayam dengan santan hingga matang dan empuk',
          'Campur tepung beras dan tepung tapioka dengan air bumbu sisa rebusan',
          'Panaskan minyak banyak dalam wajan',
          'Goreng ayam hingga kecoklatan, angkat',
          'Tuang adonan tepung ke dalam minyak panas untuk membuat kremes',
          'Goreng kremes hingga kering dan renyah',
          'Sajikan ayam dengan taburan kremes'
        ],
        category: 'Ayam',
        imageUrl: '',
        prepTime: 40,
        cookTime: 30,
        servings: 4,
        difficulty: 'Sulit',
        nutritionInfo: 'Kalori: 350 | Protein: 30g | Karbohidrat: 20g',
        tags: ['ayam', 'goreng', 'indonesia', 'spesial'],
      ),
      Recipe(
        id: uuid.v4(),
        title: 'Capcay Kuah',
        ingredients: [
          'sawi putih',
          'wortel',
          'brokoli',
          'kembang kol',
          'jagung muda',
          'buncis',
          'bawang putih',
          'bawang bombay',
          'jahe',
          'saus tiram',
          'kecap ikan',
          'garam',
          'merica',
          'minyak goreng',
          'air',
          'ayam suwir',
          'udang'
        ],
        steps: [
          'Potong semua sayuran sesuai selera',
          'Panaskan minyak, tumis bawang putih, bawang bombay, dan jahe',
          'Masukkan ayam suwir dan udang, tumis hingga matang',
          'Tambahkan sayuran yang keras dulu (wortel, brokoli)',
          'Tuang air secukupnya, masak hingga sayuran setengah matang',
          'Masukkan sayuran yang cepat matang (sawi, buncis)',
          'Beri saus tiram, kecap ikan, garam, dan merica',
          'Masak hingga semua sayuran matang tetapi masih renyah',
          'Sajikan hangat dengan nasi putih'
        ],
        category: 'Sayur',
        imageUrl: '',
        prepTime: 25,
        cookTime: 15,
        servings: 4,
        difficulty: 'Sedang',
        nutritionInfo: 'Kalori: 280 | Protein: 20g | Karbohidrat: 35g',
        tags: ['sayur', 'sehat', 'cina', 'komplit'],
      ),
    ];

    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = sampleRecipes.map((r) => jsonEncode(r.toMap())).toList();
    await prefs.setStringList(_recipesKey, raw);
  }

  // ========== RECOMMENDATION LOGIC ==========

  static Future<List<RecipeRecommendation>> recommendRecipes(List<String> userIngredients) async {
    final recipes = await getRecipes();
    
    // Preprocess user ingredients
    final processedUserIngredients = userIngredients
        .map((ing) => ing.toLowerCase().trim())
        .where((ing) => ing.isNotEmpty)
        .toList();

    // Calculate scores for each recipe
    final List<RecipeRecommendation> recommendations = [];

    for (final recipe in recipes) {
      final processedRecipeIngredients = recipe.ingredients
          .map((ing) => ing.toLowerCase().trim())
          .toList();
      
      // Find matching ingredients
      final matchingIngredients = processedRecipeIngredients
          .where((ing) => processedUserIngredients.contains(ing))
          .toList();
      
      final missingIngredients = processedRecipeIngredients
          .where((ing) => !processedUserIngredients.contains(ing))
          .toList();
      
      // Calculate score (weighted: more ingredients matched = higher score)
      final score = (matchingIngredients.length / processedRecipeIngredients.length) * 100;
      
      // Only include recipes with score >= 40%
      if (score >= 40) {
        recommendations.add(RecipeRecommendation(
          recipe: recipe,
          score: score,
          missingIngredients: missingIngredients,
          matchingIngredients: matchingIngredients,
        ));
      }
    }

    // Sort by score (highest first)
    recommendations.sort((a, b) => b.score.compareTo(a.score));
    
    return recommendations;
  }

  // ========== SEARCH FUNCTIONALITY ==========

  static Future<List<Recipe>> searchRecipes(String query) async {
    if (query.isEmpty) return [];
    
    final recipes = await getRecipes();
    final lowercaseQuery = query.toLowerCase();
    
    return recipes.where((recipe) {
      return recipe.title.toLowerCase().contains(lowercaseQuery) ||
             recipe.category.toLowerCase().contains(lowercaseQuery) ||
             recipe.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ||
             recipe.ingredients.any((ing) => ing.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  static Future<List<Recipe>> getRecipesByCategory(String category) async {
    final recipes = await getRecipes();
    return recipes.where((recipe) => recipe.category == category).toList();
  }

  static Future<List<String>> getAllCategories() async {
    final recipes = await getRecipes();
    final categories = recipes.map((r) => r.category).toSet().toList();
    return categories;
  }
}
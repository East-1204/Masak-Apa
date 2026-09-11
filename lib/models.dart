import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final DateTime createdAt;
  final List<String> favorites;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.createdAt,
    this.favorites = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'favorites': favorites,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      createdAt: DateTime.parse(map['createdAt']),
      favorites: List<String>.from(map['favorites'] ?? []),
    );
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    DateTime? createdAt,
    List<String>? favorites,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
      favorites: favorites ?? this.favorites,
    );
  }
}

class Recipe {
  final String id;
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final String category;
  final String imageUrl;
  final int prepTime;
  final int cookTime;
  final int servings;
  final String difficulty;
  final String nutritionInfo;
  final List<String> tags;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.category,
    this.imageUrl = '',
    required this.prepTime,
    required this.cookTime,
    required this.servings,
    required this.difficulty,
    this.nutritionInfo = '',
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients,
      'steps': steps,
      'category': category,
      'imageUrl': imageUrl,
      'prepTime': prepTime,
      'cookTime': cookTime,
      'servings': servings,
      'difficulty': difficulty,
      'nutritionInfo': nutritionInfo,
      'tags': tags,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      title: map['title'],
      ingredients: List<String>.from(map['ingredients']),
      steps: List<String>.from(map['steps']),
      category: map['category'],
      imageUrl: map['imageUrl'] ?? '',
      prepTime: map['prepTime'],
      cookTime: map['cookTime'],
      servings: map['servings'],
      difficulty: map['difficulty'],
      nutritionInfo: map['nutritionInfo'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  int get totalTime => prepTime + cookTime;
}

class RecipeRecommendation {
  final Recipe recipe;
  final double score;
  final List<String> missingIngredients;
  final List<String> matchingIngredients;

  RecipeRecommendation({
    required this.recipe,
    required this.score,
    required this.missingIngredients,
    required this.matchingIngredients,
  });

  String get scorePercentage => '${score.toStringAsFixed(1)}%';
  bool get isPerfectMatch => score >= 90;
  bool get isGoodMatch => score >= 70;
  bool get isFairMatch => score >= 40;
}
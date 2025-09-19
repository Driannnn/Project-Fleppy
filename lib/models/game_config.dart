import 'package:flutter/material.dart';

/// Model dasar
class GameConfig {
  final String name;
  final String description;
  final double pipeGapH;
  final double pipeSpeed;

  const GameConfig({
    required this.name,
    required this.description,
    required this.pipeGapH,
    required this.pipeSpeed,
  });

  Map<String, dynamic> toMap() {
    return {
      'kind': 'base',
      'name': name,
      'description': description,
      'pipeGapH': pipeGapH,
      'pipeSpeed': pipeSpeed,
    };
  }

  factory GameConfig.fromMap(Map<String, dynamic> map) {
    return GameConfig(
      name: map['name'],
      description: map['description'],
      pipeGapH: (map['pipeGapH'] as num).toDouble(),
      pipeSpeed: (map['pipeSpeed'] as num).toDouble(),
    );
  }

  /// Helper: otomatis pilih turunan kalau field tambahan ada
  static GameConfig fromAny(Map<String, dynamic> map) {
    final kind = map['kind'];
    final hasAdvancedFields = map.containsKey('themeColor') || map.containsKey('iconPath');
    if (kind == 'advanced' || hasAdvancedFields) {
      return AdvancedGameConfig.fromMap(map);
    }
    return GameConfig.fromMap(map);
  }
}

/// Model turunan: punya warna tema + icon (SVG / PNG)
class AdvancedGameConfig extends GameConfig {
  final Color themeColor;
  final String iconPath;

  const AdvancedGameConfig({
    required super.name,
    required super.description,
    required super.pipeGapH,
    required super.pipeSpeed,
    required this.themeColor,
    required this.iconPath,
  });

  @override
  Map<String, dynamic> toMap() {
    final base = super.toMap();
    return {
      ...base,
      'kind': 'advanced',
      'themeColor': themeColor.value,
      'iconPath': iconPath,
    };
  }

  factory AdvancedGameConfig.fromMap(Map<String, dynamic> map) {
    return AdvancedGameConfig(
      name: map['name'],
      description: map['description'],
      pipeGapH: (map['pipeGapH'] as num).toDouble(),
      pipeSpeed: (map['pipeSpeed'] as num).toDouble(),
      themeColor: Color(map['themeColor'] ?? 0xFFFFFFFF),
      iconPath: map['iconPath'] ?? 'assets/bird.svg',
    );
  }
}

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

  @override
  String toString() =>
      'GameConfig(name: $name, gap: $pipeGapH, speed: $pipeSpeed)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameConfig &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          pipeGapH == other.pipeGapH &&
          pipeSpeed == other.pipeSpeed;

  @override
  int get hashCode =>
      name.hashCode ^
      description.hashCode ^
      pipeGapH.hashCode ^
      pipeSpeed.hashCode;
}

/// Model turunan dengan tambahan properti
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
  String toString() =>
      'AdvancedGameConfig(name: $name, gap: $pipeGapH, speed: $pipeSpeed, '
      'themeColor: $themeColor, iconPath: $iconPath)';

  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvancedGameConfig &&
          super == other && // panggil equality dari GameConfig
          themeColor == other.themeColor &&
          iconPath == other.iconPath;

  @override
  int get hashCode => super.hashCode ^ themeColor.hashCode ^ iconPath.hashCode;
}

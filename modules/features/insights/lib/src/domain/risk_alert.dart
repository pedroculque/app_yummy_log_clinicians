import 'package:equatable/equatable.dart';

enum RiskType {
  forcedVomit,
  usedLaxatives,
  regurgitated,
  hiddenFood,
  ateInSecret,
}

enum RiskPriority {
  high,
  medium,
  low,
}

class RiskAlert extends Equatable {
  const RiskAlert({
    required this.patientId,
    required this.patientName,
    required this.type,
    required this.dateTime,
    required this.priority,
    this.mealId,
  });

  final String patientId;
  final String patientName;
  final RiskType type;
  final DateTime dateTime;
  final RiskPriority priority;
  final String? mealId;

  @override
  List<Object?> get props => [
        patientId,
        patientName,
        type,
        dateTime,
        priority,
        mealId,
      ];

  static RiskPriority getPriorityForType(RiskType type) {
    switch (type) {
      case RiskType.forcedVomit:
      case RiskType.usedLaxatives:
        return RiskPriority.high;
      case RiskType.regurgitated:
      case RiskType.hiddenFood:
        return RiskPriority.medium;
      case RiskType.ateInSecret:
        return RiskPriority.low;
    }
  }
}

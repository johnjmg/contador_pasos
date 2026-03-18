class StepRecord {
  int? id;
  DateTime dateTime;
  int steps;
  String userId;

  StepRecord({
    this.id,
    required this.dateTime,
    required this.steps,
    required this.userId,
  });

  // Convertir Map a StepRecord
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date_time': dateTime.toIso8601String(),
      'steps': steps,
      'user_id': userId,
    };
  }

  // Convertir StepRecord a Map
  factory StepRecord.fromMap(Map<String, dynamic> map) {
    return StepRecord(
      id: map['id'],
      dateTime: DateTime.parse(map['date_time']),
      steps: map['steps'],
      userId: map['user_id'],
    );
  }
}
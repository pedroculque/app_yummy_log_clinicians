import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  const Patient({
    required this.id,
    required this.name,
    this.photoUrl,
    this.age,
    this.linkedAt,
    this.condition,
  });

  factory Patient.fromFirestore(Map<String, dynamic> data, String id) {
    return Patient(
      id: id,
      name: data['name'] as String? ?? 'Paciente',
      photoUrl: data['photoUrl'] as String?,
      age: data['age'] as int?,
      linkedAt: data['linkedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (data['linkedAt'] as dynamic).millisecondsSinceEpoch as int,
            )
          : null,
      condition: data['condition'] as String?,
    );
  }

  final String id;
  final String name;
  final String? photoUrl;
  final int? age;
  final DateTime? linkedAt;
  final String? condition;

  @override
  List<Object?> get props => [id, name, photoUrl, age, linkedAt, condition];
}

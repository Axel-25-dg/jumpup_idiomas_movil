enum ExerciseType { multipleChoice, fillInTheBlank, trueFalse, matching }

class ExerciseModel {
  final String id;
  final String lessonId;
  final String question;
  final ExerciseType type;
  final List<String> options;
  final String correctAnswer;
  final int points;

  const ExerciseModel({
    required this.id,
    required this.lessonId,
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswer,
    this.points = 10,
  });
}

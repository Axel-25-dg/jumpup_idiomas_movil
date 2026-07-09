class Exercise {
  final int id;
  final int lesson;
  final String? lessonTitle;
  final String questionText;
  final String exerciseType;
  final String correctAnswer;

  Exercise({
    required this.id,
    required this.lesson,
    this.lessonTitle,
    required this.questionText,
    required this.exerciseType,
    required this.correctAnswer,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int,
      lesson: json['lesson'] as int,
      lessonTitle: json['lesson_title'] as String?,
      questionText: json['question_text'] as String,
      exerciseType: json['exercise_type'] as String,
      correctAnswer: json['correct_answer'] as String,
    );
  }
}
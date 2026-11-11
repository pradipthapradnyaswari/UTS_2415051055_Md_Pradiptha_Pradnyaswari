class FeedbackModel {
  final String name;
  final String studentId;
  final String comment;

  const FeedbackModel({
    required this.name,
    required this.studentId,
    required this.comment,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'student_id': studentId, 'comment': comment};
  }
}

import '../models/feedback_model.dart';
import '../services/supabase_service.dart';

class FeedbackRepository {
  Future<void> submitFeedback(FeedbackModel feedback) async {
    await SupabaseService.client.from('feedback').insert(feedback.toJson());
  }
}

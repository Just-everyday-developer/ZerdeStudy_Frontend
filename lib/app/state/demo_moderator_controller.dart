import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo_moderator_data.dart';

final demoModeratorFaqProvider =
    NotifierProvider<DemoModeratorFaqController, List<ModFaqQuestion>>(
      DemoModeratorFaqController.new,
    );

final demoModeratorCommentsProvider =
    NotifierProvider<DemoModeratorCommentsController, List<ModCommentItem>>(
      DemoModeratorCommentsController.new,
    );

final demoModeratorCommunityProvider =
    NotifierProvider<
      DemoModeratorCommunityController,
      List<ModCommunityContentItem>
    >(DemoModeratorCommunityController.new);

class DemoModeratorFaqController extends Notifier<List<ModFaqQuestion>> {
  @override
  List<ModFaqQuestion> build() {
    return List<ModFaqQuestion>.from(kModFaqQuestions);
  }

  void submitQuestion({required String question, required String askedBy}) {
    final trimmedQuestion = question.trim();
    final trimmedAskedBy = askedBy.trim();
    if (trimmedQuestion.isEmpty || trimmedAskedBy.isEmpty) {
      return;
    }

    final now = DateTime.now();
    state = <ModFaqQuestion>[
      ModFaqQuestion(
        id: 'faq_${now.microsecondsSinceEpoch}',
        question: trimmedQuestion,
        askedBy: trimmedAskedBy,
        askedAt: _formatAskedAt(now),
        answer: '',
      ),
      ...state,
    ];
  }

  String _formatAskedAt(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }
}

class DemoModeratorCommentsController extends Notifier<List<ModCommentItem>> {
  @override
  List<ModCommentItem> build() {
    return List<ModCommentItem>.from(kModCommentItems);
  }

  void updateStatus(String commentId, ModCommentStatus status) {
    state = state
        .map(
          (item) => item.id == commentId ? item.copyWith(status: status) : item,
        )
        .toList(growable: false);
  }
}

class DemoModeratorCommunityController
    extends Notifier<List<ModCommunityContentItem>> {
  @override
  List<ModCommunityContentItem> build() {
    return List<ModCommunityContentItem>.from(kModCommunityContentItems);
  }

  void updateStatus(String itemId, ModCommunityContentStatus status) {
    state = state
        .map((item) => item.id == itemId ? item.copyWith(status: status) : item)
        .toList(growable: false);
  }
}

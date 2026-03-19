import 'package:flutter_riverpod/flutter_riverpod.dart';

final courseSearchFocusRequestProvider =
    NotifierProvider<CourseSearchFocusRequest, int>(
  CourseSearchFocusRequest.new,
);

class CourseSearchFocusRequest extends Notifier<int> {
  @override
  int build() => 0;

  void ping() {
    state = state + 1;
  }
}

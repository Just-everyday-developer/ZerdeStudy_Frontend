import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_app_state.dart';
import '../../../../app/state/demo_catalog.dart';
import '../../../../app/state/demo_models.dart';

final aiAppContextProvider = Provider<String>((ref) {
  final state = ref.watch(demoAppControllerProvider);
  final catalog = ref.watch(demoCatalogProvider);
  return buildAiAppContext(state: state, catalog: catalog);
});

String buildAiAppContext({
  required DemoAppState state,
  required DemoCatalog catalog,
}) {
  final locale = state.locale;
  final tracks = List<LearningTrack>.of(catalog.tracks)
    ..sort(_compareTracksForContext);
  final coreTracks = tracks
      .where((track) => track.zone == TrackZone.computerScienceCore)
      .toList(growable: false);
  final sphereTracks = tracks
      .where((track) => track.zone == TrackZone.itSpheres)
      .toList(growable: false);

  final currentTrack = catalog.trackById(state.currentTrackId);
  final currentProgress = catalog.progressForTrack(state, currentTrack.id);
  final focusedLesson = state.focusedLessonId == null
      ? null
      : catalog.lessonById(state.focusedLessonId!);
  final focusedPractice = state.focusedPracticeId == null
      ? null
      : catalog.practiceById(state.focusedPracticeId!);

  final startedTracks = tracks
      .where(
        (track) => catalog.progressForTrack(state, track.id).completedUnits > 0,
      )
      .toList(growable: false);
  final completedTracks = tracks
      .where(
        (track) =>
            catalog.trackAvailabilityFor(state, track.id) ==
                TrackAvailability.completed ||
            catalog.trackAvailabilityFor(state, track.id) ==
                TrackAvailability.mastered,
      )
      .toList(growable: false);
  final masteredTracks = tracks
      .where(
        (track) =>
            catalog.trackAvailabilityFor(state, track.id) ==
            TrackAvailability.mastered,
      )
      .toList(growable: false);

  final foundationTrack = _selectFoundationTrack(
    state: state,
    catalog: catalog,
    coreTracks: coreTracks,
  );
  final currentPathSuggestion = _selectCurrentPathSuggestion(
    state: state,
    catalog: catalog,
    currentTrack: currentTrack,
  );
  final followUpTrack = _selectFollowUpTrack(
    state: state,
    catalog: catalog,
    currentTrack: currentTrack,
    allTracks: tracks,
  );
  final connectedTracks = currentTrack.connections
      .map(catalog.trackById)
      .toList(growable: false);

  final currentFocusKind = focusedLesson != null
      ? 'lesson'
      : focusedPractice != null
      ? 'practice'
      : 'track';
  final currentFocusTitle =
      focusedLesson?.title.resolve(locale) ??
      focusedPractice?.title.resolve(locale) ??
      currentTrack.title.resolve(locale);
  final currentFocusRoute = focusedLesson != null
      ? AppRoutes.lessonById(focusedLesson.id)
      : focusedPractice != null
      ? AppRoutes.practiceById(focusedPractice.id)
      : AppRoutes.trackById(currentTrack.id);

  final buffer = StringBuffer()
    ..writeln('app_name: ZerdeStudy')
    ..writeln('current_surface: ai_mentor')
    ..writeln('locale: ${state.locale.code}')
    ..writeln('user_name: ${state.user?.name ?? 'Student'}')
    ..writeln('user_role: ${state.user?.role ?? 'Learner'}')
    ..writeln('user_goal: ${state.user?.goal ?? 'Learn effectively'}')
    ..writeln(
      'progress_snapshot: xp=${state.xp}, level=${state.level}, streak=${state.streak}, completed_lessons=${state.completedLessonIds.length}, completed_practices=${state.completedPracticeIds.length}, completed_tracks=${completedTracks.length}, mastered_tracks=${masteredTracks.length}',
    )
    ..writeln()
    ..writeln('current_focus:')
    ..writeln(' - focus_kind: $currentFocusKind')
    ..writeln(' - focus_title: $currentFocusTitle')
    ..writeln(' - focus_route: $currentFocusRoute')
    ..writeln(' - current_track: ${currentTrack.title.resolve(locale)}')
    ..writeln(' - current_track_id: ${currentTrack.id}')
    ..writeln(' - current_track_zone: ${_zoneLabel(currentTrack.zone)}')
    ..writeln(
      ' - current_track_status: ${_availabilityLabel(currentProgress.state)} (${currentProgress.completedUnits}/${currentProgress.totalUnits} units)',
    )
    ..writeln(
      ' - current_next_target: ${currentProgress.nextTarget?.title.resolve(locale) ?? 'none'}',
    )
    ..writeln(
      ' - connected_tracks: ${_trackTitleList(connectedTracks, locale)}',
    )
    ..writeln()
    ..writeln('knowledge_tree:')
    ..writeln(
      ' - zone_core_summary: Foundational branches that explain math, systems, data, architecture, and core computing behavior.',
    )
    ..writeln(
      ' - zone_it_summary: Applied IT branches built on top of the foundation, including frontend, backend, mobile, DevOps, QA, ML, and security.',
    )
    ..writeln(
      ' - core_tracks: ${_trackStatusList(catalog: catalog, state: state, tracks: coreTracks)}',
    )
    ..writeln(
      ' - applied_tracks: ${_trackStatusList(catalog: catalog, state: state, tracks: sphereTracks)}',
    )
    ..writeln(
      ' - already_started_branches: ${startedTracks.isEmpty ? 'none' : _trackTitleList(startedTracks, locale)}',
    )
    ..writeln()
    ..writeln('guided_recommendations:')
    ..writeln(
      ' - recommended_tree_start_from_current_state: ${currentPathSuggestion.title.resolve(locale)}',
    )
    ..writeln(
      ' - recommended_tree_start_reason: ${_currentPathReason(catalog: catalog, state: state, track: currentPathSuggestion)}',
    )
    ..writeln(
      ' - recommended_core_anchor: ${foundationTrack.title.resolve(locale)}',
    )
    ..writeln(
      ' - recommended_core_anchor_reason: ${_foundationReason(catalog: catalog, state: state, track: foundationTrack)}',
    )
    ..writeln(
      ' - recommended_follow_up_branch: ${followUpTrack.title.resolve(locale)}',
    )
    ..writeln()
    ..writeln('navigation_routes:')
    ..writeln(' - tree: ${AppRoutes.tree}')
    ..writeln(' - learn: ${AppRoutes.learn}')
    ..writeln(' - ai: ${AppRoutes.ai}')
    ..writeln(' - stats: ${AppRoutes.stats}')
    ..writeln(' - current_track: ${AppRoutes.trackById(currentTrack.id)}')
    ..writeln(' - current_focus: $currentFocusRoute');

  return buffer.toString().trim();
}

LearningTrack _selectFoundationTrack({
  required DemoAppState state,
  required DemoCatalog catalog,
  required List<LearningTrack> coreTracks,
}) {
  final inProgress = coreTracks.where(
    (track) =>
        catalog.trackAvailabilityFor(state, track.id) ==
        TrackAvailability.inProgress,
  );
  if (inProgress.isNotEmpty) {
    return inProgress.first;
  }

  final available = coreTracks.where(
    (track) =>
        catalog.trackAvailabilityFor(state, track.id) ==
        TrackAvailability.available,
  );
  if (available.isNotEmpty) {
    return available.first;
  }

  return coreTracks.first;
}

LearningTrack _selectCurrentPathSuggestion({
  required DemoAppState state,
  required DemoCatalog catalog,
  required LearningTrack currentTrack,
}) {
  final currentAvailability = catalog.trackAvailabilityFor(
    state,
    currentTrack.id,
  );
  if (currentAvailability == TrackAvailability.inProgress ||
      currentAvailability == TrackAvailability.available) {
    return currentTrack;
  }

  final tracks = List<LearningTrack>.of(catalog.tracks)
    ..sort(_compareTracksForContext);
  return tracks.firstWhere(
    (track) =>
        track.id != currentTrack.id &&
        catalog.trackAvailabilityFor(state, track.id) !=
            TrackAvailability.mastered,
    orElse: () => currentTrack,
  );
}

LearningTrack _selectFollowUpTrack({
  required DemoAppState state,
  required DemoCatalog catalog,
  required LearningTrack currentTrack,
  required List<LearningTrack> allTracks,
}) {
  final connected = currentTrack.connections
      .map(catalog.trackById)
      .where(
        (track) =>
            catalog.trackAvailabilityFor(state, track.id) !=
            TrackAvailability.mastered,
      )
      .toList(growable: false);

  final sameZone = connected
      .where((track) => track.zone == currentTrack.zone)
      .toList(growable: false);
  if (sameZone.isNotEmpty) {
    sameZone.sort(_compareTracksForContext);
    return sameZone.first;
  }

  if (connected.isNotEmpty) {
    connected.sort(_compareTracksForContext);
    return connected.first;
  }

  return allTracks.firstWhere(
    (track) =>
        track.id != currentTrack.id &&
        catalog.trackAvailabilityFor(state, track.id) !=
            TrackAvailability.mastered,
    orElse: () => currentTrack,
  );
}

String _trackStatusList({
  required DemoCatalog catalog,
  required DemoAppState state,
  required List<LearningTrack> tracks,
}) {
  return tracks
      .map((track) {
        final progress = catalog.progressForTrack(state, track.id);
        return '${track.title.resolve(state.locale)} [${_availabilityLabel(progress.state)}, ${progress.completedUnits}/${progress.totalUnits}]';
      })
      .join(' | ');
}

String _trackTitleList(List<LearningTrack> tracks, AppLocale locale) {
  return tracks.map((track) => track.title.resolve(locale)).join(', ');
}

String _zoneLabel(TrackZone zone) {
  return switch (zone) {
    TrackZone.computerScienceCore => 'Computer Science Core',
    TrackZone.itSpheres => 'Applied IT Spheres',
  };
}

String _availabilityLabel(TrackAvailability availability) {
  return switch (availability) {
    TrackAvailability.available => 'available',
    TrackAvailability.inProgress => 'in_progress',
    TrackAvailability.completed => 'completed',
    TrackAvailability.mastered => 'mastered',
  };
}

String _currentPathReason({
  required DemoCatalog catalog,
  required DemoAppState state,
  required LearningTrack track,
}) {
  final progress = catalog.progressForTrack(state, track.id);
  final nextTarget = progress.nextTarget?.title.resolve(state.locale);
  if (track.id == state.currentTrackId && nextTarget != null) {
    return 'This is the learner\'s active track and the next unfinished target is $nextTarget.';
  }
  if (progress.completedUnits > 0) {
    return 'The learner already started this branch, so continuing it keeps momentum and uses the saved progress.';
  }
  return 'This is the cleanest unsolved branch from the current saved state.';
}

String _foundationReason({
  required DemoCatalog catalog,
  required DemoAppState state,
  required LearningTrack track,
}) {
  final availability = catalog.trackAvailabilityFor(state, track.id);
  if (availability == TrackAvailability.inProgress) {
    return 'This branch is already in progress inside Computer Science Core, so it is the best foundation anchor right now.';
  }
  return 'This is the earliest available core branch and it gives the strongest foundation for the rest of the tree.';
}

int _compareTracksForContext(LearningTrack left, LearningTrack right) {
  final leftZone = left.zone == TrackZone.computerScienceCore ? 0 : 1;
  final rightZone = right.zone == TrackZone.computerScienceCore ? 0 : 1;
  if (leftZone != rightZone) {
    return leftZone.compareTo(rightZone);
  }
  return left.order.compareTo(right.order);
}

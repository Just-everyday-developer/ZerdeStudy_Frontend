import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:frontend_flutter/core/network/json_http_client.dart';
import 'package:frontend_flutter/features/courses_backend/data/datasources/backend_course_remote_data_source.dart';

void main() {
  test(
    'backend course endpoint helpers hit expected methods and paths',
    () async {
      final requests = <http.Request>[];
      final client = JsonHttpClient(
        client: MockClient((request) async {
          requests.add(request);

          expect(request.headers['Authorization'], 'Bearer test-token');

          switch ('${request.method} ${request.url.path}') {
            case 'POST /api/v1/course/enrollment':
              expect(
                jsonDecode(request.body) as Map<String, dynamic>,
                <String, dynamic>{'course_id': 'course-42'},
              );
              return http.Response('{"subscription_id":"sub-1"}', 200);
            case 'POST /api/v1/point':
              expect(
                jsonDecode(request.body) as Map<String, dynamic>,
                <String, dynamic>{'course_id': 'course-42', 'points': 15},
              );
              return http.Response('{"point_id":"point-1"}', 200);
            case 'PUT /api/v1/point/point-1':
              expect(
                jsonDecode(request.body) as Map<String, dynamic>,
                <String, dynamic>{'points': 25},
              );
              return http.Response('{"point_id":"point-1","points":25}', 200);
            case 'DELETE /api/v1/point/point-1':
              expect(request.body, isEmpty);
              return http.Response('', 204);
            case 'GET /api/v1/leaderboard/course-42':
              expect(request.body, isEmpty);
              return http.Response(
                '[{"user_id":"user-1","points":120},{"user_id":"user-2","points":95}]',
                200,
              );
            case 'POST /api/v1/order':
              expect(
                jsonDecode(request.body) as Map<String, dynamic>,
                <String, dynamic>{'course_id': 'course-42', 'amount': 9900},
              );
              return http.Response('{"order_id":"order-1"}', 200);
          }

          fail('Unexpected request: ${request.method} ${request.url}');
        }),
        uriResolver: (path) => Uri.parse('http://localhost').resolve(path),
      );

      final remote = BackendCourseRemoteDataSource(client);

      final subscription = await remote.createSubscription(
        accessToken: 'test-token',
        body: <String, dynamic>{'course_id': 'course-42'},
      );
      final createdPoint = await remote.createCoursePoint(
        accessToken: 'test-token',
        body: <String, dynamic>{'course_id': 'course-42', 'points': 15},
      );
      final updatedPoint = await remote.updateCoursePoint(
        accessToken: 'test-token',
        pointId: 'point-1',
        body: <String, dynamic>{'points': 25},
      );
      await remote.deleteCoursePoint(
        accessToken: 'test-token',
        pointId: 'point-1',
      );
      final leaderboard = await remote.getCoursePointByCourseId(
        accessToken: 'test-token',
        courseId: 'course-42',
      );
      final order = await remote.createOrder(
        accessToken: 'test-token',
        body: <String, dynamic>{'course_id': 'course-42', 'amount': 9900},
      );

      expect(subscription['subscription_id'], 'sub-1');
      expect(createdPoint['point_id'], 'point-1');
      expect(updatedPoint['points'], 25);
      expect(leaderboard, hasLength(2));
      expect(leaderboard.first['user_id'], 'user-1');
      expect(order['order_id'], 'order-1');

      expect(
        requests
            .map((request) => '${request.method} ${request.url.path}')
            .toList(growable: false),
        <String>[
          'POST /api/v1/course/enrollment',
          'POST /api/v1/point',
          'PUT /api/v1/point/point-1',
          'DELETE /api/v1/point/point-1',
          'GET /api/v1/leaderboard/course-42',
          'POST /api/v1/order',
        ],
      );
    },
  );
}

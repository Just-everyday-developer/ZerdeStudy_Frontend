import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../core/config/app_environment.dart';
import '../../../../core/network/json_http_client.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/datasources/payment_remote_data_source.dart';
import '../../data/models/order_models.dart';
import '../../data/models/payment_models.dart';

final paymentHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final paymentJsonHttpClientProvider = Provider<JsonHttpClient>((ref) {
  final client = ref.watch(paymentHttpClientProvider);
  final environment = ref.watch(appEnvironmentProvider);
  return JsonHttpClient(client: client, uriResolver: environment.resolve);
});

final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>((ref) {
  final client = ref.watch(paymentJsonHttpClientProvider);
  return PaymentRemoteDataSource(client);
});

final paymentAccessTokenProvider = Provider<String?>((ref) {
  return ref.watch(
    authControllerProvider.select((state) => state.session?.accessToken),
  );
});

// Payment methods
final paymentMethodsProvider = FutureProvider<List<PaymentMethod>>((ref) async {
  final accessToken = ref.watch(paymentAccessTokenProvider);
  if (accessToken == null || accessToken.trim().isEmpty) {
    return const <PaymentMethod>[];
  }

  final remote = ref.watch(paymentRemoteDataSourceProvider);
  try {
    return await remote.fetchPaymentMethods(accessToken: accessToken);
  } catch (_) {
    return const <PaymentMethod>[];
  }
});

// Create order
final createOrderProvider = FutureProvider.family<OrderResponse?, OrderRequest>((
  ref,
  request,
) async {
  final accessToken = ref.watch(paymentAccessTokenProvider);
  if (accessToken == null || accessToken.trim().isEmpty) {
    return null;
  }

  final remote = ref.watch(paymentRemoteDataSourceProvider);
  try {
    return await remote.createOrder(accessToken: accessToken, request: request);
  } catch (_) {
    return null;
  }
});

// Create payment
final createPaymentProvider =
    FutureProvider.family<OrderResponse?, PaymentRequest>((ref, request) async {
  final accessToken = ref.watch(paymentAccessTokenProvider);
  if (accessToken == null || accessToken.trim().isEmpty) {
    return null;
  }

  final remote = ref.watch(paymentRemoteDataSourceProvider);
  try {
    return await remote.createPayment(accessToken: accessToken, request: request);
  } catch (_) {
    return null;
  }
});

// Get transaction status
final transactionProvider =
    FutureProvider.family<TransactionResponse?, String>((ref, invoiceId) async {
  final accessToken = ref.watch(paymentAccessTokenProvider);
  if (accessToken == null || accessToken.trim().isEmpty) {
    return null;
  }

  final remote = ref.watch(paymentRemoteDataSourceProvider);
  try {
    return await remote.getTransaction(
      accessToken: accessToken,
      invoiceId: invoiceId,
    );
  } catch (_) {
    return null;
  }
});

/// Price for a single course pulled from /api/v1/price/:course_id.
/// Returns null when there is no published price for the course (treated as Free).
final coursePriceProvider =
    FutureProvider.family<CoursePriceResponse?, String>((ref, courseId) async {
  final normalizedCourseId = courseId.trim();
  if (normalizedCourseId.isEmpty) {
    return null;
  }

  final accessToken = ref.watch(paymentAccessTokenProvider);
  if (accessToken == null || accessToken.trim().isEmpty) {
    return null;
  }

  final remote = ref.watch(paymentRemoteDataSourceProvider);
  try {
    final price = await remote.fetchCoursePrice(
      accessToken: accessToken,
      courseId: normalizedCourseId,
    );
    if (price.amount <= 0) {
      return null;
    }
    return price;
  } catch (_) {
    return null;
  }
});

import '../../../../core/network/json_http_client.dart';
import '../models/order_models.dart';
import '../models/payment_models.dart';

class PaymentRemoteDataSource {
  PaymentRemoteDataSource(this._client);

  final JsonHttpClient _client;

  Future<OrderResponse> createOrder({
    required String accessToken,
    required OrderRequest request,
  }) async {
    final json = await _client.postJson(
      '/api/v1/order',
      headers: _authHeaders(accessToken),
      body: request.toJson(),
    );
    return OrderResponse.fromJson(json);
  }

  Future<CoursePriceResponse> createCoursePrice({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final json = await _client.postJson(
      '/api/v1/price',
      headers: _authHeaders(accessToken),
      body: body,
    );
    return CoursePriceResponse.fromJson(json);
  }

  Future<CoursePriceResponse> updateCoursePrice({
    required String accessToken,
    required String priceId,
    required int amount,
    required String currency,
  }) async {
    final json = await _client.putJson(
      '/api/v1/price/${Uri.encodeComponent(priceId.trim())}',
      headers: _authHeaders(accessToken),
      body: <String, dynamic>{
        'amount': amount,
        'currency': currency.trim().isEmpty ? 'KZT' : currency.trim(),
      },
    );
    return CoursePriceResponse.fromJson(json);
  }

  Future<CoursePriceResponse> fetchCoursePrice({
    required String accessToken,
    required String courseId,
  }) async {
    final json = await _client.getJson(
      '/api/v1/price/${Uri.encodeComponent(courseId.trim())}',
      headers: _authHeaders(accessToken),
    );
    return CoursePriceResponse.fromJson(json);
  }

  Future<List<PaymentMethod>> fetchPaymentMethods({
    required String accessToken,
  }) async {
    final json = await _client.getJsonList(
      '/api/v1/payment_method',
      headers: _authHeaders(accessToken),
    );
    return json.map(PaymentMethod.fromJson).toList(growable: false);
  }

  Future<GetTokenResponse> getPaymentToken({
    required String accessToken,
    required Map<String, dynamic> body,
  }) async {
    final json = await _client.postJson(
      '/api/v1/payment/token',
      headers: _authHeaders(accessToken),
      body: body,
    );
    return GetTokenResponse.fromJson(json);
  }

  Future<OrderResponse> createPayment({
    required String accessToken,
    required PaymentRequest request,
  }) async {
    final json = await _client.postJson(
      '/api/v1/payment',
      headers: _authHeaders(accessToken),
      body: request.toJson(),
    );
    return OrderResponse.fromJson(json);
  }

  Future<TransactionResponse> getTransaction({
    required String accessToken,
    required String invoiceId,
  }) async {
    final json = await _client.getJson(
      '/api/v1/payment/transaction/${invoiceId.trim()}',
      headers: _authHeaders(accessToken),
    );
    return TransactionResponse.fromJson(json);
  }

  Map<String, String> _authHeaders(String accessToken) {
    return <String, String>{'Authorization': 'Bearer ${accessToken.trim()}'};
  }
}

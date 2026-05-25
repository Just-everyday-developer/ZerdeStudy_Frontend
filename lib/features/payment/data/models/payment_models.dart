class PaymentRequest {
  PaymentRequest({
    required this.orderId,
    this.name,
    this.cryptogram,
    this.cardSave = false,
  });

  final String orderId;
  final String? name;
  final String? cryptogram;
  final bool cardSave;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'order_id': orderId,
    if (name != null && name!.isNotEmpty) 'name': name,
    'cardsave': cardSave,
  };
}

class PaymentResponse {
  PaymentResponse({
    required this.id,
    this.status,
    this.code,
    this.invoiceId,
    this.approvalCode,
    this.cardId,
    this.message,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      id: json['id'] as String? ?? '',
      status: json['status'] as String?,
      code: (json['code'] as num?)?.toInt(),
      invoiceId: json['invoiceID'] as String?,
      approvalCode: json['approvalCode'] as String?,
      cardId: json['cardID'] as String?,
      message: json['message'] as String?,
    );
  }

  final String id;
  final String? status;
  final int? code;
  final String? invoiceId;
  final String? approvalCode;
  final String? cardId;
  final String? message;

  bool get isSuccess => status == 'success' || code == 100;
}

class GetTokenResponse {
  GetTokenResponse({
    required this.accessToken,
    this.expiresIn,
    this.scope,
    this.tokenType,
  });

  factory GetTokenResponse.fromJson(Map<String, dynamic> json) {
    return GetTokenResponse(
      accessToken: json['access_token'] as String? ?? '',
      expiresIn: json['expires_in'] as String?,
      scope: json['scope'] as String?,
      tokenType: json['token_type'] as String?,
    );
  }

  final String accessToken;
  final String? expiresIn;
  final String? scope;
  final String? tokenType;
}

class PaymentMethod {
  PaymentMethod({
    required this.id,
    required this.name,
    required this.code,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
    );
  }

  final String id;
  final String name;
  final String code;
}

class TransactionResponse {
  TransactionResponse({
    required this.resultCode,
    this.resultMessage,
    this.transaction,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      resultCode: json['resultCode'] as String? ?? '',
      resultMessage: json['resultMessage'] as String?,
      transaction: json['transaction'] != null
          ? TransactionData.fromJson(
              json['transaction'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final String resultCode;
  final String? resultMessage;
  final TransactionData? transaction;
}

class TransactionData {
  TransactionData({
    required this.id,
    required this.invoiceId,
    required this.amount,
    this.statusId,
    this.statusName,
    this.cardMask,
    this.cardType,
    this.approvalCode,
  });

  factory TransactionData.fromJson(Map<String, dynamic> json) {
    return TransactionData(
      id: json['id'] as String? ?? '',
      invoiceId: json['invoiceID'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      statusId: json['statusID'] as String?,
      statusName: json['statusName'] as String?,
      cardMask: json['cardMask'] as String?,
      cardType: json['cardType'] as String?,
      approvalCode: json['approvalCode'] as String?,
    );
  }

  final String id;
  final String invoiceId;
  final double amount;
  final String? statusId;
  final String? statusName;
  final String? cardMask;
  final String? cardType;
  final String? approvalCode;
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/state/app_locale.dart';
import '../../../../app/state/demo_app_controller.dart';
import '../../../../app/state/demo_models.dart';
import '../../../../core/common_widgets/app_button.dart';
import '../../../../core/common_widgets/app_notice.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../../../features/courses_backend/presentation/providers/backend_course_providers.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../data/models/order_models.dart';
import '../../data/models/payment_models.dart';
import '../providers/payment_providers.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({
    super.key,
    required this.courseId,
    required this.amount,
    this.currency = 'KZT',
  });

  final String courseId;
  final int amount;
  final String currency;

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  OrderResponse? _createdOrder;
  int? _backendAmount;
  String? _backendCurrency;

  // Test card data
  static const String _testPan = '4405639704015096';
  static const String _testExpiry = '01/27';
  static const String _testCvc = '321';

  int get _displayAmount {
    final backendAmount = _createdOrder?.amount ?? 0;
    if (backendAmount > 0) {
      return backendAmount;
    }
    final coursePriceAmount = _backendAmount ?? 0;
    return coursePriceAmount > 0 ? coursePriceAmount : widget.amount;
  }

  String get _displayCurrency {
    final backendCurrency = _createdOrder?.currency.trim() ?? '';
    if (backendCurrency.isNotEmpty) {
      return backendCurrency;
    }
    final coursePriceCurrency = _backendCurrency?.trim() ?? '';
    return coursePriceCurrency.isNotEmpty
        ? coursePriceCurrency
        : widget.currency;
  }

  String get _displayStatus {
    final status = _createdOrder?.status.trim() ?? '';
    return status.isEmpty ? 'unknown' : status;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCoursePrice());
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final catalog = ref.watch(demoCatalogProvider);
    final state = ref.watch(demoAppControllerProvider);
    final course = catalog.maybeCourseById(widget.courseId);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text(
          'Оплата курса',
          style: TextStyle(color: colors.textPrimary),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course info card
            _buildCourseInfoCard(colors, course, state.locale),
            const SizedBox(height: 24),

            // Payment form
            _buildPaymentForm(colors),
            const SizedBox(height: 24),

            // Quick fill test card button
            _buildTestCardButton(colors),
            const SizedBox(height: 24),

            // Pay button
            _buildPayButton(colors),

            if (_createdOrder != null) ...[
              const SizedBox(height: 16),
              _buildOrderInfo(colors),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCourseInfoCard(
    AppThemeColors colors,
    CommunityCourse? course,
    AppLocale locale,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: course?.color ?? colors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.school_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course?.title.resolve(locale) ?? 'Course',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_displayAmount $_displayCurrency',
                  style: TextStyle(
                    color: colors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentForm(AppThemeColors colors) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Данные карты',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),

          // Card holder
          TextFormField(
            controller: _cardHolderController,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Держатель карты',
              labelStyle: TextStyle(color: colors.textSecondary),
              filled: true,
              fillColor: colors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Введите имя держателя карты';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Card number
          TextFormField(
            controller: _cardNumberController,
            style: TextStyle(color: colors.textPrimary),
            keyboardType: TextInputType.number,
            maxLength: 19,
            decoration: InputDecoration(
              labelText: 'Номер карты',
              labelStyle: TextStyle(color: colors.textSecondary),
              hintText: '0000 0000 0000 0000',
              hintStyle: TextStyle(
                color: colors.textSecondary.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: colors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: Icon(Icons.credit_card, color: colors.textSecondary),
            ),
            onChanged: _formatCardNumber,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Введите номер карты';
              }
              final cleaned = value.replaceAll(' ', '');
              if (cleaned.length < 16) {
                return 'Неполный номер карты';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // Expiry
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  style: TextStyle(color: colors.textPrimary),
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  decoration: InputDecoration(
                    labelText: 'Срок действия',
                    labelStyle: TextStyle(color: colors.textSecondary),
                    hintText: 'MM/YY',
                    hintStyle: TextStyle(
                      color: colors.textSecondary.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _formatExpiry,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите срок';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              // CVC
              Expanded(
                child: TextFormField(
                  controller: _cvcController,
                  style: TextStyle(color: colors.textPrimary),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'CVC/CVV',
                    labelStyle: TextStyle(color: colors.textSecondary),
                    hintText: '***',
                    hintStyle: TextStyle(
                      color: colors.textSecondary.withValues(alpha: 0.5),
                    ),
                    filled: true,
                    fillColor: colors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите CVC';
                    }
                    if (value.length < 3) {
                      return 'Неполный CVC';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestCardButton(AppThemeColors colors) {
    return OutlinedButton.icon(
      onPressed: () {
        _cardNumberController.text = _testPan;
        _expiryController.text = _testExpiry;
        _cvcController.text = _testCvc;
        _cardHolderController.text = 'Test User';
      },
      icon: Icon(Icons.science_rounded, color: colors.accent),
      label: Text(
        'Заполнить тестовую карту',
        style: TextStyle(color: colors.textSecondary),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        side: BorderSide(color: colors.divider),
      ),
    );
  }

  Widget _buildPayButton(AppThemeColors colors) {
    return AppButton.primary(
      onPressed: _isProcessing ? null : _processPayment,
      label: _isProcessing
          ? 'Обработка...'
          : 'Оплатить $_displayAmount $_displayCurrency',
    );
  }

  Widget _buildOrderInfo(AppThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Заказ создан: ${_createdOrder!.id}',
            style: TextStyle(color: colors.textPrimary, fontSize: 12),
          ),
          Text(
            'Статус: $_displayStatus',
            style: TextStyle(color: colors.success, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _formatCardNumber(String value) {
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    if (cleaned.length != value.replaceAll(' ', '').length) {
      _cardNumberController.value = TextEditingValue(
        text: buffer.toString(),
        selection: TextSelection.collapsed(offset: buffer.length),
      );
    }
  }

  void _formatExpiry(String value) {
    final cleaned = value.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length >= 2) {
      final formatted = '${cleaned.substring(0, 2)}/${cleaned.substring(2)}';
      if (formatted != value) {
        _expiryController.value = TextEditingValue(
          text: formatted.length > 5 ? formatted.substring(0, 5) : formatted,
          selection: TextSelection.collapsed(
            offset: formatted.length > 5 ? 5 : formatted.length,
          ),
        );
      }
    }
  }

  Future<void> _loadCoursePrice() async {
    final accessToken = ref.read(backendCourseAccessTokenProvider);
    if (accessToken == null || accessToken.trim().isEmpty) {
      return;
    }

    try {
      final price = await ref
          .read(paymentRemoteDataSourceProvider)
          .fetchCoursePrice(
            accessToken: accessToken,
            courseId: widget.courseId,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        if (price.amount > 0) {
          _backendAmount = price.amount;
        }
        if (price.currency.trim().isNotEmpty) {
          _backendCurrency = price.currency.trim();
        }
      });
    } catch (_) {
      // Keep the route amount as a fallback until the order response arrives.
    }
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    try {
      // 1. Get auth session
      final accessToken = ref.read(backendCourseAccessTokenProvider);
      if (accessToken == null || accessToken.trim().isEmpty) {
        if (!mounted) return;
        AppNotice.show(
          context,
          message: 'Необходимо авторизоваться',
          type: AppNoticeType.error,
        );
        setState(() => _isProcessing = false);
        return;
      }

      final authUserId = ref.read(
        authControllerProvider.select((state) => state.session?.user.id),
      );
      if (authUserId == null) {
        if (!mounted) return;
        AppNotice.show(
          context,
          message: 'ID пользователя не найден',
          type: AppNoticeType.error,
        );
        setState(() => _isProcessing = false);
        return;
      }

      // 2. Create order
      final orderRequest = OrderRequest(
        userId: authUserId,
        courseId: widget.courseId,
        amount: _displayAmount,
        currency: _displayCurrency,
      );

      final paymentRemote = ref.read(paymentRemoteDataSourceProvider);
      final order = await paymentRemote.createOrder(
        accessToken: accessToken,
        request: orderRequest,
      );

      if (!mounted) return;
      setState(() => _createdOrder = order);

      // 3. Call backend payment endpoint with cryptogram (empty -> server generates test card)
      final paymentRequest = PaymentRequest(
        orderId: order.id,
        name: _cardHolderController.text.trim(),
        cryptogram: '', // Empty -> server uses hardcoded test card
        cardSave: false,
      );

      final paidOrder = await paymentRemote.createPayment(
        accessToken: accessToken,
        request: paymentRequest,
      );

      if (!mounted) return;
      setState(() => _createdOrder = paidOrder);

      AppNotice.show(
        context,
        message: 'Статус оплаты: $_displayStatus',
        type: switch (paidOrder.status) {
          'paid' => AppNoticeType.success,
          'failed' || 'canceled' || 'refunded' => AppNoticeType.error,
          _ => AppNoticeType.info,
        },
        duration: const Duration(seconds: 6),
      );

      if (paidOrder.status == 'paid') {
        ref
            .read(demoAppControllerProvider.notifier)
            .enrollCommunityCourse(widget.courseId);

        // Sync enrollment to backend so progress/achievements track correctly.
        await backendEnrollCourse(ref, widget.courseId);
        ref.invalidate(backendAchievementsProvider);
        ref.invalidate(backendAllProgressProvider);

        if (!mounted) return;
        // Navigate to course player
        context.go(AppRoutes.coursePlayerById(widget.courseId));
      }
    } catch (e) {
      if (!mounted) return;
      AppNotice.show(
        context,
        message: 'Ошибка при обработке платежа: $e',
        type: AppNoticeType.error,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}

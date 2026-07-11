// Modelos del módulo de Suscripciones y Pagos
// Cubre: Subscription, UserSubscription, Payment, Order

// ─── Subscription ─────────────────────────────────────────────────────────────

class SubscriptionModel {
  const SubscriptionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    this.features = const [],
    this.isActive = true,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final List<String> features;
  final bool isActive;

  bool get isFree => price == 0.0;

  String get formattedPrice =>
      isFree ? 'Gratis' : '\$${price.toStringAsFixed(2)}';

  String get durationLabel {
    if (durationDays == 30) return '1 mes';
    if (durationDays == 90) return '3 meses';
    if (durationDays == 365) return '1 año';
    return '$durationDays días';
  }

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features'];
    List<String> parsedFeatures;
    if (rawFeatures is String) {
      parsedFeatures = rawFeatures.isEmpty
          ? []
          : rawFeatures.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else if (rawFeatures is List) {
      parsedFeatures = rawFeatures.map((e) => e.toString()).toList();
    } else {
      parsedFeatures = [];
    }
    return SubscriptionModel(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationDays: json['duration_days'] as int? ?? 30,
      features: parsedFeatures,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'duration_days': durationDays,
        'features': features,
        'is_active': isActive,
      };
}

// ─── UserSubscription ─────────────────────────────────────────────────────────

class UserSubscriptionModel {
  const UserSubscriptionModel({
    required this.id,
    required this.subscription,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  final int id;
  final SubscriptionModel subscription;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  bool get isExpired => DateTime.now().isAfter(endDate);
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  factory UserSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionModel(
      id: json['id'] as int,
      subscription: SubscriptionModel.fromJson(
          json['subscription'] as Map<String, dynamic>),
      startDate: DateTime.tryParse(json['start_date']?.toString() ?? '') ??
          DateTime.now(),
      endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ??
          DateTime.now(),
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}

// ─── Payment ──────────────────────────────────────────────────────────────────

class PaymentModel {
  const PaymentModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.method,
    required this.createdAt,
    this.transactionId,
  });

  final int id;
  final double amount;
  final String status; // 'pending' | 'completed' | 'failed' | 'refunded'
  final String method;
  final DateTime createdAt;
  final String? transactionId;

  bool get isCompleted => status == 'completed';

  String get statusLabel {
    const labels = {
      'pending': 'Pendiente',
      'completed': 'Completado',
      'failed': 'Fallido',
      'refunded': 'Reembolsado',
    };
    return labels[status] ?? status;
  }

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as int,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      method: json['payment_method']?.toString() ?? json['method']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      transactionId: json['transaction_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'status': status,
        'method': method,
        'created_at': createdAt.toIso8601String(),
        'transaction_id': transactionId,
      };
}

// ─── Order ────────────────────────────────────────────────────────────────────

class OrderModel {
  const OrderModel({
    required this.id,
    required this.subscriptionId,
    this.subscriptionDetail,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final int subscriptionId;
  final SubscriptionModel? subscriptionDetail;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final sub = json['subscription'];
    int subId;
    SubscriptionModel? subDetail;
    if (sub is Map) {
      subDetail = SubscriptionModel.fromJson(Map<String, dynamic>.from(sub));
      subId = subDetail.id;
    } else {
      subId = sub as int? ?? 0;
    }
    return OrderModel(
      id: json['id'] as int,
      subscriptionId: subId,
      subscriptionDetail: subDetail,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

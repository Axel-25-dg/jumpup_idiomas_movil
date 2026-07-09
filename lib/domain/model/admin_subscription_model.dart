class Subscription {
  final int id;
  final String name;
  final double price;
  final int durationDays;
  final String features;

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.features,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json['id'],
        name: json['name'],
        price: double.parse(json['price'].toString()),
        durationDays: json['duration_days'],
        features: json['features'],
      );
}

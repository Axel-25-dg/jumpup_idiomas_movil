class TwoFactorRequest {
  const TwoFactorRequest({required this.code});

  final String code;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
    };
  }
}

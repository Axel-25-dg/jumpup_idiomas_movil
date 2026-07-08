class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.errors = const [],
  });

  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final List<String> errors;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(Object? value)? fromJsonT,
  }) {
    final payload = json['data'];

    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString(),
      data: fromJsonT != null && payload != null
          ? fromJsonT(payload)
          : payload as T?,
      statusCode: json['statusCode'] as int?,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((error) => error.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson({Object? Function(T? value)? toJsonT}) {
    return {
      'success': success,
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data) : data,
      'statusCode': statusCode,
      'errors': errors,
    };
  }
}

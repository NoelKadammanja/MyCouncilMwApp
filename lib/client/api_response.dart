class ApiResponse {
  final int? statusCode;
  final dynamic body;
  final String? error;

  ApiResponse({this.statusCode, this.body, this.error});

  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;
}

class ResModel {
  final dynamic error;
  final dynamic data;
  final dynamic message;

  ResModel({this.error, this.data, this.message});

  Map<String, dynamic> toJson() => {
    "error": error ?? "",
    "data": data ?? "",
    "message": message ?? "",
  };
}

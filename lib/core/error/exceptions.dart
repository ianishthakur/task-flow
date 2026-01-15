class DatabaseException implements Exception {
  final String message;
  
  DatabaseException([this.message = 'Database exception occurred']);
  
  @override
  String toString() => 'DatabaseException: $message';
}

class CacheException implements Exception {
  final String message;
  
  CacheException([this.message = 'Cache exception occurred']);
  
  @override
  String toString() => 'CacheException: $message';
}

class ValidationException implements Exception {
  final String message;
  
  ValidationException([this.message = 'Validation exception occurred']);
  
  @override
  String toString() => 'ValidationException: $message';
}

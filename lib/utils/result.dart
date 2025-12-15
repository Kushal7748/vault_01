/// A generic Result type to handle Success and Failure states
sealed class Result<T> {
  const Result();

  /// Helper to execute logic based on the result
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Exception? error) failure,
  });
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Exception? error) failure,
  }) {
    return success(data);
  }
}

class Failure<T> extends Result<T> {
  final String message;
  final Exception? error;

  const Failure(this.message, [this.error]);

  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Exception? error) failure,
  }) {
    return failure(message, error);
  }
}

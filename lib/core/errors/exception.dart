class ListingAccessException implements Exception {
  final String message;

  const ListingAccessException(this.message);
}

class ListingNotFoundException implements Exception {
  final String message;

  const ListingNotFoundException(this.message);
}

/// Thrown when listing image uploads fail.
///
/// Covers network, timeout, HTTP, and malformed-response failures raised by
/// the Supabase Edge Function client. Authentication problems reuse
/// [ListingAccessException] so they keep mapping to `AuthFailure`.
class ListingImageUploadException implements Exception {
  final String message;

  const ListingImageUploadException(this.message);

  @override
  String toString() => message;
}

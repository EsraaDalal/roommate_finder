
class Roommate {
  const Roommate({
    required this.initials,
    required this.name,
    required this.tagline,
        this.userId,
  });

  final String initials;
  final String name;
  final String tagline;
    final String? userId;
}

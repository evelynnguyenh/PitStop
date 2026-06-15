class Restaurant {
  final String name;
  final String imagePath;
  final double rating;
  final double distanceKm;
  final List<String> tags;

  const Restaurant({
    required this.name,
    required this.imagePath,
    required this.rating,
    required this.distanceKm,
    required this.tags,
  });
}
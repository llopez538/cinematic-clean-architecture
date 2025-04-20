class Film {
  final int id;
  final String title;
  final String? overview;
  final String? releaseDate;
  final String? fullPosterPath;
  final String? fullBackdropPath;

  Film({
    required this.id,
    required this.title,
    this.overview,
    this.releaseDate,
    this.fullPosterPath,
    this.fullBackdropPath,
  });
}

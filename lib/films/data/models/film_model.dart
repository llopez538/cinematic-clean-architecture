import 'package:cinematic/films/domain/models/film.dart';

class FilmModel extends Film {
  FilmModel({
    required int id,
    required String title,
    String? overview,
    String? releaseDate,
    String? fullPosterPath,
    String? fullBackdropPath,
  }) : super(
          id: id,
          title: title,
          overview: overview,
          releaseDate: releaseDate,
          fullPosterPath: fullPosterPath,
          fullBackdropPath: fullBackdropPath,
        );

  factory FilmModel.fromJson(Map<String, dynamic> json) {
    return FilmModel(
      id: json['id'],
      title: json['title'],
      overview: json['overview'],
      releaseDate: json['release_date'],
      fullPosterPath: json['poster_path'],
      fullBackdropPath: json['backdrop_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'release_date': releaseDate,
      'poster_path': fullPosterPath,
      'backdrop_path': fullBackdropPath,
    };
  }
}

import 'package:cinematic/films/data/models/film.dart';
import 'package:cinematic/films/domain/repository/film_repository.dart';

class GetFilmDetail {
  final FilmRepository repository;

  GetFilmDetail(this.repository);

  Future<Film> call(int filmId) async {
    return await repository.getFilmDetail(filmId);
  }
}

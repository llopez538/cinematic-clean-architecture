import 'package:cinematic/films/data/models/film.dart';

abstract class FilmRepository {
  Future<List<Film>> getFilms(int page, int genre);
  Future<Film> getFilmDetail(int filmId);
  Future<bool> hasInternetConnection();
}

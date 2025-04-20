import 'package:cinematic/films/data/models/film.dart';
import 'package:cinematic/films/domain/repository/film_repository.dart';

class GetFilms {
  final FilmRepository repository;

  GetFilms(this.repository);

  Future<List<Film>> call(int page, int genre) async {
    return await repository.getFilms(page, genre);
  }
}

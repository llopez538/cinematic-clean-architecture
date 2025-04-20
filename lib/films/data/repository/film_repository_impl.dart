import 'package:cinematic/films/data/datasources/film_local_datasource.dart';
import 'package:cinematic/films/data/datasources/film_remote_datasource.dart';
import 'package:cinematic/films/data/models/film.dart';
import 'package:cinematic/films/domain/repository/film_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FilmRepositoryImpl implements FilmRepository {
  final FilmRemoteDataSource remoteDataSource;
  final FilmLocalDataSource localDataSource;
  final Connectivity connectivity;

  FilmRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<List<Film>> getFilms(int page, int genre) async {
    final hasInternet = await hasInternetConnection();
    
    if (hasInternet) {
      try {
        final films = await remoteDataSource.getFilms(page, genre);
        await localDataSource.cacheFilms(page, genre, films);
        return films;
      } catch (e) {
        final cachedFilms = await localDataSource.getCachedFilms(page, genre);
        if (cachedFilms != null) return cachedFilms;
        rethrow;
      }
    } else {
      final cachedFilms = await localDataSource.getCachedFilms(page, genre);
      if (cachedFilms != null) return cachedFilms;
      throw Exception('No internet connection and no cached data available');
    }
  }

  @override
  Future<Film> getFilmDetail(int filmId) async {
    return await remoteDataSource.getFilmDetail(filmId);
  }

  @override
  Future<bool> hasInternetConnection() async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}

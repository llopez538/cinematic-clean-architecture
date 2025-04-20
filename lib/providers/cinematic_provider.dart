import 'package:flutter/foundation.dart';
import 'package:cinematic/films/data/models/film.dart';
import 'package:cinematic/films/domain/usecase/get_films.dart';
import 'package:cinematic/films/domain/usecase/get_film_detail.dart';

class FilmProvider extends ChangeNotifier {
  late GetFilms getFilms;
  late GetFilmDetail getFilmDetail;

  final List<Film> _movies = [];
  Film? _selectedFilm;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isUsingCache = false;
  String? _error;

  void updateUseCases({
    required GetFilms getFilms,
    required GetFilmDetail getFilmDetail,
  }) {
    getFilms = getFilms;
    getFilmDetail = getFilmDetail;
  }

  List<Film> get movies => List.unmodifiable(_movies);
  Film? get selectedFilm => _selectedFilm;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get isUsingCache => _isUsingCache;
  String? get error => _error;

  FilmProvider({
    required this.getFilms,
    required this.getFilmDetail,
  });

  Future<void> loadMovies({bool refresh = false, int genre = 16}) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;

      if (refresh) {
        _currentPage = 1;
        _movies.clear();
        _hasMore = true;
      }

      if (!_hasMore) return;

      final films = await getFilms(_currentPage, genre);

      _movies.addAll(films);
      _hasMore = films.isNotEmpty;
      _currentPage++;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners()); // Diferir la notificación
    }
  }

  Future<void> loadFilmDetail(int filmId) async {
    if (_isLoading) return;

    try {
      _isLoading = true;
      _error = null;

      _selectedFilm = await getFilmDetail(filmId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners()); // Diferir la notificación
    }
  }

  Future<void> loadNextPage({int genre = 16}) async {
    if (_hasMore && !_isLoading) {
      await loadMovies(genre: genre);
    }
  }

  void clear() {
    _movies.clear();
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    _isUsingCache = false;
    notifyListeners();
  }
}


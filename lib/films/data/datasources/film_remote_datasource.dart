import 'dart:convert';

import 'package:cinematic/films/data/models/film.dart';
import 'package:http/http.dart' as http;

abstract class FilmRemoteDataSource {
  Future<List<Film>> getFilms(int page, int genre);
  Future<Film> getFilmDetail(int filmId);
}

class FilmRemoteDataSourceImpl implements FilmRemoteDataSource {
  final http.Client client;
  static const _baseUrl = 'https://api.themoviedb.org/3';
  static const _apiKey = '';

  FilmRemoteDataSourceImpl({required this.client});

  @override
  Future<List<Film>> getFilms(int page, int genre) async {
    final response = await client.get(
      Uri.parse(
        '$_baseUrl/discover/movie?'
        'include_adult=true&'
        'include_video=false&'
        'language=en-US&'
        'page=$page&'
        'sort_by=popularity.desc&'
        'with_genres=$genre',
      ),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return (data['results'] as List)
          .map((json) => Film.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load films: ${response.statusCode}');
    }
  }

  @override
  Future<Film> getFilmDetail(int filmId) async {
    final response = await client.get(
      Uri.parse('$_baseUrl/movie/$filmId'),
      headers: {
        'accept': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
    );

    if (response.statusCode == 200) {
      return Film.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load film detail: ${response.statusCode}');
    }
  }
}
import 'package:cinematic/films/data/datasources/film_local_datasource.dart';
import 'package:cinematic/films/data/datasources/film_remote_datasource.dart';
import 'package:cinematic/films/domain/repository/film_repository.dart';
import 'package:cinematic/films/data/repository/film_repository_impl.dart';
import 'package:cinematic/films/domain/usecase/get_film_detail.dart';
import 'package:cinematic/films/domain/usecase/get_films.dart';
import 'package:cinematic/films/presentation/home/billboard_screen.dart';
import 'package:cinematic/films/presentation/detail/detail_film_screen.dart';
import 'package:cinematic/providers/cinematic_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Proveedores independientes
        Provider<Connectivity>(create: (_) => Connectivity()),
        Provider<http.Client>(create: (_) => http.Client()),
        
        // DataSources
        Provider<FilmRemoteDataSource>(
          create: (context) => FilmRemoteDataSourceImpl(
            client: context.read<http.Client>(),
          ),
        ),
        Provider<FilmLocalDataSource>(
          create: (_) => FilmLocalDataSourceImpl(),
          dispose: (_, ds) => ds.close(),
        ),

        // Repository - IMPORTANTE: Usa ProxyProvider sin dependencia previa
        Provider<FilmRepository>(
          create: (context) => FilmRepositoryImpl(
            remoteDataSource: context.read<FilmRemoteDataSource>(),
            localDataSource: context.read<FilmLocalDataSource>(),
            connectivity: context.read<Connectivity>(),
          ),
        ),

        // Use Cases
        Provider<GetFilms>(
          create: (context) => GetFilms(context.read<FilmRepository>()),
        ),
        Provider<GetFilmDetail>(
          create: (context) => GetFilmDetail(context.read<FilmRepository>()),
        ),

        // Main Provider
        ChangeNotifierProvider<FilmProvider>(
          create: (context) => FilmProvider(
            getFilms: context.read<GetFilms>(),
            getFilmDetail: context.read<GetFilmDetail>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Cinematic',
        theme: ThemeData(
          searchBarTheme: SearchBarThemeData(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.0)),
            ),
            elevation: WidgetStateProperty.all(0),
          ),
        ),
        initialRoute: '/',
        routes: {'/': (context) => const BillboardScreen()},
        onGenerateRoute: (settings) {
          if (settings.name == DetailFilmScreen.routeName) {
            final filmId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => DetailFilmScreen(filmId: filmId),
            );
          }
          return null;
        },
      ),
    );
  }
}

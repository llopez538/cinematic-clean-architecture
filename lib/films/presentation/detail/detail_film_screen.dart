import 'package:cinematic/core/ui/components/atoms/primary_button.dart';
import 'package:cinematic/core/ui/components/atoms/title_section.dart';
import 'package:cinematic/core/ui/components/molecules/metadata_row.dart';
import 'package:cinematic/core/ui/components/organisms/action_buttons_row.dart';
import 'package:cinematic/core/ui/components/organisms/play_button_row.dart';
import 'package:cinematic/core/ui/templates/detail_film_template.dart';
import 'package:cinematic/films/data/models/film.dart';
import 'package:cinematic/providers/cinematic_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Asegúrate de importar tu provider

class DetailFilmScreen extends StatefulWidget {
  static const routeName = '/details';
  final int filmId;

  const DetailFilmScreen({super.key, required this.filmId});

  @override
  State<DetailFilmScreen> createState() => _DetailFilmScreenState();
}

class _DetailFilmScreenState extends State<DetailFilmScreen> {
  @override
  void initState() {
    super.initState();
    _loadFilmDetails();
  }

  Future<void> _loadFilmDetails() async {
    final provider = context.read<FilmProvider>();
    if (provider.selectedFilm?.id != widget.filmId) {
      await provider.loadFilmDetail(widget.filmId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filmProvider = context.watch<FilmProvider>();

    return Scaffold(
      body:
          filmProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filmProvider.error != null
              ? Center(child: Text('Error: ${filmProvider.error}'))
              : filmProvider.selectedFilm == null
              ? const Center(child: Text('Película no encontrada'))
              : _buildContent(filmProvider.selectedFilm!),
    );
  }

  Widget _buildContent(Film film) {
    return DetailFilmTemplate(
      film: film,
      content: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitleSection(film: film),
              const SizedBox(height: 8),
              MetadataRow(
                items: [
                  film.releaseDate?.substring(0, 4) ?? 'N/A',
                  'Temporada 4', // Deberías obtener esto de los géneros reales
                ],
              ),
              const SizedBox(height: 20),
              _buildDescription(film.overview),
              const SizedBox(height: 30),
              const ActionButtonsRow(),
              const SizedBox(height: 30),
              PrimaryButton(
                text: 'Comenzar a ver',
                onPressed: () => _handlePlay(film),
              ),
              const SizedBox(height: 20),
              const PlayButtonRow(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  void _handlePlay(Film film) {
    // Implementar lógica de reproducción
  }

  Widget _buildDescription(String overview) {
    return Text(
      overview,
      style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
      textAlign: TextAlign.justify,
    );
  }
}

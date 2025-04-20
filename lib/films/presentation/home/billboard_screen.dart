import 'package:cinematic/core/ui/components/atoms/search_input.dart';
import 'package:cinematic/core/ui/components/molecules/error_view.dart';
import 'package:cinematic/core/ui/components/molecules/loading_footer.dart';
import 'package:cinematic/core/ui/components/molecules/no_more_items.dart';
import 'package:cinematic/core/ui/components/molecules/main_carousel.dart';
import 'package:cinematic/core/ui/components/organisms/favorites_section.dart';
import 'package:cinematic/core/ui/components/organisms/movies_grid.dart';
import 'package:cinematic/core/ui/templates/billboard_template.dart';
import 'package:cinematic/films/presentation/detail/detail_film_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cinematic/films/data/models/film.dart';
import 'package:cinematic/providers/cinematic_provider.dart';

class BillboardScreen extends StatefulWidget {
  static const routeName = '/billboard';

  const BillboardScreen({super.key});

  @override
  State<BillboardScreen> createState() => _BillboardScreenState();
}

class _BillboardScreenState extends State<BillboardScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final double _scrollThreshold = 200;
  final TextEditingController _searchController = TextEditingController();

  @override
  bool get wantKeepAlive => true; // Mantener el estado de la pantalla

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      await context.read<FilmProvider>().loadMovies(refresh: true);
      if (mounted) {
        setState(() => _searchController.clear());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= _scrollThreshold) {
      context.read<FilmProvider>().loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necesario para AutomaticKeepAliveClientMixin
    final filmProvider = context.watch<FilmProvider>();
    final filteredFilm = _searchList(filmProvider.movies);

    return BillboardTemplate(
      title: 'Cinematic Billboard',
      onRefresh: _loadInitialData,
      scrollController: _scrollController,
      slivers: [
        if (filmProvider.isLoading && filmProvider.movies.isEmpty)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else if (filmProvider.error != null)
          SliverToBoxAdapter(
            child: ErrorView(
              message: filmProvider.error!,
              onRetry: _loadInitialData,
            ),
          )
        else ...[
          MainCarousel(
            films: filmProvider.movies.reversed.toList(),
            onFilmSelected: _navigateToDetail,
          ),
          _buildSearchSection(),
          const FavoritesSection(),
          MoviesGrid(movies: filteredFilm, onMovieSelected: _navigateToDetail),
          _buildFooter(filmProvider, filteredFilm),
        ],
      ],
    );
  }

  Widget _buildFooter(FilmProvider filmProvider, List<Film> filteredFilm) {
    if (filmProvider.isLoading && filteredFilm.isNotEmpty) {
      return const SliverLoadingFooter();
    }
    if (!filmProvider.hasMore || filteredFilm.isEmpty) {
      return const SliverNoMoreItems();
    }
    return const SliverToBoxAdapter();
  }

  Widget _buildSearchSection() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverToBoxAdapter(
        child: SearchInput(
          controller: _searchController,
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  void _onSearchChanged(String query) => setState(() {});

  List<Film> _searchList(List<Film> filmList) {
    return filmList
        .where(
          (film) =>
              film.title.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ) ||
              film.originalTitle.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ),
        )
        .toList();
  }

  void _navigateToDetail(Film film) {
    Navigator.pushNamed(
      context,
      DetailFilmScreen.routeName,
      arguments: film.id,
    );
  }
}

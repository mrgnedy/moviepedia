import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:session3/movie_card.dart';
import 'package:session3/movie_mode.dart';
import 'package:session3/movies_card.dart';
import 'package:session3/scoped_mode.dart';
import 'package:switches_kit/switches_kit.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  TabController _tabController;
  MainModel model;
  List<Widget> moviesCards = [];
  List<Widget> tvCards = [];
  bool _isLoading = false;
  bool _isProcessing = false;
  @override
  void initState() {
    model = ScopedModel.of(context);
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _tabController.addListener(callback);
    _isLoading = true;
    getPops();
    // .then((s) {
    //    moviesCards =s;
    // });
    super.initState();
  }

  Future fetchMoviesPop(String mediaType, List types) async {
    _isLoading = true;
    setState(() {});
    // moviesCards = [];
    List<Future<Widget>> futures = [];
    for (int index = 0; index < types.length; index++) {
      futures.add(model
          .fetchDiscover(
              'https://api.themoviedb.org/3/$mediaType/${types[index]}?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US',
              mediaType: mediaType)
          .then((fetchedMovies) {
        model.popularType = types[index];
        return MoviesCard(fetchedMovies, 'homeCard', 'titleCard',
            genre: types[index], index: index);

        // model.notifyListeners();
      }));

      // fetchGenres();
      // return MoviesCard(movies);
      // print(movies[index].img);
    }
    return Future.wait(futures);
    // .then((s) {
    //   _isLoading = false;
    //   setState(() {});
    //   return s;
    // });
  }

  Future getPops() {
    return fetchMoviesPop('movie', populars).then((s) {
      moviesCards = s;
      _isLoading = false;
      setState(() {});
    }).then((_) {
      fetchMoviesPop('tv', popularTV).then((s) {
        _isLoading = false;
        tvCards = s;
        setState(() {});
      });
    });
  }

  callback() {
    if (_tabController.index == 1) {
      fetchGenres();
      _tabController.removeListener(callback);
    }
  }

  String direction = '.desc';
  List<String> sortBy = [
    'popularity',
    'release_date',
    'primary_release_date',
    'revenue',
    'original_title',
    'vote_average',
    'vote_count'
  ];
  List<Map<String, bool>> genres = [
    {'Action': true},
    {'Adventure': true},
    {'Animation': true},
    {'Comedy': false},
    {'Crime': false},
    {'Documentary': false},
    {'Drama': false},
    {'Family': false},
    {'Fantasy': false},
    {'History': false},
    {'Horror': false},
    {'Music': false},
    {'Mystery': false},
    {'Romance': false},
    {'Sci-Fi': false},
    {'TV Movie': false},
    {'Thriller': false},
    {'War': false},
    {'Western': false},
    {'Action & Adventure': false},
    {'Sci-Fi & Family': false},
    {'Soap': false},
    {'Talk': false},
    {'War & Politics': false},
  ];

  List<List<Movie>> moviesByGenres = [];
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  List<String> populars = [
    'top_rated',
    'now_playing',
    'popular',
    'upcoming',
  ];
  List<String> popularTV = [
    'airing_today',
    'on_the_air',
    'popular',
    'top_rated'
  ];
  // List<List<Movie>> movies = [];
  String currentGenre = 'popularity';

  List<Widget> genreMovieList = [];
  bool isExpanded = false;
  bool isAscending = false;
  fetchGenres() {
    final reducedGenres = genres.where((s) {
      return s.values.first == true;
    }).toList();
    moviesByGenres = [];

    genreMovieList = [];
    for (int index = 0; index < reducedGenres.length; index++) {
      model
          .fetchDiscover(
              'https://api.themoviedb.org/3/discover/movie?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&sort_by=$currentGenre$direction&include_adult=false&include_video=false&page=1&with_genres=${model.genres[reducedGenres[index].keys.first]}')
          .then((fetchedMovie) {
        genreMovieList.insert(
            0,
            MoviesCard(
              fetchedMovie,
              'genreCard',
              'genreTitle',
              index: index,
              genre: reducedGenres[index].keys.first,
            ));
        setState(() {});
      });
    }
  }

  bool typeToggle = true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    // moviesByGenres.isEmpty? fetchGenres(): null;
    return Container(
      // height: MediaQuery.of(context).size.height,
      child: Column(
        // addAutomaticKeepAlives:true ,
        // addRepaintBoundaries: true,
        // shrinkWrap: true,
        children: <Widget>[
          Container(
            height: 100,
            child: AppBar(
              bottom: TabBar(
                controller: _tabController,
                tabs: <Widget>[
                  Tab(
                    icon: Icon(Icons.whatshot),
                    text: 'Popular',
                  ),
                  Tab(
                    icon: Icon(Icons.web),
                    text: 'Genres',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            // height: MediaQuery.of(context).size.height -
            //     kBottomNavigationBarHeight -
            //     kToolbarHeight -
            //     50,
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                RefreshIndicator(
                  onRefresh: () => getPops(),
                  child: Container(
                    // height: MediaQuery.of(context).size.height / 2.1,
                    child: _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : ListView(
                            shrinkWrap: true,
                            addAutomaticKeepAlives: true,
                            children: [
                              Align(
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 100,
                                  child: LabeledToggle(
                                    thumbSize: 30,
                                    offText: 'TV',
                                    onText: 'Movies',
                                    curve: Curves.easeInOut,
                                    value: typeToggle,
                                    transitionType: TextTransitionTypes.SCALE,
                                    duration: Duration(milliseconds: 500),
                                    offTextColor:
                                        Theme.of(context).appBarTheme.color,
                                    onTextColor: Colors.white,
                                    offBkColor: Color.fromRGBO(80, 88, 108, 1),
                                    offBorderColor: Colors.white,
                                    onThumbColor:
                                        Theme.of(context).appBarTheme.color,
                                    onBkColor: Color.fromRGBO(80, 88, 108, 1),
                                    offThumbColor: Colors.white,
                                    onBorderColor: Colors.white,

                                    // rotationAnimation: false,
                                    onChanged: (b) {
                                      typeToggle = b;
                                      setState(() {});
                                    },
                                  ),
                                ),
                              )
                            ]..addAll(typeToggle ? moviesCards : tvCards),
                          ),
                  ),
                ),
                Scaffold(
                  floatingActionButton: FloatingActionButton.extended(
                    icon: Container(
                        padding: EdgeInsets.only(left: 9),
                        child: Icon(
                            isExpanded ? Icons.chevron_right : Icons.sort)),
                    isExtended: isExpanded,
                    onPressed: () {
                      isExpanded = !isExpanded;
                      setState(() {});
                    },
                    label: !isExpanded
                        ? Container()
                        : Row(
                            children: <Widget>[
                              DropdownButton(
                                icon: Container(),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                items: List.generate(
                                  sortBy.length,
                                  (index) {
                                    return DropdownMenuItem(
                                      child: Container(
                                        // width: genres[index].keys.first.length*7.0,
                                        alignment: Alignment.center,
                                        width: 100,
                                        child: Container(
                                          // width: 20,
                                          child: Text(
                                            sortBy[index],
                                            // maxLines: 1,
                                            // overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      value: sortBy[index],
                                    );
                                  },
                                ),
                                onChanged: (val) {
                                  // setState(() {});
                                  currentGenre = val;
                                  isExpanded = false;
                                  fetchGenres();
                                  // genreList[index] = genre;
                                  // if (index >= genreList.length - 1) {
                                  //   genreList.add(null);
                                  //   numOfGenres++;
                                  // }
                                  // setState(() {});
                                  setState(() {});
                                },
                                value: currentGenre,
                              ),
                              IconButton(
                                icon: Icon(isAscending
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down),
                                onPressed: () {
                                  isAscending = !isAscending;
                                  setState(() {});
                                  direction = isAscending ? '.asc' : '.desc';
                                  fetchGenres();
                                },
                              ),
                            ],
                          ),
                  ),
                  floatingActionButtonAnimator:
                      FloatingActionButtonAnimator.scaling,
                  body: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Container(
                          // height: MediaQuery.of(context).size.height / 2.1,
                          child: ListView(
                            addRepaintBoundaries: true,
                            shrinkWrap: true,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                height: 40,
                                child: ListView(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    children:
                                        List.generate(genres.length, (index) {
                                      Color color;
                                      genres[index].values.first == true
                                          ? color = Colors.blueGrey
                                          : color = Colors.amber;
                                      return InkWell(
                                        onTap: _isProcessing
                                            ? null
                                            : () {
                                                genres[index].update(
                                                    genres[index].keys.first,
                                                    (s) => !genres[index]
                                                        .values
                                                        .first);
                                                setState(() {});
                                                if (genres[index]
                                                    .values
                                                    .first) {
                                                  _isProcessing = true;
                                                  model
                                                      .fetchDiscover(
                                                          'https://api.themoviedb.org/3/discover/movie?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&sort_by=$currentGenre$direction&include_adult=false&include_video=false&page=1&with_genres=${model.genres[genres[index].keys.first]}')
                                                      .then((fetchedMovie) {
                                                    genreMovieList.insert(
                                                      0,
                                                      MoviesCard(
                                                        fetchedMovie,
                                                        'genreCard',
                                                        'genreTitle',
                                                        index: index,
                                                        genre: genres[index]
                                                            .keys
                                                            .first,
                                                      ),
                                                    );
                                                    _isProcessing = false;
                                                    setState(() {});
                                                  });
                                                } else
                                                  genreMovieList.removeWhere(
                                                      (s) =>
                                                          (s as MoviesCard)
                                                              .genre ==
                                                          genres[index]
                                                              .keys
                                                              .first);
                                                // _isProcessing=false;
                                                setState(() {});
                                              },
                                        child: Container(
                                          // height: 90,
                                          padding: EdgeInsets.all(5),
                                          margin: EdgeInsets.all(5),
                                          alignment: Alignment.center,
                                          child: Text(genres[index].keys.first),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: color,
                                          ),
                                        ),
                                      );
                                    })),
                              )
                              // MoviesCard(genre:'Comedy'),
                            ]
                              ..add(Center(
                                  child: _isProcessing
                                      ? CircularProgressIndicator()
                                      : Container()))
                              ..addAll(genreMovieList),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:infinite_listview/infinite_listview.dart';
import 'package:scoped_model/scoped_model.dart';
// import 'package:session3/main.dart';
import 'package:session3/search_btn.dart';
import 'package:session3/discover_tab.dart';
import 'package:session3/movie_card.dart';
import 'package:session3/movie_details.dart';
import 'package:session3/movie_mode.dart';
import 'package:session3/person_details.dart';
import 'package:session3/scoped_mode.dart';
import 'movies_card.dart';
import 'package:http/http.dart';

class DiscoverAppBar extends StatefulWidget {
  @override
  _DiscoverAppBarState createState() => _DiscoverAppBarState();
}

class _DiscoverAppBarState extends State<DiscoverAppBar>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController _controller;
  ScrollController _scrollController;
  TabController _tabController;
  TabController _tabController2;
  // MainModel model;
  BuildContext contxt;
  double top;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    _tabController2.dispose();
    _searchNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    //  gridList = GridList();
    // model = ScopedModel.of(context);
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 200), value: 1);

    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    _tabController2 = TabController(vsync: this, length: 0, initialIndex: 0);
    _tabController.addListener(callback);
    _scrollController = ScrollController();
  }

  List<Movie> suggestedMovies = [];
  MainModel model = MainModel();
  Future<List<Movie>> getSuggestion(String p) {
    List<Movie> moviesContainP = [];
    if (p.isEmpty) return Future.sync(() => []);
    if (suggestedMovies.isNotEmpty) {
      // print(suggestedMovies);
      moviesContainP = suggestedMovies
          .where((movie) => movie.title.toLowerCase().contains(p.toLowerCase()))
          .toList();
    }
    if (moviesContainP.isNotEmpty) {
      return Future.sync(
        () => moviesContainP,
      );
    }
    return get(
            'https://api.themoviedb.org/3/search/multi?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&query=$p&page=1&include_adult=false')
        .then((response) {
      suggestedMovies = [];
      List<Movie> movies = [];
      final decoded = json.decode(response.body);
      decoded['results'].forEach((movie) {
        // final movie = decoded['results'][index];
        if (movie['media_type'] == 'movie')
          movies.add(Movie(
            mediaType: movie['media_type'],
            desc: movie['overview'],
            genres: List.generate(movie['genre_ids'].length, (index) {
              return model.genres.keys.firstWhere((s) {
                return model.genres[s] == movie['genre_ids'][index];
              }, orElse: () {
                return;
              });
            }),
            img: movie['poster_path'] == null
                ? 'http://icons.iconarchive.com/icons/dtafalonso/android-lollipop/512/Movie-Studio-icon.png'
                : 'https://image.tmdb.org/t/p/w185/${movie['poster_path']}',
            imgBG: 'https://image.tmdb.org/t/p/w500/${movie['backdrop_path']}',
            rating: movie['vote_average'].toString(),
            id: movie['id'].toString(),
            title: movie['title'],
          ));
        else if (movie['media_type'] == 'tv')
          movies.add(Movie(
            mediaType: 'tv',
            desc: movie['overview'],
            genres: List.generate(movie['genre_ids'].length, (index) {
              return model.genres.keys.firstWhere((s) {
                return model.genres[s] == movie['genre_ids'][index];
              }, orElse: () {
                return;
              });
            }),
            img: movie['poster_path'] == null
                ? 'http://icons.iconarchive.com/icons/dtafalonso/android-lollipop/512/Movie-Studio-icon.png'
                : 'https://image.tmdb.org/t/p/w185/${movie['poster_path']}',
            imgBG: 'https://image.tmdb.org/t/p/w500/${movie['backdrop_path']}',
            rating: movie['vote_average'].toString(),
            id: movie['id'].toString(),
            title: movie['original_name'],
          ));
        else if (movie['media_type'] == 'person')
          movies.add(Movie.person(
              mediaType: 'person',
              id: movie['id'].toString(),
              title: movie['name'],
              gender: movie['gender'] == 1 ? 'Female' : 'Male',
              department: movie['known_for_department'],
              img: movie['profile_path'] == null
                  ? movie['gender'] == 1
                      ? 'https://cdn2.iconfinder.com/data/icons/person-gender-hairstyle-clothes-variations/48/Female-Side-comb-O-neck-512.png'
                      : 'http://www.tactic90.com/images/Members/Avatar_tac_2016_2.png'
                  : 'https://image.tmdb.org/t/p/w185/${movie['profile_path']}',
              knownFor: List.generate(movie['known_for'].length, (index) {
                Map knownFor = movie['known_for'][index];
                return Movie(
                  id: knownFor['id'].toString(),
                  img:
                      'https://image.tmdb.org/t/p/w185/${knownFor['poster_path']}',
                  imgBG:
                      'https://image.tmdb.org/t/p/w500/${knownFor['backdrop_path']}',
                  desc: knownFor['overview'],
                  rating: knownFor['vote_average'].toString(),
                  title: knownFor['title'],
                  genres: List.generate(knownFor['genre_ids'].length, (index) {
                    return model.genres.keys.firstWhere((s) {
                      return model.genres[s] == knownFor['genre_ids'][index];
                    }, orElse: () {
                      return;
                    });
                  }),
                );
              })));
      });
      suggestedMovies = movies;
      return movies;
    }, onError: (e) {});
  }

  callback() {
    if (_tabController.index == 0)
      setState(() {
        height = MediaQuery.of(contxt).size.height / 3;
      });
    else
      setState(() {
        height = MediaQuery.of(contxt).size.height / 1.9;
      });
  }

  TextEditingController search = TextEditingController();
  FocusNode _searchNode = FocusNode();
  Widget searchBar() {
    return Center(
      child: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints.expand(height: 55),
        margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blueGrey[300],
            boxShadow: [BoxShadow(color: Colors.white, blurRadius: 2)]),
        child: ListTile(
          leading: Container(
            child: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
          title: ScopedModelDescendant<MainModel>(
            builder: (context, child, model) {
              return TypeAheadField(
                onSuggestionSelected: (Movie s) {
                  if (s.mediaType == 'person')
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PersonDetails(s, 'c', 't')));
                  else
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MovieDetails(
                              movie: s,
                            ),
                        settings: RouteSettings(arguments: [s, 'c', 't'])));
                },
                suggestionsCallback: (p) async {
                  // model.query = '${model.searchUrl}$p';

                  final movies = getSuggestion(p);

                  return await movies;
                },
                hideOnError: true,
                getImmediateSuggestions: true,
                keepSuggestionsOnLoading: true,
                itemBuilder: (context, suggestion) {
                  // Movie movie = suggestion;
                  return ListTile(
                    leading: SizedBox.fromSize(
                        size: Size.square(50),
                        child: Hero(
                            tag: 'c', child: Image.network(suggestion.img))),
                    title: Container(
                        child: Text(
                      suggestion.title,
                      style: TextStyle(color: Colors.white),
                    )),
                    subtitle: Text(
                      suggestion.mediaType,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  );
                },
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                debounceDuration: Duration.zero,
                textFieldConfiguration: TextFieldConfiguration(
                  controller: search,
                  focusNode: _searchNode,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  onStartScroll(ScrollMetrics metrics) {
    // _scrollController.position.saveScrollOffset();
    print(top);
    // if (_end - _start > 80) {
    if (top <= 81) {
      _isExpanded = false;
      res.isEmpty ? height = 50 : height = 100;
      setState(() {});
    }
  }

  GlobalKey nested = GlobalKey();
  double _start = 0;
  double _end = 0;
  callback2() {
    _isExpanded = false;
    res.isEmpty ? height = 50 : height = 100;
    setState(() {});
    print('object');
  }

  bool _isExpanded = false;
  double height = 50;
  Widget sliver(BuildContext context, var gridLista) {
    contxt = context;
    //
    return NotificationListener<ScrollNotification>(
      onNotification: (s) {
        if (s is ScrollEndNotification) {
          _start = s.metrics.pixels;
          onStartScroll(s.metrics);
        }
      },
      child: NestedScrollView(
        dragStartBehavior: DragStartBehavior.start,
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        // physics: AlwaysScrollableScrollPhysics(),
        headerSliverBuilder: (context, i) {
          return [
            SliverAppBar(
                centerTitle: true,
                title: Text('MoviePedia'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  // side: BorderSide(color: Colors.white,)
                ),
                actions: <Widget>[
                  Container(
                    // duration: Duration(seconds: 1),
                    // height:5,
                    width: 80,
                    child: IconButton(
                      onPressed: () {
                        if (_controller.isDismissed) {
                          _controller.forward();
                        } else {
                          _controller.reverse();
                        }
                        _isExpanded = !_isExpanded;
                        !_isExpanded
                            ? height = 50
                            : _tabController.index == 0
                                ? height = MediaQuery.of(contxt).size.height / 3
                                : height =
                                    MediaQuery.of(contxt).size.height / 1.9;
                        Future.delayed(
                            Duration(
                              microseconds: 1,
                            ),
                            () => setState(() {}));
                      },
                      icon: AnimatedBuilder(
                        animation: _controller,
                        builder: (BuildContext context, Widget child) {
                          return Transform(
                            transformHitTests: false,
                            alignment: FractionalOffset.center,
                            transform: Matrix4.rotationZ(
                                _controller.value * 2 * (22 / 7)),
                            child: Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.search,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                expandedHeight: height,
                forceElevated: i,
                floating: true,
                snap: true,
                pinned: true,
                bottom: !_isExpanded && res.isEmpty
                    ? null
                    : PreferredSize(
                        preferredSize: Size.fromHeight(50),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          decoration: BoxDecoration(
                              color: Theme.of(context).appBarTheme.color,
                              borderRadius: BorderRadius.circular(10)),
                          // height: MediaQuery.of(context).size.height / 18,
                          // color: Theme.of(context).appBarTheme.color,
                          child: !_isExpanded
                              ? TabBar(
                                  onTap: (s) {
                                    // initIndex=s;
                                  },
                                  controller: _tabController2,
                                  tabs: List.generate(types.length, (index) {
                                    return Tab(
                                      text: types[index],
                                    );
                                  }),
                                )
                              : TabBar(
                                  isScrollable: false,
                                  onTap: (s) {
                                    _isExpanded = true;
                                  },
                                  // onTap: (s) {
                                  //   s == 0
                                  //       ? setState(() {
                                  //           height = MediaQuery.of(context).size.height / 4.5;
                                  //         })
                                  //       : setState(() =>
                                  //           height = MediaQuery.of(context).size.height / 2.1);
                                  // },
                                  controller: _tabController,
                                  tabs: <Widget>[
                                    Tab(
                                      icon: Icon(Icons.devices_other),
                                    ),
                                    Tab(
                                      icon: Icon(Icons.search),
                                    )
                                  ],
                                ),
                        ),
                      ),
                backgroundColor:
                    Theme.of(context).appBarTheme.color, //Color(0xff59b2b5),
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    top = constraints.biggest.height;
                    return FlexibleSpaceBar(
                        centerTitle: true,
                        background: _isExpanded
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: height -
                                        MediaQuery.of(context).size.height / 10,
                                    child: TabBarView(
                                      // dragStartBehavior: DragStartBehavior.down,
                                      controller: _tabController,
                                      children: <Widget>[
                                        ListView(
                                          addAutomaticKeepAlives: true,
                                          children: <Widget>[
                                            searchBar(),
                                            Center(
                                                child: SearchBtn(
                                              callback: callback2,
                                              search: search,
                                              cast: [],
                                            )),
                                          ],
                                        ),
                                        gridLista,
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Container());
                  },
                ))
          ];
        },

        body: SafeArea(
          child: ScopedModelDescendant<MainModel>(
            builder: (context, child, model) {
              return res.length < 1 && model.isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : res.length < 1
                      ? _cuteCat()
                      : TabBarView(

                          // physics: NeverScrollableScrollPhysics(),
                          controller: _tabController2,
                          children: res);
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _result(MainModel model) {
    return [
      model.movies.isEmpty
          ? Container()
          : CustomScrollView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              slivers: [
                  SliverToBoxAdapter(
                    child: _buildResult(model.movies),
                  ),
                  SliverToBoxAdapter(
                      child: pageRow(
                    model.pages,
                    model.currentPage,
                    model.setMoviePage,
                    model.fetch,
                    model.isLoading,
                  )),
                ]),
      model.tv.isEmpty
          ? Container()
          : ListView(
              addAutomaticKeepAlives: true,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                  Container(),
                  _buildResult(model.tv),
                  pageRow(
                    model.tvPages,
                    model.currentTvPage,
                    model.setTvPage,
                    model.fetchTv,
                    model.isLoading,
                  ),
                ]),
      model.persons.isEmpty
          ? Container()
          : ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                  Container(),
                  _buildResult(model.persons),
                  pageRow(
                    model.peoplePages,
                    model.currentPeoplePage,
                    model.setPersonPage,
                    model.fetchPeople,
                    model.isLoading,
                  ),
                ])
    ];
  }

  Widget _cuteCat() {
    return Center(
      child: ListView(
        children: <Widget>[
          Image.asset('assets/cat.png'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.warning,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                'Found Nothing!',
                style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      BoxShadow(color: Color(0xff59b2b5), blurRadius: 4)
                    ]),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildResult(List<Movie> movies) {
    return GridView.count(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      childAspectRatio: 0.62,
      crossAxisCount: 2,
      children: List.generate(
        movies.length,
        (index) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                    opaque: false,
                    maintainState: true,
                    pageBuilder: (context, animation, secAnim) =>
                        movies[index].mediaType == 'person'
                            ? PersonDetails(
                                movies[index], 'cardA$index', 'titleA$index')
                            : MovieDetails(
                                movie: movies[index],
                              ),
                    transitionDuration: Duration(milliseconds: 500),
                    settings: RouteSettings(arguments: [
                      movies[index],
                      'cardA$index',
                      'titleA$index'
                    ])),
              );
            },
            child: MovieCard(
              cardTag: 'cardA$index',
              titleTag: 'titleA$index',
              img: movies[index].img,
              title: movies[index].title,
            ),
          );
        },
      ),
      // addAutomaticKeepAlives: true,
    );
  }

  Widget pageRow(int pages, int currentPage, Function setPage, Function fetch,
      bool isLoading) {
    return Container(
      // height: 50,
      // color: Colors.white,

      child: pages > 1
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  color: Colors.white,
                  disabledColor: Colors.white30,
                  padding: EdgeInsets.all(15),
                  onPressed: currentPage != 1
                      ? () {
                          setPage(currentPage - 1);

                          fetch().whenComplete(() {
                            // _scrollController.jumpTo(0);
                            _scrollController.animateTo(0,
                                duration: Duration(milliseconds: 1000),
                                curve: Curves.easeOutCirc);
                          });
                        }
                      : null,
                  icon: Icon(
                    Icons.arrow_left,
                  ),
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          TextEditingController controller =
                              TextEditingController(text: '');
                          return AlertDialog(
                            backgroundColor: Colors.blueGrey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            content: Container(
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              height: 70,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    ' 1 <==> $pages      ',
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Container(
                                        width: 50,
                                        child: TextField(
                                          controller: controller,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            WhitelistingTextInputFormatter
                                                .digitsOnly
                                          ],
                                          style: TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      0, 2.5, 0, 0),
                                              hintStyle: TextStyle(
                                                  color: Colors.white70),
                                              hintText: currentPage.toString()),
                                        ),
                                      ),
                                      Center(
                                        child: FlatButton(
                                          child: Text(
                                            'Go',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          onPressed: int.tryParse(
                                                          controller.text) !=
                                                      1 ||
                                                  int.tryParse(
                                                          controller.text) <=
                                                      pages
                                              ? () {
                                                  setPage(int.parse(controller
                                                      .value.text
                                                      .trim()));
                                                  fetch().whenComplete(() {
                                                    // _scrollController.jumpTo(0);
                                                    _scrollController.animateTo(
                                                        0,
                                                        duration: Duration(
                                                            milliseconds: 1000),
                                                        curve:
                                                            Curves.easeOutCirc);
                                                  });
                                                  Navigator.pop(context);
                                                }
                                              : null,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  child: Container(
                    // color: Colors.indigo,
                    margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Text(
                            currentPage.toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
                IconButton(
                  color: Colors.white,
                  disabledColor: Colors.white30,
                  padding: EdgeInsets.all(15),
                  onPressed: currentPage != pages
                      ? () {
                          setPage(currentPage + 1);

                          fetch().whenComplete(() {
                            // _scrollController.jumpTo(0);
                            _scrollController.animateTo(0,
                                duration: Duration(milliseconds: 1000),
                                curve: Curves.easeOutCirc);
                          });
                        }
                      : null,
                  icon: Icon(
                    Icons.arrow_right,
                  ),
                )
              ],
            )
          : null,
    );
  }

  List<Widget> res = [];
  List<String> types = [];
  int initIndex = 0;

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    final gridList = DiscoverTab(
      callback: callback2,
    );
    int length;
    res.isEmpty ? length = 0 : length = res.length;
    super.build(context);
    return ScopedModelDescendant<MainModel>(
      child: sliver(context, gridList),
      builder: (context, child, model) {
        res = _result(model).toList();
        types = ['Movie', 'TV-Shows', 'People'];
        if (model.persons.isEmpty) {
          res.removeAt(2);
          types.removeAt(2);
          // _tabController2 =
          //   TabController(vsync: this, length: res.length, initialIndex: initIndex);
        }
        if (model.tv.isEmpty) {
          res.removeAt(1);
          types.removeAt(1);
          // _tabController2 =
          //   TabController(vsync: this, length: res.length, initialIndex: initIndex);
        }
        if (model.movies.isEmpty) {
          res.removeAt(0);
          types.removeAt(0);
          // _tabController2 =
          //   TabController(vsync: this, length: res.length, initialIndex: initIndex);
        }
        if (length != res.length)
          _tabController2 = TabController(
              vsync: this, length: res.length, initialIndex: initIndex);
        print('${res.length}jh');
        return child;
      },
    );
  }
}

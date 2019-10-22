import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:session3/movie_card.dart';
import 'package:session3/movie_mode.dart';
import 'package:session3/scoped_mode.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:xlive_switch/xlive_switch.dart';

class UserList extends StatefulWidget {
  final List<Movie> movieList;
  final String title;
  final IconData icon;
  UserList(this.movieList, this.title, this.icon);

  @override
  _UserListState createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  bool _isEdit = false;
  bool _isLoading = false;
  String type;
  String mediaType;
  double _headerHeight = 1;
  List<Movie> editableList;
  List<Movie> delMovies = [];
  List<Movie> addedMovies = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    editableList = List.from(widget.movieList);
    mediaType = widget.title.toLowerCase().contains('tv') ? 'tv' : 'movie';
    type = widget.title.toLowerCase().contains('watchlist')
        ? 'watchlist'
        : 'favorite';
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return Scaffold(
          appBar: AppBar(
            title: Hero(
              tag: '${widget.title} title',
              child: Text(widget.title),
            ),
            leading:
                Hero(tag: '${widget.title} icon', child: Icon(widget.icon)),
            actions: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white),
                ),
                // height: 200,
                width: 55,
                margin: EdgeInsets.fromLTRB(0, 11, 14, 11),
                child: Align(
                  child: XlivSwitch(
                    activeColor: Color.fromRGBO(80, 88, 108, 1),
                    value: _isEdit,
                    onChanged: (b) {
                      _isEdit = b;
                      _headerHeight = b ? 65 : 0;
                      setState(() {});
                    },
                  ),
                ),
              )
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => model
                .getFavOrWatch(type, mediaType)
                .then((s) => editableList = List.from(s)),
            child: CustomScrollView(
              slivers: <Widget>[
                _isEdit &&
                        !listEquals(
                            model.listMovie[type][mediaType], editableList)
                    ? SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverHeader(
                            child: PreferredSize(
                          preferredSize: Size(35, _headerHeight),
                          child: Align(
                            child: Container(
                              width: 360,
                              height: 65,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .scaffoldBackgroundColor
                                    .withAlpha(200),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Text(
                                    'Confirm changes?',
                                    style: TextStyle(),
                                  ),
                                  _isLoading
                                      ? Container(
                                          width: 180,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        )
                                      : Row(
                                          children: <Widget>[
                                            RaisedButton(
                                              onPressed: () =>
                                                  confirmChanges(model)
                                                      .then((_) {
                                                addedMovies = [];
                                                delMovies = [];
                                                editableList = List.from(
                                                    model.listMovie[type]
                                                        [mediaType]);
                                                _isLoading = false;
                                                setState(() {});
                                              }),
                                              color: Colors.lightBlueAccent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Text('Confirm'),
                                            ),
                                            VerticalDivider(
                                              width: 5,
                                            ),
                                            RaisedButton(
                                              onPressed: () {
                                                editableList = List.from(
                                                    model.listMovie[type]
                                                        [mediaType]);
                                                delMovies = [];
                                                addedMovies = [];
                                                setState(() {});
                                              },
                                              color: Colors.lightBlueAccent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Text('Discard'),
                                            ),
                                          ],
                                        )
                                ],
                              ),
                            ),
                          ),
                        )),
                      )
                    : SliverToBoxAdapter(child: Container()),
                SliverGrid.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.623,
                  // shrinkWrap: true,
                  children: List.generate(editableList.length, (index) {
                    return Stack(
                      children: <Widget>[
                        MovieCard(
                          img: editableList[index].img,
                          title: '${editableList[index].title}',
                          cardTag: '${widget.title}Card$index',
                          titleTag: '${widget.title}Title$index',
                        ),
                        _isEdit
                            ? Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  // margin: EdgeInsets.fromLTRB(0,0,0,20),
                                  width: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red
                                  ),
                                  child: IconButton(
                                    iconSize: 15,
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      delMovies.add(editableList[index]);
                                      editableList.removeAt(index);
                                      setState(() {});
                                      // model.toggleFav(
                                      //     int.parse(delMovie.id),
                                      //     delMovie.mediaType,
                                      //     false,
                                      //     widget.title.contains('list')
                                      //         ? 'watchlist'
                                      //         : 'favorite');
                                      // setState(() {});
                                    },
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    );
                  })
                    ..add(Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: _isEdit || model.listMovie[type][mediaType].isEmpty
                          ? DottedBorder(
                              dashPattern: [10, 2],
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: Colors.white30,
                                          width: 2,
                                        )),
                                    child: TypeAheadField(
                                      hideOnEmpty: true,
                                      keepSuggestionsOnLoading: true,
                                      hideSuggestionsOnKeyboardHide: false,
                                      onSuggestionSelected: (s) {
                                        editableList.add(s);
                                        addedMovies.add(s);
                                        setState(() {});
                                      },
                                      suggestionsCallback: (p) async {
                                        return await getSuggestion(p);
                                      },
                                      itemBuilder: (context, s) {
                                        return ListTile(
                                          leading: SizedBox.fromSize(
                                            size: Size.square(50),
                                            child: Image.network(s.img),
                                          ),
                                          title: Container(
                                              width: 200, child: Text(s.title)),
                                        );
                                      },
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.add,
                                        size: 55,
                                        color: Colors.white30,
                                      ),
                                      Center(
                                          child: Text(
                                        'Add',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white10),
                                      ))
                                    ],
                                  ),
                                ],
                              ),
                              strokeWidth: 4,
                              borderType: BorderType.RRect,
                              radius: Radius.circular(10),
                              color: Colors.white30,
                            )
                          : Container(),
                    )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // animateUp() {
  //   for (_headerHeight = 1; _headerHeight < 65;) {
  //     Future.delayed(Duration(seconds: 1), () {
  //       _headerHeight++;
  //       setState(() {});
  //     });
  //   }
  // }

  // animateDown() {
  //   // for (_headerHeight = 65; _headerHeight > 1;) {
  //   //   Future.delayed(Duration(milliseconds: 10), () {
  //   //     _headerHeight--;
  //   //     setState(() {});
  //   //   });
  //   // }
  // }

  Future confirmChanges(MainModel model) {
    _isLoading = true;
    setState(() {});
    List<Future> futures = [];
    delMovies.forEach((m) => futures
        .add(model.toggleFav(int.parse(m.id), m.mediaType, false, type)));
    addedMovies.forEach((m) =>
        futures.add(model.toggleFav(int.parse(m.id), m.mediaType, true, type)));
    return Future.wait(futures)
        .then((_) => model.getFavOrWatch(type, mediaType));
  }

  List<Movie> suggested = [];
  Future getSuggestion(String p) {
    if (p.isEmpty) return Future.sync(() => []);
    if (suggested.isNotEmpty) {
      List<Movie> movies = [];
      movies = suggested
          .where(
              (Movie mov) => mov.title.toLowerCase().contains(p.toLowerCase()))
          .toList();
      if (movies.isNotEmpty) return Future.sync(() => movies);
    }

    final model = MainModel();
    final String mediaType = widget.movieList[0].mediaType;
    return get(
            'https://api.themoviedb.org/3/search/${widget.movieList[0].mediaType}?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&query=$p&page=1&include_adult=false')
        .then((res) {
      suggested = [];
      if (res.statusCode != 200) return null;
      final decoded = json.decode(res.body);
      final List<Movie> movies = [];
      (decoded['results'] as List).forEach((movie) {
        movies.add(Movie(
          desc: movie['overview'],
          id: movie['id'].toString(),
          imgBG: 'https://image.tmdb.org/t/p/w500/${movie['backdrop_path']}',
          img: movie['poster_path'] == null
              ? 'http://icons.iconarchive.com/icons/dtafalonso/android-lollipop/512/Movie-Studio-icon.png'
              : 'https://image.tmdb.org/t/p/w185/${movie['poster_path']}',
          mediaType: mediaType,
          title: movie['name'] ?? movie['original_name'] ?? movie['title'],
          rating: movie['vote_average'].toString(),
          genres: List.generate(movie['genre_ids'].length, (index) {
            return model.genres.keys.firstWhere((s) {
              return model.genres[s] == movie['genre_ids'][index];
            }, orElse: () {
              return;
            });
          }),
        ));
      });
      suggested = movies;
      return movies;
    });
  }
}

class _SliverHeader extends SliverPersistentHeaderDelegate {
  final PreferredSize child;
  _SliverHeader({this.child});
  @override
  double get minExtent => child.preferredSize.height;
  @override
  double get maxExtent => child.preferredSize.height;
  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }
}

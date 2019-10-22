import 'package:flutter/material.dart';
import 'package:session3/movie_details.dart';
import 'package:session3/movie_mode.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:session3/scoped_mode.dart';

class MoviesCard extends StatefulWidget {
  final int index;
  String cardTag;
  String titleTag;
  String genre;
  List<Movie> movies;
  MoviesCard(this.movies, this.cardTag, this.titleTag,
      {this.genre, this.index});
  @override
  _MoviesCardState createState() => _MoviesCardState();
}

class _MoviesCardState extends State<MoviesCard>
    with AutomaticKeepAliveClientMixin {
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

  @override
  bool get wantKeepAlive => true;
  int _movIndex = 0;
  // bool _isLoading = false;
  void callback(int index) {
    _movIndex = index;
    setState(() {});
    print(_movIndex);
    print(widget.genre);
  }

  @override
  void initState() {
    // MainModel model = ScopedModel.of(context);

    // if(model.movies != null) {_movies = model.movies;return;}
    // _isLoading = true;
    // model.popularType = widget.genre;
    // Future.delayed(Duration(milliseconds: 100));
    // model.fetch('${model.popularUrl}').then((fetchedMovies) {
    //   _movies = fetchedMovies;
    // if (!mounted) return;
    // setState(() {
    //   _isLoading = false;
    // });
    // });
    super.initState();
  }

  @override
  void dispose() {
    // dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return Center(
          child: widget.movies == null
              ? Center(
                  child: Row(
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
                      'Server is busy!',
                      style: TextStyle(
                          fontSize: 32,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            BoxShadow(color: Colors.white, blurRadius: 4)
                          ]),
                    ),
                  ],
                ))
              : Builder(
                  builder: (context) {
                    return Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(72, 80, 100, 1),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                // spreadRadius: 10,
                                blurRadius: 10,
                                // offset: Offset.fromDirection(1, 10),
                                color: Colors.black38,
                              )
                            ],
                          ),
                          height: MediaQuery.of(context).size.height / 2.5,
                          // color: Colors.white,
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(20, 15, 0, 0),
                                child: Text(
                                    widget.genre
                                        .replaceAll('_', ' ')
                                        .replaceFirst(widget.genre[0],
                                            widget.genre[0].toUpperCase()),
                                    style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70)),
                              ),
                              Stack(
                                alignment: AlignmentGeometry.lerp(
                                    Alignment.center,
                                    Alignment.bottomCenter,
                                    1),
                                fit: StackFit.passthrough,
                                children: <Widget>[
                                  Container(
                                    // width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height /
                                        3.1,
                                    // aspectRatio: 2 / 1.5,

                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              PageRouteBuilder(
                                                maintainState: true,
                                                pageBuilder: (context,
                                                        animation,
                                                        secAnimation) =>
                                                    MovieDetails(
                                                  movie:
                                                      widget.movies[_movIndex],
                                                ),
                                                transitionDuration:
                                                    Duration(milliseconds: 500),
                                                settings: RouteSettings(
                                                  arguments: [
                                                    widget.movies[_movIndex],
                                                    '${widget.cardTag}${widget.index}${model.stackedIndex}',
                                                    '${widget.titleTag}${widget.index}${model.stackedIndex}'
                                                  ],
                                                ),
                                              ),
                                            );
                                            model.stackedIndex++;
                                          },
                                          child: AspectRatio(
                                            aspectRatio: MediaQuery.of(context)
                                                    .size
                                                    .aspectRatio /
                                                0.71,
                                            child: Hero(
                                              tag:
                                                  '${widget.cardTag}${widget.index}${model.stackedIndex}',
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(15),
                                                    topLeft:
                                                        Radius.circular(15)),
                                                child: !widget
                                                        .movies[_movIndex].img
                                                        .contains('null')
                                                    ? Image.network(
                                                        widget.movies[_movIndex]
                                                            .img,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.asset(
                                                        'assets/cat.png'),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                                padding: EdgeInsets.all(10),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    4.5,
                                                child: Hero(
                                                  tag:
                                                      '${widget.titleTag}${widget.index}${model.stackedIndex}',
                                                  child: Text(
                                                    widget.movies[_movIndex]
                                                        .title,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      decoration:
                                                          TextDecoration.none,
                                                      fontFamily: 'Arial',
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xff59b2b5),
                                                    ),
                                                  ),
                                                )),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  4.5,
                                              padding: EdgeInsets.all(10),
                                              child: Text(
                                                widget.movies[_movIndex].desc,
                                                maxLines: 5,
                                                overflow: TextOverflow.ellipsis,
                                                // textWidthBasis: TextWidthBasis.parent,
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    // margin: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(72, 80, 100, 1),
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          // spreadRadius: 10,
                                          blurRadius: 10,
                                          // offset: Offset.fromDirection(1, 10),
                                          color: Colors.black38,
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    // margin: EdgeInsets.all(20),
                                    // height: height,
                                    child: Box(callback, widget.movies),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.movies.length,
                            (index) {
                              int color = _movIndex == index
                                  ? Theme.of(context).appBarTheme.color.value
                                  : Color.fromRGBO(0, 0, 0, 0.4).value;
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(color)),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }
}

class Box extends StatefulWidget {
  final Function callback;
  final List<Movie> _movies;
  Box(this.callback, this._movies);
  @override
  _BoxState createState() => _BoxState();
}

class _BoxState extends State<Box> {
  int sel = 0;
  int color;

  List<Widget> child;
  Widget carousel() {
    print(MediaQuery.of(context).size.aspectRatio);

    return CarouselSlider(
      initialPage: 0,
      items: child,
      enableInfiniteScroll: true,
      autoPlay: false,

      autoPlayAnimationDuration: Duration(milliseconds: 1000),
      autoPlayInterval: Duration(seconds: 5),
      pauseAutoPlayOnTouch: Duration(seconds: 3),
      onPageChanged: (s) {
        sel = s;
        // _movIndex = s;
        widget.callback(s);
        setState(() {});
      },
      height: MediaQuery.of(context).size.height / 8.22,
      autoPlayCurve: Curves.elasticInOut,
      enlargeCenterPage: true,
      viewportFraction: 0.2,
      // aspectRatio: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    child = List.generate(
      widget._movies.length,
      (index) {
        color = sel == index
            ? Theme.of(context).appBarTheme.color.value
            : Color.fromRGBO(0, 0, 0, 0.4).value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(200, 0, 0, 0),
                Color.fromARGB(0, 0, 0, 0)
              ],
            ),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: Color(color),
            ),
          ),
          margin: EdgeInsets.all(5.0),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Stack(
              children: <Widget>[
                Image.network(widget._movies[index].img,
                    fit: BoxFit.cover, width: 1000.0),
              ],
            ),
          ),
        );
      },
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Color.fromARGB(200, 0, 0, 0), Color.fromARGB(0, 0, 0, 0)],
        ),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width / 1.1 - 3,
        child: carousel(),
      ),
    );
  }
}

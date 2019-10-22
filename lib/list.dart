import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:session3/lst_model.dart';
import 'package:session3/movie_card.dart';
import 'package:session3/movie_details.dart';
import 'package:session3/movie_mode.dart';
import 'package:session3/scoped_mode.dart';

class MovieLists extends StatefulWidget {
  final ListModel selectedList;
  MovieLists(this.selectedList);
  @override
  _MovieListsState createState() => _MovieListsState();
}

class _MovieListsState extends State<MovieLists> {
  List<Movie> movieList = [];
  List<Movie> chunk = [];
  Future fetchList(int id) async {
    return get(
            'https://api.themoviedb.org/3/list/$id?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US')
        .then((res) {
      print('LIST GENERATED');
      Map decoded = json.decode(res.body);
      movieList = List.generate(decoded['items'].length, (index) {
        final movie = decoded['items'][index];
        return Movie(
          img: 'https://image.tmdb.org/t/p/w185/${movie['poster_path']}',
          desc: movie['overview'],
          genres: List.generate(movie['genre_ids'].length, (index) {
            return model.genres.keys.firstWhere((s) {
              return model.genres[s] == movie['genre_ids'][index];
            }, orElse: () {
              return;
            });
          }),
          id: movie['id'].toString(),
          imgBG: 'https://image.tmdb.org/t/p/w300/${movie['backdrop_path']}',
          rating: movie['vote_average'].toString(),
          title: movie['title'],
        );
      });
    }, onError: (e) {});
  }

  MainModel model;
  bool isLoading = false;
  ScrollController _scrollController;
  @override
  void initState() {
    _scrollController = ScrollController();
    model = ScopedModel.of(context);
    isLoading = true;
    fetchList(widget.selectedList.id).then((_) {
      print(widget.selectedList.id);
      isLoading = false;
      setState(() {});
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies

    super.didChangeDependencies();
  }

  int start = 0;
  int end = 20;
  Widget _buildNavigate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          color: Colors.white,
          disabledColor: Colors.white30,
          padding: EdgeInsets.all(15),
          onPressed: start != 0
              ? () {
                  start -= 20;
                  setState(() {});
                  _scrollController.animateTo(0,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOutCirc);
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
                      borderRadius: BorderRadius.all(Radius.circular(10)),
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
                            ' 1 <==> ${(movieList.length / 20).ceil()}      ',
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
                                  style: TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.fromLTRB(0, 2.5, 0, 0),
                                      hintStyle:
                                          TextStyle(color: Colors.white70),
                                      hintText: model.currentPage.toString()),
                                ),
                              ),
                              Center(
                                child: FlatButton(
                                  child: Text(
                                    'Go',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: int.tryParse(controller.text) !=
                                              1 ||
                                          int.tryParse(controller.text) <=
                                              model.pages
                                      ? () {
                                          start = int.parse(controller
                                                      .value.text
                                                      .trim()) *
                                                  20 -
                                              20;
                                          setState(() {
                                            _scrollController.animateTo(0,
                                                duration:
                                                    Duration(milliseconds: 500),
                                                curve: Curves.easeOutCirc);
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
            child: Text(
              (start / 20 + 1).ceil().toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        IconButton(
          color: Colors.white,
          disabledColor: Colors.white30,
          padding: EdgeInsets.all(15),
          onPressed: start + 20 < (movieList.length).ceil()
              ? () {
                  start += 20;
                  setState(() {});
                  _scrollController.animateTo(0,
                      duration: Duration(
                        milliseconds: 500,
                      ),
                      curve: Curves.easeOutCubic);
                }
              : null,
          icon: Icon(
            Icons.arrow_right,
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    (movieList.length < 20) ? end = movieList.length : end = 20;
    if (start + 20 > movieList.length) end = movieList.length - start;
    // end=20;
    return Scaffold(
      body: ListView(
        controller: _scrollController,
        // primary: true,
        children: isLoading
            ? [
                Center(
                  child: CircularProgressIndicator(),
                )
              ]
            : <Widget>[
                GridView.count(
                  physics: NeverScrollableScrollPhysics(),
                  // controller: _scrollController,
                  shrinkWrap: true,
                  childAspectRatio: 0.625,
                  crossAxisCount: 2,
                  children: List.generate(end, (index) {
                    // if (start + 20 > movieList.length)
                    //   end = movieList.length - start;
                    // Future.delayed(Duration(milliseconds: 100));
                    print(movieList.length);
                    return InkWell(
                      onTap: () => Navigator.of(context).push(
                        PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 500),
                            pageBuilder: (context, anim, secAnim) =>
                                MovieDetails(
                                  movie: movieList[start + index],
                                ),
                            settings: RouteSettings(arguments: [
                              movieList[start + index],
                              'relCard${start + index}',
                              'relTitle${start + index}'
                            ])),
                      ),
                      child: MovieCard(
                        cardTag: 'relCard${start + index}',
                        titleTag: 'relTitle${start + index}',
                        img: movieList[start + index].img,
                        title: movieList[start + index].title,
                      ),
                    );
                  }),
                ),
                _buildNavigate()
              ],
      ),
    );
  }
}

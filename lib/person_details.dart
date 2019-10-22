import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:session3/movie_card.dart';
import 'package:session3/movie_details.dart';
import 'package:session3/movie_mode.dart';
import 'package:session3/scoped_mode.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:toast/toast.dart';

class PersonDetails extends StatefulWidget {
  final Movie person;
  final String titleTag;
  final String cardTag;
  PersonDetails(this.person, this.cardTag, this.titleTag);
  @override
  _PersonDetailsState createState() => _PersonDetailsState();
}

class _PersonDetailsState extends State<PersonDetails>
    with TickerProviderStateMixin {
  List<String> bgImges = [];
  Map<String, dynamic> contact = {};
  List<Movie> movieCredits = [];
  List<Movie> tvCredits = [];
  int age;
  String birthDate;
  String birthPlace;
  String gender;
  String depart;
  String biography;
  final Animatable<double> _halfTween = Tween<double>(begin: 0.0, end: 0.5);
  final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);
  Animation<double> _iconTurns;

  Map<String, int> genres = {
    'Action': 28,
    'Adventure': 12,
    'Animation': 16,
    'Comedy': 35,
    'Crime': 80,
    'Documentary': 99,
    'Drama': 18,
    'Family': 10751,
    'Fantasy': 14,
    'History': 36,
    'Horror': 27,
    'Music': 10402,
    'Mystery': 9648,
    'Romance': 10749,
    'Sci-Fi': 878,
    'TV Movie': 10770,
    'Thriller': 53,
    'War': 10752,
    'Western': 37,
    'Action & Adventure': 10759,
    'Sci-Fi & Family': 10765,
    'Soap': 10766,
    'Talk': 10767,
    'War & Politics': 10768,
  };

  Future fetchPersonDetails() {
    return get(
            'https://api.themoviedb.org/3/person/${widget.person.id}?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&append_to_response=tv_credits%2Cmovie_credits%2Cexternal_ids')
        .then((fetchedPerson) {
      final Map decoded = json.decode(fetchedPerson.body);
      contact = decoded['external_ids'];
      bgImges = [];
      final List movies = decoded['movie_credits']['cast'];
      movies.forEach((element) {
        if (element['backdrop_path'] != null)
          bgImges.add(
              'https://image.tmdb.org/t/p/w500/${element['backdrop_path']}');
      });
      movieCredits = List.generate(movies.length, (index) {
        print(movies[index]['genre_ids']);
        return Movie(
          desc: movies[index]['overview'],
          genres: List.generate(movies[index]['genre_ids'].length, (i) {
            return genres.keys.firstWhere((s) {
              return genres[s] == movies[index]['genre_ids'][i];
            }, orElse: () {
              return null;
            });
          }),
          id: movies[index]['id'].toString(),
          img:
              'https://image.tmdb.org/t/p/w185/${movies[index]['poster_path']}',
          imgBG:
              'https://image.tmdb.org/t/p/w500/${movies[index]['backdrop_path']}',
          rating: movies[index]['vote_average'].toString(),
          title: (movies[index] as Map).containsKey('title')
              ? movies[index]['title']
              : movies[index]['original_title'],
        );
      });
      // print(movieCredits[10].desc);
      final List tv = decoded['tv_credits']['cast'];
      tvCredits = List.generate(tv.length, (index) {
        return Movie(
          desc: tv[index]['overview'],
          genres: List.generate(tv[index]['genre_ids'].length, (i) {
            return model.genres.keys.firstWhere((s) {
              return model.genres[s] == tv[index]['genre_ids'][i];
            }, orElse: () {
              return;
            });
          }),
          id: tv[index]['id'].toString(),
          img: 'https://image.tmdb.org/t/p/w185/${tv[index]['poster_path']}',
          imgBG:
              'https://image.tmdb.org/t/p/w500/${tv[index]['backdrop_path']}',
          rating: tv[index]['vote_average'].toString(),
          title: (tv[index] as Map).containsKey('name')
              ? tv[index]['name']
              : tv[index]['original_name'],
        );
      });
      age = DateTime.now().year -
          int.parse((decoded['birthday'] as String).split('-')[0]);
      birthDate = decoded['birthday'];
      birthPlace = decoded['place_of_birth'];
      biography = decoded['biography'];
      gender = widget.person.gender;
      depart = widget.person.department ?? decoded['known_for_department'];
    }, onError: (e) {});
  }

  MainModel model;
  bool isLoading = true;
  TabController _tabController;
  TabController _tabController2;
  AnimationController _controller;

  @override
  void initState() {
    model = ScopedModel.of(context);
    _controller =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _iconTurns = _controller.drive(_halfTween.chain(_easeInTween));
    _tabController = TabController(length: 2, vsync: this);
    _tabController2 = TabController(length: 2, vsync: this);
    fetchPersonDetails().then((_) {
      isLoading = false;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.blueGrey[300], boxShadow: [
          BoxShadow(
              color: Colors.white,
              blurRadius: 10,
              spreadRadius: -10,
              offset: Offset.fromDirection(11, 5))
        ]),
        child: TabBar(
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              child: Text('Biography'),
            ),
            Tab(
              child: Text('Filmography'),
            ),
          ],
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, scrolled) {
          return [
            SliverPersistentHeader(
              delegate: _SliverPersistentHeaderDelegate(
                  contactInfo: contact,
                  depart: widget.person.department ?? depart ?? '',
                  bgImg: isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : CarouselSlider(
                          aspectRatio: 1,
                          // height: 0,
                          enlargeCenterPage: true,

                          viewportFraction: 1.0,
                          items: List.generate(bgImges.length, (index) {
                            return Container(
                                width: MediaQuery.of(context).size.width,
                                child: Image.network(
                                  bgImges[index],
                                  fit: BoxFit.cover,
                                ));
                          }),
                        ),
                  avatar: Hero(
                    tag: widget.cardTag,
                    child: Container(
                      // child: Image.network(widget.person.img,fit: BoxFit.cover,),
                      // height: ,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(
                              widget.person.img,
                            ),
                            fit: BoxFit.cover,
                            alignment: AlignmentGeometry.lerp(
                                Alignment.center, Alignment.topCenter, 0.7)),
                        shape: BoxShape.circle,
                        border: Border.all(width: 1),
                      ),
                    ),
                  ),
                  title: widget.person.title,
                  titleTag: widget.titleTag),
              pinned: true,
            )
          ];
        },
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                controller: _tabController,
                children: [
                  Container(child: _buildBio()),
                  Container(child: _buildFilmo()),
                ],
              ),
      ),
    );
  }

  Widget _buildBio() {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            height: 0.5,
            child: Container(
              decoration:
                  BoxDecoration(boxShadow: [BoxShadow(blurRadius: 0.7)]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Biography:',
            style: TextStyle(fontSize: 36, color: Colors.white),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text(
                        'Department: ',
                        style: TextStyle(color: Color(0xff59b2b5)),
                      ),
                    ),
                  ),
                  Text(' $depart'),
                ],
              ),
              Divider(
                height: 3,
              ),
              Row(
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text('Birth Date: ',
                          style: TextStyle(color: Color(0xff59b2b5))),
                    ),
                  ),
                  Text(' $birthDate ($age)'),
                ],
              ),
              Divider(
                height: 3,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text('Birth Place: ',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xff59b2b5),
                          )),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    padding: EdgeInsets.only(left: 5),
                    child: Text(
                      '$birthPlace',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Divider(
                height: 3,
              ),
              Stack(
                children: <Widget>[
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Text('Bio: ',
                          style: TextStyle(color: Color(0xff59b2b5))),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 4, 0, 0),
                    child: Text('          $biography'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isExpanded = false;
  void _handleTap() {
    _isExpanded = !_isExpanded;
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    // PageStorage.of(context)?.writeState(context, _isExpanded);
  }

  Widget _buildFilmo() {
    return Column(
      // shrinkWrap: true,
      children: [
        TabBar(
          controller: _tabController2,
          tabs: <Widget>[
            Tab(
              text: 'Movies',
            ),
            Tab(
              text: 'TV-Shows',
            ),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController2,
            children: <Widget>[
              GridView.count(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 0.623,
                children: List.generate(movieCredits.length, (index) {
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      PageRouteBuilder(
                          pageBuilder: (context, anim, secAnim) => MovieDetails(
                                movie: movieCredits[index],
                              ),
                          settings: RouteSettings(arguments: [
                            movieCredits[index],
                            '${widget.cardTag}$index',
                            '${widget.titleTag}}$index',
                          ]),
                          transitionDuration: Duration(milliseconds: 700)),
                    ),
                    child: MovieCard(
                      cardTag: '${widget.cardTag}$index',
                      titleTag: '${widget.titleTag}}$index',
                      title: movieCredits[index].title,
                      img: movieCredits[index].img,
                    ),
                  );
                }),
              ),
              GridView.count(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 0.623,
                children: List.generate(tvCredits.length, (index) {
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      PageRouteBuilder(
                          pageBuilder: (context, anim, secAnim) => MovieDetails(
                                movie: tvCredits[index],
                              ),
                          settings: RouteSettings(arguments: [
                            tvCredits[index],
                            '${widget.cardTag}$index',
                            '${widget.titleTag}$index',
                          ]),
                          transitionDuration: Duration(milliseconds: 700)),
                    ),
                    child: MovieCard(
                      cardTag: '${widget.cardTag}$index',
                      titleTag: '${widget.titleTag}$index',
                      title: tvCredits[index].title,
                      img: tvCredits[index].img,
                    ),
                  );
                }),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class _SliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final _stackColorTween =
      ColorTween(begin: Colors.transparent, end: Color(0xff59b2b5));
  final _avatarTween = SizeTween(
    begin: Size.square(110),
    end: Size(50, 50),
  );
  final _avatarAlign = AlignmentTween(
      begin:
          AlignmentGeometry.lerp(Alignment.center, Alignment.bottomCenter, 0.3),
      end: AlignmentGeometry.lerp(Alignment.center, Alignment.centerLeft, 1));
  final _avatarMargin = EdgeInsetsTween(
      begin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      end: EdgeInsets.fromLTRB(10, 25, 0, 0));

  final _titleMargin = EdgeInsetsTween(
      begin: EdgeInsets.fromLTRB(0, 0, 0, 0),
      end: EdgeInsets.fromLTRB(70, 25, 0, 0));
  final _titleAlign = AlignmentTween(
    begin:
        AlignmentGeometry.lerp(Alignment.center, Alignment.bottomCenter, 0.6),
    end: Alignment.centerLeft,
  );
  final _departAlign = AlignmentTween(
    begin:
        AlignmentGeometry.lerp(Alignment.center, Alignment.bottomCenter, 0.7),
    end: Alignment.centerLeft,
  );
  final _contactAlign = AlignmentTween(
    begin:
        AlignmentGeometry.lerp(Alignment.center, Alignment.bottomCenter, 0.95),
    end: Alignment.centerLeft,
  );
  final _titleColor = ColorTween(begin: Colors.white, end: Colors.white);
  final _genreColor =
      ColorTween(begin: Colors.white60, end: Colors.transparent);
  final _shadowColor = ColorTween(begin: Color(0xff59b2b5), end: Colors.white);
  final Widget avatar;
  final String title;
  Widget bgImg;
  final String img;
  final List genres;
  final String depart;
  final String cert;
  final String runtime;
  final String titleTag;
  final Map contactInfo;
  _SliverPersistentHeaderDelegate(
      {this.avatar,
      this.title,
      this.img,
      this.genres,
      this.bgImg,
      this.depart,
      this.cert,
      this.runtime,
      this.titleTag,
      this.contactInfo}) {
    print('ss');
  }
  // bool _isPlaying = isPlaying;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    print('ytIDssss');
    double size = shrinkOffset / 400;
    Size avatarSize = _avatarTween.lerp(size);
    EdgeInsets avatarMargin = _avatarMargin.lerp(size);
    Alignment avatarAlign = _avatarAlign.lerp(size);
    EdgeInsets titlePadding = _titleMargin.lerp(size);
    Alignment titleAlign = _titleAlign.lerp(size);
    Alignment departAlign = _departAlign.lerp(size);
    Alignment contactAlign = _contactAlign.lerp(size);
    // double opacity = _opacity.lerp(size);
    Color titleColor = _titleColor.lerp(size);
    Color genreColor = _genreColor.lerp(size);
    Color shadowColor = _shadowColor.lerp(size);
    Color stackColor = _stackColorTween.lerp(size);
    return Container(
      color: stackColor,
      width: 440,
      child: Stack(
        overflow: Overflow.visible,
        fit: StackFit.loose,
        children: <Widget>[
          // Container(
          //   height: 100,
          //   color: Colors.white
          // ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: (maxExtent - shrinkOffset) / 3.1 + minExtent,
              width: 440,
              // alignment: Alignment.center,

              child: Opacity(opacity: 1 - size, child: bgImg),
            ),
          ),
          Container(
            // top: (maxExtent - shrinkOffset) / 2,
            child: Padding(
              padding: avatarMargin,
              child: Align(
                alignment: avatarAlign,
                child: SizedBox.fromSize(
                  size: avatarSize,
                  child: avatar,
                ),
              ),
            ),
          ),
          Padding(
            padding: titlePadding,
            child: Align(
                alignment: departAlign,
                child: Opacity(
                    opacity: 1 - size,
                    child: Text(
                      depart,
                      style: TextStyle(
                          color: Colors.white60, fontWeight: FontWeight.bold),
                    ))),
          ),

          Padding(
            padding: titlePadding,
            child: Align(
              alignment: titleAlign,
              child: Hero(
                tag: titleTag,
                child: Text(title.toString(),
                    style: TextStyle(
                        fontFamily: 'Arial',
                        decoration: TextDecoration.none,
                        color: titleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        shadows: [
                          BoxShadow(blurRadius: 2, color: shadowColor)
                        ])),
              ),
            ),
          ),
          Padding(
            padding: titlePadding,
            child: Align(
              alignment: contactAlign,
              child: Opacity(
                opacity: 1 - size,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    contactInfo['facebook_id'] == null
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: InkWell(
                              onLongPress: () => Clipboard.setData(ClipboardData(
                                      text:
                                          'https://www.facebook.com/${contactInfo['facebook_id']}'))
                                  .then((_) => Toast.show('Copied', context)),
                              onTap: () async {
                                final url =
                                    'https://www.facebook.com/${contactInfo['facebook_id']}';
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else
                                  throw 'error';
                              },
                              child: Icon(
                                FontAwesomeIcons.facebook,
                                size: 32,
                                color: Colors.blueGrey[100],
                              ),
                            ),
                          ),
                    contactInfo['twitter_id'] == null
                        ? Container(
                            width: 0,
                          )
                        : Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: InkWell(
                              onLongPress: () => Clipboard.setData(ClipboardData(
                                      text:
                                          'https://www.twitter.com/${contactInfo['twitter_id']}'))
                                  .then(
                                (_) => Toast.show('Copied', context),
                              ),
                              onTap: () async {
                                final url =
                                    'https://www.twitter.com/${contactInfo['twitter_id']}';
                                if (await canLaunch(url))
                                  await launch(url);
                                else
                                  throw 'error';
                              },
                              child: Icon(
                                FontAwesomeIcons.twitter,
                                size: 32,
                                color: Colors.blueGrey[100],
                              ),
                            ),
                          ),
                    contactInfo['instagram_id'] == null
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: InkWell(
                              onLongPress: () => Clipboard.setData(ClipboardData(
                                      text:
                                          'https://www.instagram.com/${contactInfo['instagram_id']}'))
                                  .then(
                                (_) => Toast.show('Copied', context),
                              ),
                              onTap: () async {
                                final url =
                                    'https://www.instagram.com/${contactInfo['instagram_id']}';
                                if (await canLaunch(url))
                                  launch(url);
                                else
                                  throw 'error';
                              },
                              child: Icon(
                                FontAwesomeIcons.instagram,
                                size: 32,
                                color: Colors.blueGrey[100],
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverPersistentHeaderDelegate oldDelegate) {
    // TODO: implement shouldRebuild
    // print(oldDelegate._isPlaying);
    // print(_isPlaying);
    // return isPlaying != _isPlaying;
    return true;
  }

  @override
  // TODO: implement maxExtent
  double get maxExtent => 400;
  @override
  // TODO: implement minExtent
  double get minExtent => 100;
}

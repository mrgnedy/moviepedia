import 'dart:convert';
import 'package:session3/details_header.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:session3/list.dart';
import 'package:session3/lst_model.dart';
import 'package:session3/movie_card.dart';
import 'package:session3/movie_mode.dart';
import 'package:session3/movies_card.dart';
import 'package:session3/person_details.dart';
import 'package:session3/scoped_mode.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player/youtube_player.dart';

class MovieDetails extends StatefulWidget {
  final Movie movie;
  MovieDetails({@required this.movie});
  @override
  _MovieDetailsState createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  Movie movie;
  List<Movie> movies;
  TabController _tabController;
  TabController _tabController2;
  MainModel model;
  List<Widget> movieLists = [];
  String imdb;
  @override
  void initState() {
    model = ScopedModel.of(context);
    movie = widget.movie;
    movie.mediaType == 'tv'
        ? fetchTVDetails(movie.id).then((_) => fetchSeasons())
        : fetchDetails(movie.id, 'movie').whenComplete(() => fetchDownload());
    fetchLists(movie.id, 1);
    // fetchRecommend(movie.id, 1);
    model.getFavOrWatch('favorite', movie.mediaType).then((fav) {
      isFav =
          !(fav.singleWhere((mov) => mov.id == movie.id, orElse: () => null) ==
              null);
      if (!mounted) return;
      setState(() {});
    });
    model.getFavOrWatch('watchlist', movie.mediaType).then((wishList) {
      isWish = !(wishList.singleWhere((mov) => mov.id == movie.id,
              orElse: () => null) ==
          null);
      if (!mounted) return;
      setState(() {});
    });
    _tabController = TabController(vsync: this, length: 4, initialIndex: 0);
    _tabController.offset = 0;
    super.initState();
  }

  // Future fetchedLists(String id, int page) {
  //   // print('objecZt');
  //   return get(
  //           ' https://api.themoviedb.org/3/movie/$id/lists?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&page=$page')
  //       .then((res) {
  //     print('objecZt');
  //     final Map decoded = json.decode(res.body);
  //     movieLists = List.generate(decoded['results'].length, (index) {
  //       print('zazazaz');
  //       return MovieCard(
  //         img: decoded['results'][index]['poster_path'],
  //         title: decoded['results'][index]['title'],
  //         index: index,
  //       );
  //     });
  //   }, onError: (e) {});
  // }

  Future fetchLists(String id, int page) {
    return get(
            'https://api.themoviedb.org/3/${movie.mediaType}/$id/lists?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&page=$page')
        .then((res) {
      if (res.statusCode != 200) return;
      print('sssssssssssss');
      final Map decoded = json.decode(res.body);
      if (decoded['results'] == null) return;
      movieLists = List.generate(decoded['results'].length, (index) {
        final Map list = decoded['results'][index];
        this.index = index;
        print('zazazaz');
        return InkWell(
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(
                maintainState: true,
                pageBuilder: (context, anime, secAnime) => MovieLists(
                      ListModel(
                          id: list['id'],
                          count: list['item_count'],
                          desc: list['description'],
                          name: list['name'],
                          img:
                              'https://image.tmdb.org/t/p/w185/${list['poster_path']}'),
                    )));
          },
          child: MovieCard(
            img:
                'https://image.tmdb.org/t/p/w185/${decoded['results'][index]['poster_path']}',
            title: decoded['results'][index]['name'],
            cardTag: 'similarCard$index',
            titleTag: 'similarTitle$index',
          ),
        );
      });
    }, onError: (e) {});
  }

  Future fetchRecommend(String id, int page) {
    return get(
            'https://api.themoviedb.org/3/${movie.mediaType}/$id/recommendations?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&page=$page')
        .then((res) {
      print('saddddddd');
      Map decoded = json.decode(res.body);
      movies = List.generate(decoded['results'].length, (index) {
        final fetchedMovie = decoded['results'][index];
        return Movie(
          mediaType: movie.mediaType,
          id: fetchedMovie['id'].toString(),
          title: fetchedMovie['title'],
          desc: fetchedMovie['overview'],
          genres: List.generate(fetchedMovie['genre_ids'].length, (index) {
            return model.genres.keys.firstWhere((s) {
              return model.genres[s] == fetchedMovie['genre_ids'][index];
            }, orElse: () {
              return;
            });
          }),
          img: 'https://image.tmdb.org/t/p/w185/${fetchedMovie['poster_path']}',
          imgBG:
              'https://image.tmdb.org/t/p/w500/${fetchedMovie['backdrop_path']}',
          rating: fetchedMovie['vote_average'].toString(),
        );
      });
    }, onError: (e) {});
  }

  List<Widget> torrents = [];
  Future fetchDownload() {
    return get('https://yts.lt/api/v2/list_movies.json?query_term=$imdb').then(
        (res) {
      final Map decoded = json.decode(res.body);
      if (decoded['data']['movies'] == null) return;
      torrents = List.generate(decoded['data']['movies'][0]['torrents'].length,
          (index) {
        final Map<String, dynamic> torrLink =
            decoded['data']['movies'][0]['torrents'][index];
        return Card(
          child: ListTile(
            title: Text(
              '${torrLink['quality']}${torrLink['type'].replaceFirst(torrLink['type'][0], torrLink['type'][0].toUpperCase())}',
              style: TextStyle(
                  color: Color(0xff59b2b5), fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              torrLink['size'],
              style: TextStyle(color: Color(0xaa59b2b5)),
            ),
            trailing: IconButton(
              onPressed: () async {
                if (await canLaunch(torrLink['url']))
                  launch(torrLink['url']);
                else
                  Toast.show('Error', context);
              },
              icon: Icon(
                FontAwesomeIcons.download,
                color: Color(0xff59b2b5),
              ),
            ),
          ),
        );
      });
      if (!mounted) return;
      setState(() {});
    }, onError: (e) {
      print(e);
    });
  }

  List<Map> network;
  String lastAirDate;
  var nextEpisode;
  int numOfEpisodes;
  Future fetchTVDetails(String id) {
    isLoading = true;
    setState(() {});
    return get(
            'https://api.themoviedb.org/3/tv/${movie.id}?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&append_to_response=content_ratings%2Cimages%2Ccredits%2Crecommendations%2C%20credits%2Cvideos')
        .then((res) {
      if (res.statusCode != 200) return null;
      final Map decoded = json.decode(res.body);
      // if (decoded['results'] == null) return null;
      print('gfsdgffffffffffffffffffffffffffffffffffff');
      final hrs = decoded['episode_run_time'][0] ~/ 60;
      final min = decoded['episode_run_time'][0] - hrs * 60;
      runtime = '${hrs}h$min';
      releaseDate = decoded['first_air_date'];
      lastAirDate = decoded['last_air_date'];
      nextEpisode = decoded['next_episode_to_air'];
      rate = decoded['vote_average'].toString();
      network = List.generate(decoded['networks'].length, (index) {
        return {
          'name': decoded['networks'][index]['name'],
          'logo':
              'https://image.tmdb.org/t/p/w185/${decoded['networks'][index]['logo_path']}',
        };
      });
      numOfSeason = decoded['number_of_seasons'];
      numOfEpisodes = decoded['number_of_episodes'];
      final contentRatings = (decoded['content_ratings']['results'] as List);
      cert = contentRatings.firstWhere((rate) => rate['iso_3166_1'] == 'US',
          orElse: () => contentRatings[0])['rating'];
      print('ssssssssssssssssssssssssssssssssssssssssssssssa');
      cast = decoded['credits']['cast'];
      status = decoded['status'];
      ytID = decoded['videos']['results'].isEmpty
          ? null
          : decoded['videos']['results'][0]['key'];

      movies =
          List.generate(decoded['recommendations']['results'].length, (index) {
        final show = decoded['recommendations']['results'][index];
        final MainModel model = MainModel();
        return Movie(
          id: show['id'].toString(),
          desc: show['overview'],
          title: show['name'],
          img: 'https://image.tmdb.org/t/p/w185/${show['poster_path']}',
          imgBG: 'https://image.tmdb.org/t/p/w500/${show['backdrop_path']}',
          genres: List.generate(show['genre_ids'].length, (index) {
            return model.genres.keys.firstWhere((s) {
              return model.genres[s] == show['genre_ids'][index];
            }, orElse: () {
              return;
            });
          }),
          mediaType: 'tv',
          rating: show['vote_average'].toString(),
        );
      });
      isLoading = false;
      if (!mounted) return null;
      setState(() {});
    });
  }

  Future fetchDetails(String id, String mediaType) {
    isLoading = true;
    if (!mounted) return null;
    setState(() {});
    return get(
            'https://api.themoviedb.org/3/movie/$id?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&append_to_response=videos%2Crecommendations%2Ccredits%2Cimages%2Crelease_dates')
        .then((s) {
      Map decoded = json.decode(s.body);
      status = decoded['status'];
      imdb = decoded['imdb_id'];

      releaseDate = decoded['release_date'] ?? decoded['first_air_date'];
      final hrs = (mediaType == 'movie'
              ? decoded['runtime']
              : decoded['episode_run_time'][0]) ~/
          60;
      final mins = (mediaType == 'movie'
              ? decoded['runtime']
              : decoded['episode_run_time'][0]) -
          hrs * 60;
      runtime = '${hrs}h$mins';
      cast = decoded['credits']['cast'];
      rate = decoded['vote_average'].toString();
      final list = (decoded['release_dates']['results'] as List);
      final map = list.firstWhere((s) {
        return s['iso_3166_1'] == 'US';
      }, orElse: () {
        return list[0];
      });
      cert = map['release_dates'][0]['certification'];
      ytID = decoded['videos']['results'].isEmpty
          ? null
          : decoded['videos']['results'][0]['key'];
      print('YT ID is$ytID');
      print(status);
      movies =
          List.generate(decoded['recommendations']['results'].length, (index) {
        final fetchedMovie = decoded['recommendations']['results'][index];
        return Movie(
          mediaType: movie.mediaType,
          id: fetchedMovie['id'].toString(),
          title: fetchedMovie['title'],
          desc: fetchedMovie['overview'],
          genres: List.generate(fetchedMovie['genre_ids'].length, (index) {
            return model.genres.keys.firstWhere((s) {
              return model.genres[s] == fetchedMovie['genre_ids'][index];
            }, orElse: () {
              return;
            });
          }),
          img: 'https://image.tmdb.org/t/p/w185/${fetchedMovie['poster_path']}',
          imgBG:
              'https://image.tmdb.org/t/p/w500/${fetchedMovie['backdrop_path']}',
          rating: fetchedMovie['vote_average'].toString(),
        );
      });
      network = List.generate(decoded['production_companies'].length, (index) {
        final company = decoded['production_companies'][index];
        return {
          'logo': 'https://image.tmdb.org/t/p/w185/${company['logo_path']}',
          'name': '${company['name']}',
        };
      });
      isLoading = false;
      if (mounted) setState(() {});
    });
  }

  int index;
  String runtime = ' ';
  String cert = ' ';
  String rate = ' ';
  bool isLoading = false;
  List cast = [];
  String releaseDate = ' ';
  String ytID;
  String status = ' ';
  @override
  void dispose() {
    // model.stackedIndex--;
    // TODO: implement dispose
    _tabController.dispose();
    if (_tabController2 != null) _tabController2.dispose();

    super.dispose();
  }

  String cardTag = '';
  String titleTag = '';
  List<Widget> tabs = List(4);
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    movie = (ModalRoute.of(context).settings.arguments as List)[0];

    cardTag = (ModalRoute.of(context).settings.arguments as List)[1];
    titleTag = (ModalRoute.of(context).settings.arguments as List)[2];
    // fetchedLists(movie.id, 1).then((_) {
    //   setState(() {});
    // });

    // Future.delayed(Duration(seconds: 003), ()=>fetchDownload());
    // fetchDownload();
    // print(ytID);
    super.didChangeDependencies();
  }

  // callback() => setState(() {});
  bool get wantKeepAlive => true;

  bool isPlaying = false;
  bool _isScrolled = false;

  @override
  Widget build(BuildContext context) {
    tabs = [
      _buildInfo(),
      _buildCast(),
      _buildRelated(),
      movie.mediaType == 'tv' ? _buildEpisodeGuide() : _buildDonwload()
    ];
    return WillPopScope(
      onWillPop: () async {
        model.stackedIndex--;
        return true;
      },
      child: Scaffold(
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
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
                child: Text('Info'),
              ),
              Tab(
                child: Text('Cast'),
              ),
              Tab(
                child: Text('Related'),
              ),
              Tab(
                child: Text('Reviews'),
              ),
            ],
          ),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, isScrolled) {
            _isScrolled = isScrolled;
            return [
              SliverPersistentHeader(
                delegate: SliverHeader(
                  avatar: Hero(
                    tag: cardTag,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(movie.img, fit: BoxFit.cover)),
                  ),
                  title: (movie.title),
                  img: movie.imgBG,
                  genres: movie.genres,
                  rate: rate,
                  cert: cert,
                  runtime: runtime,
                  titleTag: titleTag,
                  userControls: _userControls(),
                  bgImg: isPlaying
                      ? Container(
                          height: 500,
                          child: YoutubePlayer(
                            // aspectRatio:2 ,
                            context: context,
                            // showThumbnail: true,

                            quality: YoutubeQuality.HIGH,
                            source: ytID,
                            // autoPlay: true,
                            callbackController: (c) {},
                            switchFullScreenOnLongPress: true,
                            onVideoEnded: () {
                              isPlaying = false;
                              if (!mounted) return;
                              setState(() {});
                              // this.build(context,? shrinkOffset, overlapsContent);
                            },
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: NetworkImage(movie.imgBG),
                                  fit: BoxFit.cover)),
                          child: ytID == null
                              ? null
                              : Center(
                                  child: InkWell(
                                  onTap: () {
                                    isPlaying = true;
                                    if (!mounted) return;
                                    setState(() {});
                                  },
                                  child: Opacity(
                                    // color: Colors.white,
                                    opacity: 0.8,
                                    child: Icon(
                                      Icons.play_circle_filled,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ))),
                ),
                pinned: true,
              ),
            ];
          },
          body: Container(
            // padding:4EdgeInsets.only(top:100),
            alignment: Alignment.topCenter,
            // height: 370,
            // width: 440,
            child: TabBarView(controller: _tabController, children: tabs),
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            height: 0.5,
            child: Container(
              decoration:
                  BoxDecoration(boxShadow: [BoxShadow(blurRadius: 0.7)]),
            ),
          ),
        ),
        _sideTitle('Overview:'),
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 10, 40, 10),
          child: Text(movie.desc),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 0.5,
            child: Container(
              decoration:
                  BoxDecoration(boxShadow: [BoxShadow(blurRadius: 0.7)]),
            ),
          ),
        ),
        _sideTitle('Status:'),
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 10, 40, 10),
          child: Text(status ?? ' '),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 10, 40, 10),
          child: Text('Release Date : $releaseDate'),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 0.5,
            child: Container(
              decoration:
                  BoxDecoration(boxShadow: [BoxShadow(blurRadius: 0.7)]),
            ),
          ),
        ),
        _sideTitle('Production'),
        Padding(
          padding: const EdgeInsets.fromLTRB(50, 10, 40, 10),
          child: isLoading
              ? CircularProgressIndicator()
              : Column(
                  // shrinkWrap: true,
                  children: List.generate(network.length, (index) {
                    return Card(
                      color: Color.fromARGB(255, 78, 86, 106),
                      child: ListTile(
                        leading: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue),
                              image: DecorationImage(
                                  fit: BoxFit.contain,
                                  image: NetworkImage(network[index]['logo']))),
                        ),
                        title: Container(
                            width: 100,
                            alignment: Alignment.center,
                            child: Text(network[index]['name'],
                                style: TextStyle(
                                  color: Colors.white,
                                ))),
                      ),
                    );
                  }),
                ),
        ),
      ],
    );
  }

  Widget _buildDonwload() {
    return GridView.count(
      childAspectRatio: 2.5,
      crossAxisCount: 2,
      shrinkWrap: true,
      children: torrents,
      padding: EdgeInsets.fromLTRB(5, 50, 5, 10),
    );
  }

  Widget _sideTitle(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Card(
          child: Text(
            ' $text ',
            style: TextStyle(
              fontSize: 36,
              color: Color(0xff59b2b5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCast() {
    return ListView(
        children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Cast:',
          style: TextStyle(fontSize: 36, color: Colors.white),
        ),
      )
    ]..addAll(List.generate(cast.length, (index) {
            return ListTile(
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 500),
                  pageBuilder: (context, anim, secAnim) => PersonDetails(
                      Movie.person(
                          // department: cast[index]['known_for_department'],
                          title: cast[index]['name'],
                          gender:
                              cast[index]['gender'] == 1 ? 'Female' : 'Male',
                          id: cast[index]['id'].toString(),
                          img:
                              'https://image.tmdb.org/t/p/w185/${cast[index]['profile_path']}'),
                      'personCard$index',
                      'personTitle$index'),
                ));
              },
              leading: Container(
                child: Hero(
                  tag: 'personCard$index',
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                        'https://image.tmdb.org/t/p/w185/${cast[index]['profile_path']}'),
                  ),
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(width: 1),
                ),
              ),
              title: Hero(
                  tag: 'personTitle$index',
                  child: Text('${cast[index]['name']}')),
              subtitle: Text('${cast[index]['character']}'),
            );
          })));
  }

  Widget _buildRelated() {
    return ListView(
      // primary: fal??se,
      physics: NeverScrollableScrollPhysics(),
      addRepaintBoundaries: false,
      children: [
        Container(
          // height: 200,
          child: MoviesCard(
            movies,
            'similarCard',
            'similarTitle',
            genre: 'Similar',
            index: index,
          ),
        )
      ]
        ..add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: SizedBox(
              height: 0.5,
              child: Container(
                decoration:
                    BoxDecoration(boxShadow: [BoxShadow(blurRadius: 0.7)]),
              ),
            ),
          ),
        )
        ..addAll([
          Container(
            // height: 500,
            child: GridView.count(
                childAspectRatio: 0.62,
                addRepaintBoundaries: false,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                children: movieLists),
          )
        ]),
    );
  }

  int numOfSeason = 0;
  Widget _buildEpisodeGuide() {
    _tabController2 =
        TabController(vsync: this, length: numOfSeason, initialIndex: 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Align(
                  alignment: AlignmentGeometry.lerp(
                      Alignment.bottomCenter, Alignment.center, 0.1),
                  child: Container(
                    height: 50,
                    width: numOfSeason * 60.0,
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          // bottom: BorderSide(
                          color: Colors.blue,
                          // ),
                        ),
                      ),
                      controller: _tabController2,
                      tabs: List.generate(numOfSeason, (index) {
                        return Container(
                          // color:index == _tabController2.? Colors.white12 :Colors.transparent,

                          child: Tab(
                            child: Text(
                                'S${(index + 1).toString().padLeft(2, '0')}'),
                            // text: 'S${index.toString().padLeft(2, '0')}',
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: TabBarView(
              controller: _tabController2,
              children: List.generate(numOfSeason, (s) {
                return seasons.length <= s
                    ? Center(child: CircularProgressIndicator())
                    : ListView(
                        children: List.generate(seasons[s].length, (ep) {
                        return Card(
                            color: Color.fromARGB(255, 78, 86, 106),
                            child: ListTile(
                              // isThreeLine: true,
                              leading: Container(
                                  height: 80,
                                  width: 70,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          seasons[s][ep].img,
                                        ),
                                        fit: BoxFit.fill,
                                      )),
                                  child: null),
                              title: Container(
                                width: 100,
                                child: Text(seasons[s][ep].title,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ),
                              subtitle: Container(
                                width: 100,
                                // height: 100,
                                child: Text(
                                  seasons[s][ep].desc,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              trailing: Container(
                                  width: 100,
                                  child: Text(seasons[s][ep].airDate)),
                            ));
                      }));
              }),
            ),
          )
        ],
      ),
    );
  }

  Future<bool> toggleFav(String type, bool state) {
    print(movie.mediaType);
    print(movie.id);
    return model
        .toggleFav(int.parse(movie.id), movie.mediaType, state, type)
        .then((_) {
      return model.getFavOrWatch(type, movie.mediaType).then((s) {
        return !(s.singleWhere((mov) => mov.id == movie.id,
                orElse: () => null) ==
            null);
      });
    }, onError: (e) => print(e));
  }

  List<List> seasons = [];
  List episodes = [];

  Future fetchSeasons() async {
    seasons = [];
    List<Future> futures = [];
    for (int i = 1; i <= numOfSeason; i++) {
      await fetchSeasonDetails(i).then((_) {
        if (!mounted) return;
        setState(() {});
      });
      print(i);
    }
    if (!mounted) return;
    setState(() {});
    // return Future.wait(futures).then((_) {
    //   if (!mounted) return;
    //   setState(() {});
    //   futures = [];
    // });
  }

  Future fetchSeasonDetails(int s) {
    return get(
            'https://api.themoviedb.org/3/tv/${movie.id}/season/$s?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US')
        .then((res) {
      if (res.statusCode != 200) return null;
      episodes = [];
      final Map decoded = json.decode(res.body);
      episodes = List.generate(decoded['episodes'].length, (index) {
        final Map episode = decoded['episodes'][index];
        return Movie(
            desc: episode['overview'],
            title: episode['name'],
            rating: episode['vote_average'].toString(),
            img: 'https://image.tmdb.org/t/p/w185/${episode['still_path']}',
            airDate: episode['air_date']);
      });
      print('episodes = ${episodes.length}');
      seasons.add(episodes);
      return episodes;
    });
  }

  bool isFav = false;
  bool isWish = false;
  Widget _userControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: () async {
              isFav = !isFav;
              setState(() {});
              isFav = await toggleFav('favorite', isFav)
                  .whenComplete(() => setState(() {}));
            },
            icon: Icon(
                isFav ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart),
            color: Colors.blueGrey[100],
            iconSize: 32,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: () async {
              isWish = !isWish;
              setState(() {});
              isWish = await toggleFav('watchlist', isWish)
                  .whenComplete(() => setState(() {}));
            },
            icon: Icon(isWish
                ? FontAwesomeIcons.solidBookmark
                : FontAwesomeIcons.bookmark),
            color: Colors.blueGrey[100],
            iconSize: 32,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            onPressed: () {},
            icon: Icon(FontAwesomeIcons.plus),
            color: Colors.blueGrey[100],
            iconSize: 32,
          ),
        ),
      ],
    );
  }
}

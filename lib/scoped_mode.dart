import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:session3/discover_model.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:session3/movie_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainModel extends Model {
  int pages;
  int peoplePages;
  int tvPages;

  int currentPage = 1;

  void setMoviePage(int page) {
    currentPage = page;
    notifyListeners();
  }

  int currentPeoplePage = 1;
  void setTvPage(int page) {
    currentTvPage = page;
    notifyListeners();
  }

  int currentTvPage = 1;
  void setPersonPage(int page) {
    currentPeoplePage = page;
    notifyListeners();
  }

  // List favourites = [];
  // List wishList = [];
  List<List> createdLists = [];

  StatefulWidget x;

  PageController pageController = PageController();
  bool isLoading = false;
  String popularType = '';
  String popularUrl;
  String discoverUrl =
      'https://api.themoviedb.org/3/discover/movie?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&sort_by=popularity.desc';
  String searchUrl =
      'https://api.themoviedb.org/3/search/movie?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&include_adult=false&query=';
  int _selPage = 0;
  setPage(int s) {
    _selPage = s;
    pageController.animateToPage(s,
        duration: Duration(milliseconds: 400), curve: Curves.decelerate);
    // notifyListeners();
  }

  int get selPage {
    return _selPage;
  }

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
  String query = '';
  String searchQuery;
  String discoverQuery = '';
  String castQuery = '&with_cast=';
  List<Future> futures = [];
  Future oneCast(var ctrl) {
    return get(
            'https://api.themoviedb.org/3/search/person?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&query=${ctrl.text}&page=1&include_adult=false')
        .then((response) {
      Map decodedMsg = json.decode(response.body);
      if (decodedMsg['results'] == 'null') {
        movies = null;
        notifyListeners();
        return;
      }
      String castID = decodedMsg['results'][0]['id'].toString();
      print(castID);
      castQuery += '$castID,';
    }, onError: (e) {
      print(e.toString());
    });
  }

  // Future getCast(List ctrls) {

  //   castQuery = '&with_cast=';
  //   for (int i = 0; i < ctrls.length; i++) {
  //     futures.add(oneCast(ctrls[i]));
  //     // Future.delayed(Duration(milliseconds: 1400), ()=>print(castQuery)) ;
  //   }
  //   return Future.wait(futures);
  // }

  makeQuery(
    String castQuery,
    MaskedTextController dateGte,
    TextEditingController dateLte,
    String _isAdult,
    List gens, [
    TextEditingController search,
  ]) async {
    currentPage = 1;
    currentPeoplePage = 1;
    currentTvPage = 1;
    // String castQuery = '';
    persons = [];
    tv = [];
    movies = [];
    if (search.text.isNotEmpty) {
      print(search.text);
      query = '$searchUrl${search.text}';
      fetch(query).then((fetchedMovies) {
        // movies = fetchedMovies;
        // print(currentPage);
      });
      fetchTv();
      fetchPeople();
      return;
    }
    String dateQuery =
        '&primary_release_date.gte=${dateGte.text}&primary_release_date.lte=${dateLte.text}';
    String adultQuery = '&include_adult=$_isAdult';
    String genreQuery = '&with_genres=';
    gens.forEach((e) {
      if (e != null) genreQuery += '${genres[e]},';
    });
    print(genreQuery);
    discoverQuery = '$castQuery$dateQuery$genreQuery$adultQuery';
    print(discoverQuery);
    query = '$discoverUrl$discoverQuery';
    print(query);
    fetch(query);
    // getCast(ctrls).then((onValue) {
    //   print(castQuery.replaceAll(' ', ''));
    //   futures = [];
    // });
  }

  int stackedIndex = 0;
  List<Movie> movies = [];
  List<Movie> persons = [];
  List<Movie> tv = [];
  List<Movie> collections = [];
  Future<List<Movie>> fetchData({String genre}) {
    genre = genre.isEmpty ? '' : '&genre=$genre';

    return get('https://yts.lt/api/v2/list_movies.json?limit=6$genre').then(
        (res) {
      Map decodedMap = json.decode(res.body);
      movies = List.generate(decodedMap['data']['movies'].length, (index) {
        Map movie = decodedMap['data']['movies'][index];
        // print(movie);
        return Movie(
          img: movie['medium_cover_image'],
          imgBG: movie['background_image_original'],
          title:
              movie['title'].isEmpty ? movie['original_name'] : movie['title'],
          imdb: movie['imdb_code'],
          genres: movie['genres'],
          rating: movie['rating'].toString(),
          trailer: movie['yt_trailer_code'],
          torrent: movie['torrents'],
          // mpa: movie['mpa_rating'],
          desc: movie['description_full'],
        );
      });
      return movies;
    }, onError: (e) {});
  }

  Future<List<Movie>> fetch([String url]) {
    popularUrl =
        'https://api.themoviedb.org/3/movie/$popularType?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US';
    List<Movie> _movies = [];
    isLoading = true;
    notifyListeners();
    return get('$query&page=$currentPage').then((res) {
      if (res.body == 'be right back') {
        isLoading = false;
        notifyListeners();
        return null;
      }
      Map decodedMsg = json.decode(res.body);
      // decodedMsg['results'].forEach((f) {});
      // print(decodedMsg);
      movies = [];

      decodedMsg['results'].forEach((movie) {
        // var movie = decodedMsg['results'][index];
        // print(movie);
        pages = decodedMsg['total_pages'];
        movies.add(Movie(
          mediaType: 'movie',
          desc: movie['overview'],
          genres: List.generate(movie['genre_ids'].length, (index) {
            return genres.keys.firstWhere((s) {
              return genres[s] == movie['genre_ids'][index];
            }, orElse: () {
              return;
            });
          }),
          img: 'https://image.tmdb.org/t/p/w185/${movie['poster_path']}',
          imgBG: 'https://image.tmdb.org/t/p/w500/${movie['backdrop_path']}',
          rating: movie['vote_average'].toString(),
          id: movie['id'].toString(),
          title: movie['title'],
        ));
      });
      isLoading = false;
      notifyListeners();
      // print(movies[3].title);
      return _movies;
    }, onError: (e) {
      print('object');
    });
  }

  Future<List<Movie>> fetchDiscover(String url,
      {String sortby, String mediaType}) {
    popularUrl =
        'https://api.themoviedb.org/3/$mediaType/$popularType?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US';
    List<Movie> _movies = [];
    isLoading = true;
    notifyListeners();
    return get('$url&page=$currentPage').then((res) {
      print(url);
      if (res.body == 'be right back') {
        isLoading = false;
        notifyListeners();
        return null;
      }
      Map decodedMsg = json.decode(res.body);
      // decodedMsg['results'].forEach((f) {});
      // print(decodedMsg);
      // final List deco = mediaType =='tv' ? decodedMsg : decodedMsg['results'];
      decodedMsg['results'].forEach((movie) {
        // var movie = decodedMsg['results'][index];
        // print(movie);
        pages = decodedMsg['total_pages'];
        _movies.add(Movie(
          mediaType: mediaType,
          desc: movie['overview'],
          genres: List.generate(movie['genre_ids'].length, (index) {
            return genres.keys.firstWhere((s) {
              return genres[s] == movie['genre_ids'][index];
            }, orElse: () {
              return;
            });
          }),
          img: 'https://image.tmdb.org/t/p/w185/${movie['poster_path']}',
          imgBG: 'https://image.tmdb.org/t/p/w500/${movie['backdrop_path']}',
          rating: movie['vote_average'].toString(),
          id: movie['id'].toString(),
          title: movie['title'] ?? movie['name'] ?? movie['original_name'],
        ));
      });
      isLoading = false;
      notifyListeners();
      // print(movies[3].title);
      return _movies;
    }, onError: (e) {
      print('object');
    });
  }

  Future fetchTv() {
    isLoading = true;
    notifyListeners();
    return get(
            'https://api.themoviedb.org/3/search/tv?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&query=$query&page=$currentTvPage')
        .then((res) {
      Map decoded = json.decode(res.body);
      tvPages = decoded['total_pages'];
      if (res.body == 'be right back' || decoded['results'].isEmpty) {
        isLoading = false;
        notifyListeners();
        return [];
      }
      tv = [];
      decoded['results'].forEach((movie) {
        tv.add(Movie(
          mediaType: 'tv',
          desc: movie['overview'],
          genres: List.generate(movie['genre_ids'].length, (index) {
            return genres.keys.firstWhere((s) {
              return genres[s] == movie['genre_ids'][index];
            }, orElse: () {
              return;
            });
          }),
          img: 'https://image.tmdb.org/t/p/w185/${movie['poster_path']}',
          imgBG: 'https://image.tmdb.org/t/p/w500/${movie['backdrop_path']}',
          rating: movie['vote_average'].toString(),
          id: movie['id'].toString(),
          title: movie['original_name'] ?? movie['name'],
        ));
      });
      isLoading = false;
      notifyListeners();
      return tv;
    }, onError: (e) {});
  }

  Future fetchPeople() {
    isLoading = true;
    notifyListeners();
    return get(
            'https://api.themoviedb.org/3/search/person?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&query=$query&page=$currentPeoplePage')
        .then((res) {
      Map decoded = json.decode(res.body);
      if (res.body == 'be right back' || decoded['results'].isEmpty) {
        isLoading = false;
        notifyListeners();
        return [];
      }
      persons = [];
      peoplePages = decoded['total_pages'];
      decoded['results'].forEach((movie) {
        persons.add(Movie.person(
            mediaType: 'person',
            id: movie['id'].toString(),
            title: movie['name'],
            gender: movie['gender'] == 1 ? 'Female' : 'Male',
            department: movie['known_for_department'],
            img: 'https://image.tmdb.org/t/p/w185/${movie['profile_path']}',
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
                  return genres.keys.firstWhere((s) {
                    return genres[s] == knownFor['genre_ids'][index];
                  }, orElse: () {
                    return;
                  });
                }),
              );
            })));
      });
      isLoading = false;
      notifyListeners();
      return persons;
    }, onError: (e) {});
  }

  String expire;

  String validToken;

  bool success = false;

  bool authLoading = false;
  String username = '';

  String password = '';
  String statusMsg = '';
  Future createSession() {
    authLoading = true;
    notifyListeners();
    return get(
            'https://api.themoviedb.org/3/authentication/token/new?api_key=1ecb35f181c1fbce09a5df4fb806930d')
        .then((res) {
      if (res.statusCode != 200) {
        success = false;
        authLoading = false;
        statusMsg = 'Invalid Token';
        notifyListeners();
        return null;
      }
      final Map decoded = json.decode(res.body);
      final String requestToken = decoded['request_token'];
      print(username);
      print(password);
      print(requestToken);
      return post(
        'https://api.themoviedb.org/3/authentication/token/validate_with_login?api_key=1ecb35f181c1fbce09a5df4fb806930d',
        body: {
          'username': username,
          'password': password,
          'request_token': requestToken,
        },
      ).then((res) {
        if (res.statusCode != 200) {
          success = false;
          authLoading = false;
          statusMsg = 'Invalid Email or Password';
          notifyListeners();
          return null;
        }
        final Map decoded = json.decode(res.body);
        final String authedToken = decoded['request_token'];
        print(authedToken);
        expire = decoded['expires_at'];
        return post(
            'https://api.themoviedb.org/3/authentication/session/new?api_key=1ecb35f181c1fbce09a5df4fb806930d',
            body: {'request_token': authedToken}).then((res) {
          if (res.statusCode != 200) {
            success = false;
            authLoading = false;
            statusMsg = 'Session Failed!';
            notifyListeners();
            return;
          }
          final Map decoded = json.decode(res.body);
          success = decoded['success'];
          print(success);
          validToken = decoded['session_id'];
          print(validToken);
          authLoading = false;
          SharedPreferences.getInstance()
              .then((pref) => pref.setString('validToken', validToken));
          notifyListeners();
        }, onError: (e) {});
      }, onError: (e) {});
    }, onError: (e) {
      success = false;
      authLoading = false;
      statusMsg = e.toString();
      notifyListeners();
    });
  }

  Future deleteSession() {
    return post(
      'https://api.themoviedb.org/3/authentication/session?api_key=1ecb35f181c1fbce09a5df4fb806930d',
      body: {"session_id": validToken},
    ).then(
        (_) => SharedPreferences.getInstance()
            .then((pref) => pref.setString('validToken', null)), onError: (e) {
      print('$e in deleting session');
      SharedPreferences.getInstance()
          .then((pref) => pref.setString('validToken', null));
    });
  }

  static List<Movie> movieWatchlist = [];
  static List<Movie> tvWatchlist = [];
  static List<Movie> favouriteTv = [];
  static List<Movie> favouriteMovies = [];
  Map<String, Map<String, List<Movie>>> listMovie = {
    'favorite': {'movie': favouriteMovies, 'tv': favouriteTv},
    'watchlist': {'movie': movieWatchlist, 'tv': tvWatchlist}
  };
  Future getFavOrWatch(String type, String mediaType) {
    String m = mediaType == 'tv' ? 'tv' : 'movies';
    return get(
            'https://api.themoviedb.org/3/account/{account_id}/$type/$m?api_key=1ecb35f181c1fbce09a5df4fb806930d&session_id=$validToken&language=en-US&sort_by=created_at.asc&page=1')
        .then((s) {
      Map decoded = json.decode(s.body);
      print(validToken);
      print('$m mediaType');
      listMovie[type][mediaType] =
          List.generate(decoded['results'].length, (index) {
        final Map movie = decoded['results'][index];
        return Movie(
          mediaType: mediaType,
          desc: movie['overview'],
          genres: List.generate(movie['genre_ids'].length, (index) {
            return genres.keys.firstWhere((s) {
              return genres[s] == movie['genre_ids'][index];
            }, orElse: () {
              return;
            });
          }),
          img: 'https://image.tmdb.org/t/p/w185/${movie['poster_path']}',
          imgBG: 'https://image.tmdb.org/t/p/w500/${movie['backdrop_path']}',
          rating: movie['vote_average'].toString(),
          id: movie['id'].toString(),
          title: movie['original_name'] ??
              movie['name'] ??
              movie['title'] ??
              movie['original_name'],
        );
      });
      notifyListeners();
      return listMovie[type][mediaType];
    }, onError: (e) {});
  }

  Future toggleFav(int id, String mediaType, bool fav, String type) {
    print(type);
    // mediaType = mediaType == null ? 'movie' : mediaType;
    print(mediaType);
    return post(
      'https://api.themoviedb.org/3/account/{account_id}/$type?api_key=1ecb35f181c1fbce09a5df4fb806930d&session_id=$validToken',
      body:
          json.encode({"media_type": mediaType, "media_id": id, "$type": fav}),
      headers: {"Content-Type": "application/json;charset=utf-8"},
    );
  }

  List<Map<String, dynamic>> customLists = [];

  Future createList(String name, String desc) {
    return post(
      ' https://api.themoviedb.org/3/list?api_key=1ecb35f181c1fbce09a5df4fb806930d&session_id=$validToken',
      body: json.encode({'name': name, 'desc': desc, 'language': 'en'}),
      headers: {"Content-Type": "application/json;charset=utf-8"},
    ).then((s) {}, onError: (e) {});
  }

  Future deleteList(dynamic listID) {
    return delete(
        'https://api.themoviedb.org/3/list/$listID?api_key=1ecb35f181c1fbce09a5df4fb806930d&session_id=$validToken');
  }

  Future editList(String action, listID, {movieID}) async {
    // await Future.forEach()
    return post(
      ' https://api.themoviedb.org/3/list/$listID/$action?api_key=1ecb35f181c1fbce09a5df4fb806930d&session_id=$validToken',
      body: json.encode({'media_id': movieID}),
      headers: {"Content-Type": "application/json;charset=utf-8"},
    );
  }
  
  // Future<List<Movie>> getFavourites() {
  //   return get(
  //           'https://api.themoviedb.org/3/account/{account_id}/favorite/movies?api_key=1ecb35f181c1fbce09a5df4fb806930d&session_id=$validToken&language=en-US&sort_by=created_at.asc&page=1')
  //       .then((s) {
  //     Map decoded = json.decode(s.body);
  //     print(validToken);
  //     // print(decoded);
  //     return List.generate(decoded['results'].length, (index) {
  //       final Map movie = decoded['results'][index];
  //       return Movie(
  //         mediaType: 'movie',
  //         desc: movie['overview'],
  //         genres: List.generate(movie['genre_ids'].length, (index) {
  //           return genres.keys.firstWhere((s) {
  //             return genres[s] == movie['genre_ids'][index];
  //           }, orElse: () {
  //             return;
  //           });
  //         }),
  //         img: 'https://image.tmdb.org/t/p/w185/${movie['poster_path']}',
  //         imgBG: 'https://image.tmdb.org/t/p/w500/${movie['backdrop_path']}',
  //         rating: movie['vote_average'].toString(),
  //         id: movie['id'].toString(),
  //         title: movie['title'],
  //       );
  //     });
  //   }, onError: (e) {});
  // }

  // Future<List<Movie>> getWishlish(String type, String mediaType) {
  //   return get(
  //           'https://api.themoviedb.org/3/account/{account_id}/$type/${mediaType}s?api_key=1ecb35f181c1fbce09a5df4fb806930d&session_id=$validToken&language=en-US&sort_by=created_at.asc&page=1')
  //       .then((s) {
  //     Map decoded = json.decode(s.body);
  //     print(validToken);
  //     // print(decoded);
  //     return List.generate(decoded['results'].length, (index) {
  //       final Map movie = decoded['results'][index];
  //       return Movie(
  //         mediaType: '$mediaType',
  //         desc: movie['overview'],
  //         genres: List.generate(movie['genre_ids'].length, (index) {
  //           return genres.keys.firstWhere((s) {
  //             return genres[s] == movie['genre_ids'][index];
  //           }, orElse: () {
  //             return;
  //           });
  //         }),
  //         img: 'https://image.tmdb.org/t/p/w185/${movie['poster_path']}',
  //         imgBG: 'https://image.tmdb.org/t/p/w500/${movie['backdrop_path']}',
  //         rating: movie['vote_average'].toString(),
  //         id: movie['id'].toString(),
  //         title: movie['title'],
  //       );
  //     });
  //   }, onError: (e) {});
  // }

  // Future toggleWish(int id, String mediaType, bool fav) {
  //   return post(
  //     'https://api.themoviedb.org/3/account/{account_id}/watchlist?api_key=1ecb35f181c1fbce09a5df4fb806930d&session_id=$validToken',
  //     body: json
  //         .encode({"media_type": mediaType, "media_id": id, "watchlist": fav}),
  //     headers: {'Content-Type': 'application/json;charset=utf-8'},
  //   ).then((_) {
  //     notifyListeners();
  //   }, onError: (e) => print('$e in toggling wish'));
  // }
}

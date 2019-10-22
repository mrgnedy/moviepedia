import 'dart:async';
import 'dart:math';
import 'dart:ui' as prefix0;
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:infinite_listview/infinite_listview.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:session3/animated.dart';
import 'package:session3/auth.dart';
import 'package:session3/home.dart';
import 'package:session3/movie_details.dart';
import 'package:session3/movies_card.dart';
import 'package:session3/scoped_mode.dart';
import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'dart:math';
import 'dart:io';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player/youtube_player.dart';
import 'package:youtube_player/controls.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:session3/movie_mode.dart';
import 'package:session3/discover.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)..maxConnectionsPerHost = 300;
  }
}

String token;
void main() {
  // HttpOverrides.global = MyHttpOverrides();
  SharedPreferences.getInstance().then((pref) {
    token = pref.getString('validToken');
    runApp(token == null ? Authenticate() : MyApp());
  }, onError: (e) {
    runApp(Authenticate());
  });

  // runApp(Authenticate());
}

final tmdbAPI = '1ecb35f181c1fbce09a5df4fb806930d';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  int selBtn = 0;

  MainModel model = MainModel();
  @override
  void initState() {
    // TODO: implement initState
    model.validToken = token;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel(
      model: model,
      child: MaterialApp(
        routes: {
          // '/movie': (
          //   BuildContext context,
          // ) =>
          //     MovieDetails()
        },
        theme: ThemeData(
          dialogBackgroundColor: Colors.green,
          textTheme: TextTheme(
              body1: TextStyle(fontSize: 16, color: Colors.white, shadows: [
            BoxShadow(
              color: Colors.white,
              blurRadius: 1,
            )
          ])),
          canvasColor: Colors.blueGrey[300],
          scaffoldBackgroundColor: Color.fromRGBO(58, 66, 86, 1),
          appBarTheme: AppBarTheme(
            color: Color(0xff00B7c1),
          ),
        ),
        home: Scaffold(
            bottomNavigationBar: Container(
              decoration:
                  BoxDecoration(color: Colors.blueGrey[300], boxShadow: [
                BoxShadow(
                    color: Colors.white,
                    blurRadius: 10,
                    spreadRadius: -10,
                    offset: Offset.fromDirection(11, 5))
              ]),
              child: ScopedModelDescendant<MainModel>(
                // rebuildOnChange: true,
                builder: (context, child, model) {
                  return BottomNavigationBar(
                    // selectedFontSize: 12,
                    selectedItemColor: Colors.white,
                    // type: BottomNavigationBarType.shifting,
                    // currentIndex: 1,
                    currentIndex: model.selPage,
                    onTap: (s) {
                      model.setPage(s);
                      setState(() {});
                      print(
                          Theme.of(context).scaffoldBackgroundColor.toString());
                      // setState(() {});
                    },
                    showUnselectedLabels: false,
                    showSelectedLabels: false,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,

                    items: [
                      BottomNavigationBarItem(
                          icon: Icon(Icons.home), title: Text('')),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.search), title: Text('')),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.account_circle), title: Text('')),
                    ],

                    elevation: 1,
                  );
                },
              ),
            ),
            // appBar: AppBar(
            //   elevation: 0,
            //   title: Text('AppBar Here'),
            // ),
            body: Builder(
              builder: (BuildContext context) {
                return Container(child: CrossFadeThree());
              },
            )),
      ),
    );
  }
}

// if (index >= 5) index = index - index ~/ 5 * 5;
//                               if (index < 0) {
//                                 index = -index;
//                                 if (index >= 5) index = index - index ~/ 5 * 5;
//                               }

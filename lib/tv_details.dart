import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:session3/details_header.dart';
import 'package:session3/movie_mode.dart';
import 'package:session3/scoped_mode.dart';

class TvDetails extends StatefulWidget {
  @override
  _TvDetailsState createState() => _TvDetailsState();
}

class _TvDetailsState extends State<TvDetails> {
  List<Map> network;
  String runtime;
  String releaseDate;
  String lastAirDate;
  var nextEpisode;
  int numOfSeasons;
  int numOfEpisodes;
  List recommend;
  List cert;
  List cast;
  String ytID;
  
  

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, i){
        return [
          SliverPersistentHeader(
            delegate: SliverHeader(

            ),
          )
        ];
      },
    );
  }
}

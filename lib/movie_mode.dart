import 'package:flutter/material.dart';

class Movie {
  String mediaType;
  String img;
  String imgBG;
  String title;
  String imdb;
  String rating;
  List genres;
  String desc;
  List torrent;
  String trailer;
  String airDate;
  String id;
  List<Movie> knownFor;
  String department;
  String gender;

  Movie({
    this.id,
    this.img,
    this.imgBG,
    this.title,
    this.imdb,
    this.rating,
    this.genres,
    this.torrent,
    this.desc,
    this.trailer,
    this.airDate,
    this.mediaType = 'movie',
  });

  Movie.person({
    this.id,
    this.department,
    this.knownFor,
    this.img,
    this.imgBG,
    this.gender,
    this.title,
    this.mediaType,
  });
}

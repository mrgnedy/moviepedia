import 'package:flutter/material.dart';

class MovieCard extends StatelessWidget {
  final String img;
  final String title;
  final String cardTag;
  final String titleTag;
  MovieCard({this.img, this.title, this.cardTag, this.titleTag});

  Widget _movieTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 2, 10, 0),
      child: Hero(
        tag: '$titleTag',
        child: Text(
          '${title}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _movieCard(BuildContext context) {
    var orient = MediaQuery.of(context).orientation;
    return Container(
      height: orient == Orientation.landscape
          ? MediaQuery.of(context).size.height / 0.855
          : MediaQuery.of(context).size.height / 2.8,
      width: orient == Orientation.landscape
          ? MediaQuery.of(context).size.width / 2.2
          : MediaQuery.of(context).size.width / 2,
      //constraints: BoxConstraints.expand(width: 197, height: 175),
      child: Hero(
        tag: '$cardTag',
        child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: img == null || img.isEmpty || img.contains('null')
                ? Image.asset('assets/cat.png')
                : Image.network(
                    img,
                    fit: BoxFit.cover,

                    alignment: Alignment.center
                  )),
      ),
      decoration: BoxDecoration(
        // border: BoxBorder(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 4, spreadRadius: 0, color: Colors.blueGrey),
        ],
        // image: DecorationImage(
        //   fit: BoxFit.cover,
        //   image: NetworkImage(
        //     '${img}',
        //   ),
        // ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Container(
        height: MediaQuery.of(context).orientation == Orientation.landscape
            ? MediaQuery.of(context).size.height / 0.8
            : MediaQuery.of(context).size.height / 2.5,
        width: MediaQuery.of(context).orientation == Orientation.landscape
            ? MediaQuery.of(context).size.width / 2.2
            : MediaQuery.of(context).size.width / 2,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(blurRadius: 2, color: Colors.white),
            ],
            color: Theme.of(context).appBarTheme.color,
            // border: Border.all(
            //   // color: Colors.white,
            //   width: 0,
            //   style: BorderStyle.solid,
            // ),
          ),
          child: Column(
            children: <Widget>[
              _movieCard(context),
              SizedBox(
                height: 2,
              ),
              _movieTitle(),
            ],
          ),
        ),
      ),
    );
  }
}

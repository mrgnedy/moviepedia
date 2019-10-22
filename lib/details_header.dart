import 'package:flutter/material.dart';

//Color(0xff59b2b5)
class SliverHeader extends SliverPersistentHeaderDelegate {
  final _stackColorTween =
      ColorTween(begin: Colors.transparent, end: Color(0xff00B7c1));
  final _avatarTween = SizeTween(
    begin: Size(100, 150),
    end: Size(50, 50),
  );
  final _avatarAlign = AlignmentTween(
      begin: Alignment.centerLeft,
      end: AlignmentGeometry.lerp(Alignment.center, Alignment.centerLeft, 0.5));
  final _avatarMargin = EdgeInsetsTween(
      begin: EdgeInsets.fromLTRB(10, 0, 0, 0),
      end: EdgeInsets.fromLTRB(10, 35, 0, 0));

  final _userPrefAlign =
      AlignmentTween(begin: Alignment.bottomRight, end: Alignment.bottomRight);
  final _titleMargin = EdgeInsetsTween(
      begin: EdgeInsets.fromLTRB(120, 0, 0, 0),
      end: EdgeInsets.fromLTRB(70, 45, 0, 0));
  final _titleAlign =
      AlignmentTween(begin: Alignment.center, end: Alignment.centerLeft);
  final _titleColor = ColorTween(begin: Colors.white, end: Colors.white);
  final _genreColor =
      ColorTween(begin: Colors.white60, end: Colors.transparent);
  final _shadowColor = ColorTween(begin: Color(0xff59b2b5), end: Colors.white);
  final Widget avatar;
  final String title;
  Widget bgImg;
  final String img;
  final List genres;
  final String rate;
  final String cert;
  final String runtime;
  final String titleTag;
  final Widget userControls;
  SliverHeader(
      {this.avatar,
      this.title,
      this.img,
      this.genres,
      this.bgImg,
      this.rate,
      this.cert,
      this.runtime,
      this.titleTag,
      this.userControls}) {
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
    // double opacity = _opacity.lerp(size);
    Alignment prefAlign = _userPrefAlign.lerp(size);
    Color titleColor = _titleColor.lerp(size);
    Color genreColor = _genreColor.lerp(size);
    Color shadowColor = _shadowColor.lerp(size);
    Color stackColor = _stackColorTween.lerp(size);
    return Container(
      color: stackColor,
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
              height: (maxExtent - shrinkOffset) / 3 + minExtent,
              // width: 470,
              // alignment: Alignment.center,

              child: Opacity(opacity: 1 - size, child: bgImg),
            ),
          ),
          Positioned(
            top: (maxExtent - shrinkOffset) / 2,
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
          Positioned(
            top: (maxExtent - shrinkOffset) / 1.15,
            child: Padding(
              padding: avatarMargin,
              child: Align(
                  alignment: avatarAlign,
                  child: Opacity(
                    opacity: 1 - size,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 4, top: 11),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(2),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.white,
                                        blurRadius: 2,
                                        spreadRadius: 0,
                                        offset: Offset.zero)
                                  ],
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.white),
                                ),
                                child: Text(
                                  cert,
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).appBarTheme.color),
                                ),
                              ),
                              Container(
                                child: Text(' -- ${runtime}'),
                              )
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Image.network(
                              'http://icons.iconarchive.com/icons/uiconstock/socialmedia/256/IMDb-icon.png',
                              scale: 5,
                            ),
                            Text(': $rate'),
                          ],
                        ),
                      ],
                    ),
                  )),
            ),
          ),
          Positioned(
            top: (maxExtent - shrinkOffset) / 1.6,
            child: Padding(
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
          ),
          Positioned(
            top: (maxExtent - shrinkOffset) / 1.6 + 30,
            child: Padding(
              padding: titlePadding,
              child: Align(
                alignment: titleAlign,
                child: Row(
                    children: List.generate(genres.length, (index) {
                  return Text(
                    '${genres[index]},',
                    style: TextStyle(color: genreColor),
                  );
                })),
              ),
            ),
          ),
          Opacity(
            opacity: 1 - size,
            child: Align(alignment: prefAlign, child: userControls),
          )
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(SliverHeader oldDelegate) {
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

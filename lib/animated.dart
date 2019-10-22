import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:session3/auth.dart';
import 'package:session3/discover.dart';
import 'package:session3/home.dart';
import 'package:session3/scoped_mode.dart';
import 'package:session3/user_stuff.dart';

class CrossFadeThree extends StatelessWidget {
  // @override
  Widget anime(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        CrossFadeState state1 = model.selPage == 0
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond;
        CrossFadeState state2 = model.selPage == 1
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond;
        Duration duration1 = state1 == CrossFadeState.showSecond
            ? Duration(seconds: 1)
            : Duration(seconds: 0);
        return AnimatedCrossFade(
          // sizeCurve: Curves.bounceIn,
          firstCurve: Curves.easeIn,
          secondCurve: Curves.easeInBack,
          duration: Duration(seconds: 0),
          crossFadeState: state1,
          firstChild: Home(),
          secondChild: AnimatedCrossFade(
            // sizeCurve: Curves.bounceIn,
            firstCurve: Curves.easeIn,
            secondCurve: Curves.easeInBack,
            duration: Duration(seconds: 0),
            crossFadeState: state2,
            firstChild: DiscoverAppBar(),
            secondChild: Container(
              height: 200,
              width: 200,
              child: Card(
                color: Colors.teal,
              ),
            ),
          ),
        );
      },
    );
  }

  int selPage;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ScopedModelDescendant<MainModel>(
      builder: (contex, child, model) {
        selPage = model.selPage;
        return PageView(
          // pageSnapping: false,
          onPageChanged: (p) {
            // model.setPage(p);
          },
          controller: model.pageController,
          physics: NeverScrollableScrollPhysics(),

          children: <Widget>[
            Home(),
            DiscoverAppBar(),

            // height: 500,
            UserStuff(),
          ],
        );
      },
    );
  }
}

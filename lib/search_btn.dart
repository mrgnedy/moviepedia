import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:session3/scoped_mode.dart';
import 'package:scoped_model/scoped_model.dart';

class SearchBtn extends StatelessWidget {
  final Function callback;
  final List ctrls;
  final List cast;
  final MaskedTextController dateGte;
  final TextEditingController dateLte;
  final bool isAdult;
  final List<String> gens;
  final TextEditingController search;
  SearchBtn(
      {this.ctrls,
      this.dateGte,
      this.dateLte,
      this.isAdult,
      this.gens,
      this.search,
      this.callback,
      this.cast});
  String castQuery = '&with_cast=';
  getCast() {
    cast.forEach((person) => castQuery += '${person.id.toString()},');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 200,
      // alignment: Alignment.center,
      child: ScopedModelDescendant<MainModel>(
        builder: (context, child, model) {
          return RaisedButton(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.search,
                  color: Theme.of(context).appBarTheme.color,
                ),
                Text(
                  'Search',
                  style: TextStyle(
                      color: Theme.of(context).appBarTheme.color,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            elevation: 2,
            onPressed: () => [
              getCast(),
              model.makeQuery(castQuery, dateGte, dateLte, isAdult.toString(),
                  gens, search),
              // model.fetch();
              callback(),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );
        },
      ),
    );
  }
}

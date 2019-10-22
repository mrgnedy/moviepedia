import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'movie_mode.dart';
import 'dart:convert';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:http/http.dart';
import 'package:session3/search_btn.dart';
// import 'package:session3/main.dart';

class DiscoverTab extends StatefulWidget {
  final Function callback;
  DiscoverTab({this.callback});
  @override
  _DiscoverTabState createState() => _DiscoverTabState();
}

const List genres = [
  {'id': 28, 'name': 'Action'},
  {'id': 12, 'name': 'Adventure'},
  {'id': 16, 'name': 'Animation'},
  {'id': 35, 'name': 'Comedy'},
  {'id': 80, 'name': 'Crime'},
  {'id': 99, 'name': 'Documentary'},
  {'id': 18, 'name': 'Drama'},
  {'id': 10751, 'name': 'Family'},
  {'id': 14, 'name': 'Fantasy'},
  {'id': 36, 'name': 'History'},
  {'id': 27, 'name': 'Horror'},
  {'id': 10402, 'name': 'Music'},
  {'id': 9648, 'name': 'Mystery'},
  {'id': 10749, 'name': 'Romance'},
  {'id': 878, 'name': 'Sci-Fi'},
  {'id': 10770, 'name': 'TV-Movie'},
  {'id': 53, 'name': 'Thriller'},
  {'id': 10752, 'name': 'War'},
  {'id': 37, 'name': 'Western'},
];
List<String> castIDs = [];
List<Movie> addedCast = [];

List<TextEditingController> ctrls = [
  TextEditingController(text: ''),
];
List<String> genreList = [null];
MaskedTextController dateGte = MaskedTextController(mask: '0000-00-00');
TextEditingController dateLte = TextEditingController();
TextEditingController actorController = TextEditingController(text: '');
int txtFieldNum = 1;
int numOfGenres = 1;
int indexesToRemove;
int gindexestoremove;

class _DiscoverTabState extends State<DiscoverTab>
    with AutomaticKeepAliveClientMixin {
  _buildTextField(String hint,
      {TextEditingController txtCtrlr, TextInputType inputType}) {
    // ctrls[0] = TextEditingController();
    return Container(
      width: MediaQuery.of(context).size.width / 2.3,
      // height: 10,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.white70, blurRadius: 2),
        ],
        borderRadius: BorderRadius.circular(30),
        color: Colors.blueGrey[300],
      ),
      child: TextField(
        style: TextStyle(color: Colors.white),
        keyboardType: inputType,
        controller: txtCtrlr,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white54, fontSize: 14),
          contentPadding: EdgeInsets.all(10),
          border: InputBorder.none,
        ),
      ),
    );
  }

  List<Widget> _actorFieldsV2() {
    return [
      Container(
        width: MediaQuery.of(context).size.width / 2.3,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.white70, blurRadius: 2),
          ],
          borderRadius: BorderRadius.circular(30),
          color: Colors.blueGrey[300],
        ),
        child: TypeAheadField(
          onSuggestionSelected: (Movie suggestion) {
            if (suggestion.id != null) {
              // castQuery += '${suggestion.id.toString()},';
              if (addedCast.singleWhere(
                    (movie) => movie.id == suggestion.id,
                    orElse: () => null,
                  ) ==
                  null) {
                addedCast.add(suggestion);
                actorController.text = '';
              }
              addedCast.forEach((f) => print(f.id));
              setState(() {});
            }
          },
          suggestionsCallback: (p) async {
            final people = getSuggestedCast(p);

            return await people;
          },
          hideOnError: true,
          getImmediateSuggestions: true,
          hideOnEmpty: true,
          keepSuggestionsOnLoading: true,
          debounceDuration: Duration.zero,
          itemBuilder: (context, Movie suggestion) {
            // Movie movie = suggestion;
            return ListTile(
              leading: SizedBox.fromSize(
                  size: Size.square(50), child: Image.network(suggestion.img)),
              title: Container(
                  child: Text(
                suggestion.title,
                style: TextStyle(color: Colors.white),
              )),
              subtitle: Text(
                suggestion.department ?? ' ',
                style: TextStyle(color: Colors.grey[400]),
              ),
            );
          },
          suggestionsBoxDecoration: SuggestionsBoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          textFieldConfiguration: TextFieldConfiguration(
            controller: actorController,
            // focusNode: FocusNode(),
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10),
              border: InputBorder.none,
              hintText: 'Actor',
              hintStyle: TextStyle(color: Colors.white54),
            ),
          ),
        ),
      )
    ]..addAll(List.generate(addedCast.length, (index) {
        return Card(
          margin: EdgeInsets.zero,
          // color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                // alignment: Alignment.topLeft,
                // padding: EdgeInsets.zero,
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    image: DecorationImage(
                        image: NetworkImage(
                          addedCast[index].img,
                        ),
                        fit: BoxFit.cover)),
                height: 30,
                width: 30,
                // child: Image.network(addedCast[index].img, fit: BoxFit.cover,),
              ),
              Container(
                  width: 100,
                  child: Text(
                    addedCast[index].title,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(color: Colors.black, fontSize: 14),
                  )),
              InkWell(
                onTap: () {
                  addedCast.removeAt(index);
                  setState(() {});
                },
                child: Icon(Icons.close),
              ),
            ],
          ),
        );
      }));
  }

  // String castQuery = '&with_cast=';
  List<Movie> people = [];
  Future<List<Movie>> getSuggestedCast(String p) {
    List<Movie> suggestedPeople = [];
    if (p.isEmpty) return Future.sync(() => []);
    if (people.isNotEmpty) {
      suggestedPeople = people
          .where(
            (Movie person) =>
                person.title.toLowerCase().contains(p.toLowerCase()),
          )
          .toList();
    }
    if (suggestedPeople.isNotEmpty) return Future.sync(() => suggestedPeople);
    return get(
            'https://api.themoviedb.org/3/search/person?api_key=1ecb35f181c1fbce09a5df4fb806930d&language=en-US&query=$p&page=1&include_adult=false')
        .then((res) {
      people = [];
      List<Movie> suggestedPeople = [];
      final Map decoded = json.decode(res.body);
      suggestedPeople = List.generate(decoded['results'].length, (index) {
        final movie = decoded['results'][index];
        return Movie.person(
          // mediaType: 'person',
          id: movie['id'].toString(),
          title: movie['name'],
          gender: movie['gender'] == 1 ? 'Female' : 'Male',
          department: movie['known_for_department'],
          img: movie['profile_path'] == null
              ? movie['gender'] == 1
                  ? 'https://cdn2.iconfinder.com/data/icons/person-gender-hairstyle-clothes-variations/48/Female-Side-comb-O-neck-512.png'
                  : 'http://www.tactic90.com/images/Members/Avatar_tac_2016_2.png'
              : 'https://image.tmdb.org/t/p/w185/${movie['profile_path']}',
        );
      });
      people = suggestedPeople;
      return suggestedPeople;
    }, onError: (e) {});
  }

  // _buildActorField(TextEditingController txtController, int index) {
  //   return Container(
  //     width: MediaQuery.of(context).size.width / 2.3,
  //     height: 40,
  //     alignment: Alignment.center,
  //     decoration: BoxDecoration(
  //       boxShadow: [
  //         BoxShadow(color: Colors.white70, blurRadius: 2),
  //       ],
  //       borderRadius: BorderRadius.circular(30),
  //       color: Colors.blueGrey[300],
  //     ),
  //     child: TypeAheadField(
  //       onSuggestionSelected: (Movie suggestion) {
  //         if (suggestion.id != null) {
  //           // castQuery += '${suggestion.id.toString()},';
  //           if (index >= castIDs.length)
  //             castIDs.add(suggestion.id);
  //           else
  //             castIDs[index] = suggestion.id;
  //         }
  //         txtController.text = suggestion.title;
  //         print(castIDs);
  //       },
  //       suggestionsCallback: (p) async {
  //         final people = getSuggestedCast(p);
  //         return await people;
  //       },
  //       hideOnError: true,
  //       getImmediateSuggestions: true,
  //       hideOnEmpty: true,
  //       keepSuggestionsOnLoading: true,
  //       debounceDuration: Duration.zero,
  //       itemBuilder: (context, Movie suggestion) {
  //         // Movie movie = suggestion;
  //         return ListTile(
  //           leading: SizedBox.fromSize(
  //               size: Size.square(50), child: Image.network(suggestion.img)),
  //           title: Container(
  //               child: Text(
  //             suggestion.title,
  //             style: TextStyle(color: Colors.white),
  //           )),
  //           subtitle: Text(
  //             suggestion.department,
  //             style: TextStyle(color: Colors.grey[400]),
  //           ),
  //         );
  //       },
  //       suggestionsBoxDecoration: SuggestionsBoxDecoration(
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       textFieldConfiguration: TextFieldConfiguration(
  //         controller: txtController,
  //         // focusNode: FocusNode(),
  //         style: TextStyle(
  //             color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
  //         decoration: InputDecoration(
  //           contentPadding: EdgeInsets.all(10),
  //           border: InputBorder.none,
  //           hintText: 'Actor',
  //           hintStyle: TextStyle(color: Colors.white54),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  bool _isAdult = false;
  // Widget _buildActor(int index) {
  //   return Stack(
  //     children: <Widget>[
  //       Positioned(
  //           top: 3,
  //           child: Container(
  //             // width: 200,
  //             child: _buildActorField(ctrls[index], index),
  //           )),
  //       Positioned(
  //         top: 9,
  //         left: MediaQuery.of(context).size.width / 2.9,
  //         child: GestureDetector(
  //           onTap: () {
  //             indexesToRemove = index;
  //             print(index);
  //             setState(() {});
  //           },
  //           child: Icon(Icons.close),
  //         ),
  //       )
  //     ],
  //   );
  // }

  Widget _dateTextField(TextEditingController txtCtrl, String hint) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 3),
      child: Stack(children: [
        _buildTextField(hint,
            txtCtrlr: txtCtrl, inputType: TextInputType.number),
        Container(
          padding: EdgeInsets.only(right: 5),
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () {
              // _getDate().then((DateTime val) {
              //   if (val != null)
              //     dateLte.text = val.toString().substring(0, 10);
              // });
              _getDate2(txtCtrl);
            },
            icon: Icon(Icons.date_range),
            color: Colors.white,
          ),
        ),
      ]),
    );
  }

  // List<Widget> _actorFields() {
  //   List<Widget> x;
  //   x = List.generate(txtFieldNum, (index) {
  //     return _buildActor(index);
  //   });
  //   x.add(
  //     IconButton(
  //       alignment: Alignment.centerLeft,
  //       icon: Icon(Icons.add),

  //       // color: Theme.of(context).appBarTheme.color,
  //       // elevation: 0,
  //       onPressed: () {
  //         // List oldCtrls = List.from(ctrls);
  //         txtFieldNum++;
  //         // ctrls = List.generate(txtFieldNum, (index) {
  //         //   return TextEditingController(
  //         //       text: index >= oldCtrls.length ? '' : oldCtrls[index].text);
  //         // });

  //         ctrls.add(TextEditingController());
  //         if (!mounted) return;
  //         setState(() {});
  //       },
  //     ),
  //   );

  //   if (indexesToRemove != null) {
  //     x.removeAt(indexesToRemove);
  //     ctrls.removeAt(indexesToRemove);
  //     if (indexesToRemove < castIDs.length) castIDs.removeAt(indexesToRemove);
  //     indexesToRemove = null;
  //     txtFieldNum--;
  //     // ctrls = List.generate(txtFieldNum, (index) {
  //     //   return TextEditingController(text: ctrls[index].text);
  //     // });
  //     setState(() {});
  //   }
  //   if (x.length % 2 != 0) x.add(Container());
  //   return x;
  // }

  // Future<DateTime> _getDate() async {
  //   return await showDatePicker(
  //       context: context,
  //       firstDate: DateTime(1900),
  //       lastDate: DateTime(DateTime.now().year + 2),
  //       initialDate: DateTime.now(),
  //       initialDatePickerMode: DatePickerMode.year);
  // }

  _getDate2(TextEditingController maskedTextController) {
    final curent = DateTime.tryParse(
      maskedTextController.text,
    );
    DatePicker.showDatePicker(
      context,
      showTitleActions: true,
      currentTime: curent ?? DateTime.now(),
      onConfirm: (date) =>
          maskedTextController.text = date.toString().substring(0, 10),
      minTime: DateTime(1900),
      maxTime: DateTime(DateTime.now().year + 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container(
      child: ListView(
        addAutomaticKeepAlives: true,
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          GridView.extent(
            addAutomaticKeepAlives: true,
            primary: false,
            physics: NeverScrollableScrollPhysics(),
            maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 4,
            // crossAxisCount: 2,
            shrinkWrap: true,
            children: []
              ..addAll(genreWidgetList())
              ..addAll(
                [
                  _dateTextField(dateGte, 'From: YYYY-MM-DD'),
                  _dateTextField(dateLte, 'To: YYYY-MM-DD'),
                ]..addAll(_actorFieldsV2()),
              ),
          ),
          Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 10),
                width: MediaQuery.of(context).size.width / 2,
                child: CheckboxListTile(
                  value: _isAdult,
                  title: Text(
                    'Include Adult',
                    style: TextStyle(color: Colors.white),
                  ),
                  onChanged: (s) {
                    setState(() {
                      _isAdult = s;
                    });
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2,
                child: CheckboxListTile(
                  value: false,
                  title: Text(
                    'Downloadable Only',
                    style: TextStyle(color: Colors.white),
                  ),
                  onChanged: (s) {},
                ),
              ),
            ],
          ),
          Center(
            child: SearchBtn(
              callback: widget.callback,
              search: TextEditingController(),
              ctrls: ctrls,
              cast: addedCast,
              dateGte: dateGte,
              dateLte: dateLte,
              gens: genreList,
              isAdult: _isAdult,
            ),
          )
        ],
        primary: true,
      ),
    );
  }

  String genre = 'Drama';
  Widget genreDropList(int index) {
    return Container(
      alignment: Alignment.center,
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        backgroundBlendMode: BlendMode.darken,
        gradient: LinearGradient(colors: [Colors.blueGrey[300], Colors.teal]),
        boxShadow: [BoxShadow(color: Colors.white, blurRadius: 1)],
      ),
      child: DropdownButton(
        style: TextStyle(color: Colors.white),
        items: List.generate(
          genres.length,
          (index) {
            return DropdownMenuItem(
              child: Container(
                child: Text(
                  genres[index]['name'],
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              value: genres[index]['name'],
            );
          },
        ),
        onChanged: (val) {
          // setState(() {});
          genre = val;
          genreList[index] = genre;
          if (index >= genreList.length - 1 && genreList.length < 4) {
            genreList.add(null);
            numOfGenres++;
          }
          // setState(() {});
          setState(() {});
        },
        value: genreList[index],
      ),
    );
  }

  List<Widget> genreWidgetList() {
    List<Widget> x;
    x = List.generate(numOfGenres, (index) {
      return Container(
          width: 100,
          height: 200,
          // color: Colors.white,
          child: InkWell(
            child: genreDropList(index),
            onLongPress: () {
              // setState(() {});
              gindexestoremove = index;
              print(index);
              //  Future.delayed(Duration(microseconds: 20), () {
              //     setState(() {});});
              setState(() {});
            },
          ));
    });
    if (x.isEmpty) {
      x.add(
        IconButton(
          alignment: Alignment.centerLeft,
          icon: Icon(Icons.add),
          onPressed: () {
            numOfGenres++;
            // genreList = List.generate(numOfGenres, (index) {
            //   return numOfGenres >= genreList.length ? '' : genreList[index];
            // });
            genreList.add(null);
            if (!mounted) return;
            setState(() {});
          },
        ),
      );
      // setState(() {

      // });

    }
    if (gindexestoremove != null) {
      x.removeAt(gindexestoremove);
      genreList.removeAt(gindexestoremove);
      gindexestoremove = null;
      numOfGenres--;
      // genreList = List.generate(numOfGenres, (index) {
      //   return genreList[index];
      // });
      Future.delayed(Duration(microseconds: 1), () {
        setState(() {});
      });
    }
    // setState(() {

    //   });
    if (x.length % 2 != 0) x.add(Container());
    return x;
  }

  @override
  bool get wantKeepAlive => true;
}

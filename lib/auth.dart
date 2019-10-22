import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:session3/main.dart';
import 'package:session3/scoped_mode.dart';
import 'package:url_launcher/url_launcher.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  GlobalKey<FormState> key1 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    MainModel model = MainModel();
    return ScopedModel<MainModel>(
      model: model,
      child: MaterialApp(
        home: Scaffold(
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                      'assets/groot.jpg',
                    ))),
            child: Stack(
              children: <Widget>[
                Opacity(
                  opacity: 0.75,
                  child: Form(
                    key: key1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Card(
                            child: Container(
                              height: 60,
                              padding: EdgeInsets.fromLTRB(8, 0, 8, 5),
                              child: TextFormField(
                                validator: (s) {
                                  if (s == null || s.isEmpty)
                                    return 'Please enter a valid username';
                                },
                                enabled: !false,
                                onSaved: (s) {
                                  model.username = s;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Username',
                                ),
                              ),
                            ),
                          ),
                          Card(
                            child: Container(
                              height: 60,
                              padding: EdgeInsets.fromLTRB(8, 0, 8, 5),
                              child: TextFormField(
                                validator: (s) {
                                  if (s == null || s.length < 4)
                                    return 'Please enter a valid password';
                                },
                                onSaved: (s) {
                                  model.password = s;
                                },
                                enabled: !false,
                                decoration:
                                    InputDecoration(labelText: 'Password'),
                                obscureText: true,
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.all(10),
                              child: ScopedModelDescendant<MainModel>(
                                builder: (context, child, model) {
                                  return Builder(
                                    builder: (context) {
                                      return model.authLoading
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : RaisedButton(
                                              color: Colors.blue,
                                              child: Text('Login'),
                                              textColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              onPressed: () async {
                                                if (key1.currentState
                                                    .validate()) {
                                                  key1.currentState.save();
                                                  retryLogin(model, context);
                                                }
                                                return;
                                              },
                                            );
                                    },
                                  );
                                },
                              )),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  final url =
                                      'https://www.themoviedb.org/account/reset-password';
                                  if (await canLaunch(url))
                                    launch(url);
                                  else
                                    throw 'error';
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                      color: Colors.white,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                              VerticalDivider(
                                color: Colors.white,
                                width: 11,
                              ),
                              InkWell(
                                onTap: () async {
                                  final url =
                                      'https://www.themoviedb.org/account/signup';
                                  if (await canLaunch(url))
                                    launch(url);
                                  else
                                    throw 'error';
                                },
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                      color: Colors.white,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Align(
                    alignment: FractionalOffset.lerp(FractionalOffset.topRight,
                        FractionalOffset.center, 0.07),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      color: Colors.white,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> dialog(MainModel model, BuildContext context) async {
    if (model.success) {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => MyApp()));
      return Future.sync(() => false);
    }
    return await showDialog(
        context: context,
        builder: (context) {
          model.authLoading = false;
          return AlertDialog(
            title: Row(
              children: <Widget>[
                Icon(Icons.warning),
                Text('Error'),
              ],
            ),
            content: Text(model.statusMsg),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  // setState(() {});
                },
                child: Text('Retry'),
              )
            ],
          );
        });
  }

  retryLogin(MainModel model, BuildContext context) {
    model.createSession().then((_) => dialog(model, context)
        .then((retry) => retry ? retryLogin(model, context) : null));
  }
}

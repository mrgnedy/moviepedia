import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:session3/movie_details.dart';
import 'package:session3/scoped_mode.dart';
import 'package:session3/user_list.dart';

import 'auth.dart';

class UserStuff extends StatefulWidget {
  @override
  _UserStuffState createState() => _UserStuffState();
}

class _UserStuffState extends State<UserStuff> {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: () => model.deleteSession().then((_) =>
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => Authenticate()))),
              ),
            ],
          ),
          body: ListView(
            children: <Widget>[
              Column(
                children: <Widget>[
                  _buildTypeExpTile('Favorite'),
                  Divider(
                    color: Colors.black26,
                  ),
                  _buildTypeExpTile('Watchlist'),
                  ExpansionTile(
                    children: List.generate(model.customLists.length, (index) {
                      final currentList = model.customLists[index];
                      return ListTile(
                        onTap: () {
                          if(currentList['list']!=null)
                          Navigator.of(context).push(PageRouteBuilder(
                              pageBuilder: (context, anim, secAnim) => UserList(
                                  currentList['list'],
                                  '',
                                  Icons.add)));
                        },
                        title: Text(currentList['name']),
                      );
                    })
                      ..add(
                        ListTile(
                          onTap: () async {
                            bool update =false;
                            update = await addList(model);
                            if (update && mounted) setState(() {});
                          },
                          leading: Icon(Icons.add),
                          title: Text('Create List'),
                        ),
                      ),
                    leading: Icon(
                      FontAwesomeIcons.list,
                      color: Colors.white70,
                    ),
                    title: Text(
                      'Custom Lists',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future addList(MainModel model) {
    return showDialog(
      context: context,
      builder: (context) {
        String inputName;
        String inputDesc;
        IconData inputIcon = Icons.list;
        return AlertDialog(
          title: Text('Create a new list'),
          content: Column(
            children: <Widget>[
              Container(
                child: TextField(
                  onChanged: (s) {
                    inputName = s;
                  },
                  decoration: InputDecoration(hintText: 'Name'),
                ),
              ),
              Container(
                child: TextField(
                  onChanged: (s) {
                    inputDesc = s;
                  },
                  decoration: InputDecoration(hintText: 'Description'),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel'),
            ),
            FlatButton(
              onPressed: () {
                model.customLists.add(
                    {'name': inputName, 'desc': inputDesc, 'icon': inputIcon});
                model.createList(inputName, inputDesc);
                Navigator.pop(context, true);
              },
              child: Text('Add'),
            )
          ],
        );
      },
      
    );
    
  }

  Widget _buildTypeExpTile(String type) {
    final IconData icon = type == 'Favorite'
        ? FontAwesomeIcons.solidHeart
        : FontAwesomeIcons.solidBookmark;
    return ExpansionTile(
      children: <Widget>[
        _buildTile(type.toLowerCase(), 'movie'),
        _buildTile(type.toLowerCase(), 'tv'),
      ],
      leading: Icon(icon, color: Colors.white70),
      title: Text(type, style: TextStyle(color: Colors.white70)),
    );
  }

  Widget _buildTile(String type, String mediaType) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        final String partTwo = mediaType == 'movie' ? 'Movies' : 'TV-Shows';
        final String title =
            type == 'favorite' ? 'Favorite $partTwo' : '$partTwo Watchlist';
        final IconData icon =
            mediaType == 'movie' ? FontAwesomeIcons.film : FontAwesomeIcons.tv;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            onTap: () async {
              print(model.listMovie[type][mediaType].length);
              if (model.listMovie[type][mediaType].isEmpty)
                model.listMovie[type][mediaType] =
                    await model.getFavOrWatch(type, mediaType);
              Navigator.of(context).push(
                PageRouteBuilder(
                  transitionDuration: Duration(milliseconds: 500),
                  pageBuilder: (context, anim, secAnim) =>
                      UserList(model.listMovie[type][mediaType], title, icon),
                ),
              );
            },
            leading: Icon(
              icon,
              color: Colors.white30,
            ),
            title: Text(
              partTwo,
              style: TextStyle(fontSize: 14, color: Colors.white54),
            ),
          ),
        );
      },
    );
  }
}

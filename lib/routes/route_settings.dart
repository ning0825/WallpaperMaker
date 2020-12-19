import 'package:flutter/material.dart';
import 'package:wallpaper_maker/cus_widget.dart';
import 'package:wallpaper_maker/routes/route_feedback.dart';
import 'package:wallpaper_maker/routes/route_font_mgr.dart';

class SettingsRoute extends StatefulWidget {
  @override
  _SettingsRouteState createState() => _SettingsRouteState();
}

class _SettingsRouteState extends State<SettingsRoute> {
  Widget itemWidget(String name, VoidCallback callback) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.only(left: 20),
        alignment: Alignment.centerLeft,
        child: Text(name),
      ),
      onTap: callback,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollViewWithAppBar(
          title: 'Setting',
          onBackPressed: () => Navigator.pop(context),
          children: [
            SliverFixedExtentList(
              itemExtent: 60.0,
              delegate: SliverChildListDelegate([
                itemWidget('General', () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FontMgrRoute(),
                      ));
                }),
                itemWidget(
                    'Feedback',
                    () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FeedbackRoute(),
                        ))),
                itemWidget(
                    'About',
                    () => showAboutDialog(
                        context: context,
                        applicationLegalese: 'All rights reserved',
                        applicationVersion: '1.0 preview')),
              ]),
            )
          ],
        ),
      ),
    );
  }
}

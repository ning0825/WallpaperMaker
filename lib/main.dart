import 'package:flutter/material.dart';
import 'package:wallpaper_maker/inherit/inherited_config.dart';
import 'package:wallpaper_maker/routes/route_library.dart';

void main() => runApp(
      ConfigWidget(
        child: MaterialApp(
          home: LibraryRoute(),
        ),
      ),
    );

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:leancloud_feedback/leancloud_feedback.dart';

import './inherited_config.dart';
import './routes/route_library.dart';

void main() {
  initLCFeedback(
      appID: 'Cxnu5I4C5XslUk8gONphiicP-gzGzoHsz',
      appKey: 'YeyF6FxUjRx2Wp4f5maUfsEf',
      serverUrl: 'https://cxnu5i4c.lc-cn-n1-shared.com/1.1');

  runApp(
    ConfigWidget(
      child: MaterialApp(
        home: LibraryRoute(),
      ),
    ),
  );
}

// Copyright (c) 2016, Conchylicultor. All rights reserved. Use of this source code
// is governed by a MIT license that can be found in the LICENSE file.

import 'package:my_imdb_stats/main_app.dart';
import 'package:polymer/polymer.dart';
import 'src/statistics.dart';
import 'dart:async';

/// [MainApp] used!
main() async {
  await initPolymer();

  runZoned(() {
    launchStatistics(); // Get the IMDb statistics
  }, onError: (error, stackTrace) {
    print('Uncaught error in statistic.dart: $error');
    print(stackTrace);
  });

}

library chapturn_sources;

import 'package:chapturn_sources/src/impls/impls.dart';
import 'package:chapturn_sources/src/utils.dart';
import 'package:dio/dio.dart';

export './src/impls/impls.dart';
export './src/interfaces/interfaces.dart';
export './src/models/models.dart';
export './src/utils.dart';

const sources = [
  CrawlerFactory(ScribbleHub.constMeta, ScribbleHub.make, ScribbleHub.makeWith),
  CrawlerFactory(FanFiction.constMeta, FanFiction.make, FanFiction.makeWith),
];

CrawlerFactory? getCrawlerFactoryWithUrl(String url, [Dio? client]) {
  for (final tuple in sources) {
    if (tuple.meta().of(url)) {
      return tuple;
    }
  }
}

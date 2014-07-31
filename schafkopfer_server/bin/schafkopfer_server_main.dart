import 'dart:io';

import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';
import 'package:route/server.dart';

import 'package:schafkopfer_api/schafkopfer_urls.dart' as urls;
import 'package:schafkopfer_server/config.dart';
import 'package:schafkopfer_server/schafkopfer_server.dart';

void main(List<String> args) {
  
  Logger.root.onRecord.listen(new LogPrintHandler());

  HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, new Config().serverPort).then((HttpServer server) {
    var router = new Router(server)
          ..serve(urls.root, method: 'GET').listen(root)
          ..serve(urls.newMatch, method: 'POST').listen(newMatch)
          ..serve(urls.findMatch, method: 'GET').listen(findMatch)
          ..serve(urls.newGame, method: 'POST').listen(newGame)
          ..serve(urls.listGames, method: 'GET').listen(listGames)
          ..serve(urls.findGame, method: 'GET').listen(findGame)
          ..serve(urls.results, method: 'GET').listen(results);
  });

}

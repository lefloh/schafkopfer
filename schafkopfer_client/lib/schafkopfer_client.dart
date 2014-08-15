library schafkopfer_client;

import 'dart:async';
import 'dart:convert' show JSON;
import 'dart:html' hide Player;

import 'package:bootjack/bootjack.dart';
import 'package:logging/logging.dart';

import 'package:schafkopfer_api/schafkopfer_api.dart';
import 'package:schafkopfer_api/schafkopfer_urls.dart' as urls;

part 'src/schafkopfer_client/page.dart';
part 'src/schafkopfer_client/play_page.dart';
part 'src/schafkopfer_client/start_page.dart';

const String _SERVER_URL = 'http://utkast.de/schafkopfer/r';
const String _LOCAL_SERVER_URL = 'http://localhost:4848';

final _log = new Logger("schafkopfer");

/// Entry point for the SchafkopferClient
class SchafkopferClient {

  void init() {
    String serverUrl = window.location.hostname == 'localhost' || window.location.hostname == '127.0.0.1'
        ? _LOCAL_SERVER_URL : _SERVER_URL;
    _log.info('Initializing SchafkopferClient with serverUrl $serverUrl');
    window.location.hash.isEmpty ? new _StartPage().register(serverUrl) : new _PlayPage().register(serverUrl);
    
    // init Bootstrap
    Alert.use();
    Modal.use();
  }
  
}
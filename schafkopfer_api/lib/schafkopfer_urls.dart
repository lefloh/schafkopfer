library schafkopfer_urls;

import 'package:route/url_pattern.dart';

const String MATCHES = '/matches/';
const String GAMES = '/games/';

final UrlPattern root = new UrlPattern(r'/');
final UrlPattern newMatch = new UrlPattern(r'/matches/');
final UrlPattern findMatch = new UrlPattern(r'/matches/([a-fA-F0-9]+)');
final UrlPattern newGame = new UrlPattern(r'/matches/([a-fA-F0-9]+)/games/');
final UrlPattern listGames = new UrlPattern(r'/matches/([a-fA-F0-9]+)/games/');
final UrlPattern findGame = new UrlPattern(r'/games/([a-fA-F0-9]+)');
final UrlPattern results = new UrlPattern(r'/matches/([a-fA-F0-9]+)/results/');
library schafkopfer_urls;

import 'package:route/url_pattern.dart';

const String MATCHES = '/matches/';
const String GAMES = '/games/';
const String RESULTS = '/results/';

final UrlPattern root = new UrlPattern(r'/');
final UrlPattern newMatch = new UrlPattern(r'/matches/');
final UrlPattern findMatch = new UrlPattern(r'/matches/([a-fA-F0-9]+)');
final UrlPattern newGame = new UrlPattern(r'/matches/([a-fA-F0-9]+)/games/');
final UrlPattern listGames = new UrlPattern(r'/matches/([a-fA-F0-9]+)/games/');
final UrlPattern findGame = new UrlPattern(r'/games/([a-fA-F0-9]+)');
final UrlPattern results = new UrlPattern(r'/matches/([a-fA-F0-9]+)/results/');

String createMatch(String serverUrl) => serverUrl + MATCHES;
String showMatch(String serverUrl, String matchId)=> serverUrl + MATCHES + matchId;
String showResults(String serverUrl, String matchId) => serverUrl + MATCHES + matchId + RESULTS;
String createGame(String serverUrl, String matchId) => serverUrl + MATCHES + matchId + GAMES;
String showGames(String serverUrl, String matchId) => serverUrl + MATCHES + matchId + GAMES;
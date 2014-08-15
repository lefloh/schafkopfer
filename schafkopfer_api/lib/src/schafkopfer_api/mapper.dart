part of schafkopfer_api;

final _dateFormat = new DateFormat("dd.MM.yyyy");
final _currencyFormat = new NumberFormat.currencyPattern('de_DE');

/// Mapping of PODOs to MongoDocuments and JSON-Objects

// Player
List<Player> namesToPlayers(List<String> names)
  => names.map((name) => new Player(new ObjectId(), name)).toList();

List<Map> playersToDocuments(List<Player> players)
  => players.map((player) => {
    '_id' : player.id,
    'name' : player.name
  }).toList();

List<Player> documentsToPlayers(List<Map> maps) 
  => maps.map((map) => new Player(map['_id'], map['name'])).toList();

List<Map> playersToMaps(List<Player> players)
  => players.map((player) => {
    'id' : player.id.toHexString(),
    'name' : player.name
  }).toList();

List<Player> mapsToPlayers(List<Map> maps) 
  => maps.map((map) => new Player(ObjectId.parse(map['id']), map['name'])).toList();

List<String> playersToNames(List<Player> players)
  => players.map((player) => player.name).toList();

// Game
Map gameToDocument(Game game) => {
  '_id' : game.id,
  'type' : game.type.value,
  'rating' : game.rating.value,
  'laufende' : game.laufende,
  'leger' : game.leger,
  'winners' : game.winners.map((player) => player.id).toList()
};

List<Map> gamesToMaps(List<Game> games) => 
    games.map((game) => gameToMap(game)).toList();

Map gameToMap(game) => {
    'id' : game.id.toHexString(),
    'type' : game.type.value,
    'rating' : game.rating.value,
    'laufende' : game.laufende,
    'leger' : game.leger,
    'winners' : playersToMaps(game.winners)
};

String gameToJson(Game game) => JSON.encode(gameToMap(game));

String gamesWithResultsToJson(Map<Game, int> results) {
  var gameArray = [];
  results.forEach((game, result) {
    var mappedGame = gameToMap(game);
    mappedGame['result'] = result;
    gameArray.add(mappedGame);
  });
  return JSON.encode(gameArray);
}

Game documentToGame(Map map, List players) 
  => new Game(map['_id'])
               ..type = GameType.fromValue(map['type'])
               ..rating = GameRating.fromValue(map['rating'])
               ..laufende = map['laufende']
               ..leger = map['leger']
               ..winners = map['winners'].map((id) => players.firstWhere((player) => id == player.id)).toList();
  

Game jsonToGame(String value) {
  var json = JSON.decode(value);
  return mapToGame(json);
}

List<Game> jsonToGames(String value) {
  var json = JSON.decode(value);
  return json.map((map) => mapToGame(map)).toList();
}

Game mapToGame(Map map) 
    => new Game(ObjectId.parse(map['id']))
        ..type = GameType.fromValue(map['type'])
        ..rating = GameRating.fromValue(map['rating'])
        ..laufende = map['laufende']
        ..leger = map['leger']
        ..winners = mapsToPlayers(map['winners']);

// Match
Map matchToDocument(SchafkopfMatch match) => {
  '_id' : match.id,
  'date' : formatDate(match.date),
  'players' : match.players.map((player) => player.id).toList(),
  'games' : match.games.map((game) => game.id).toList()
};

SchafkopfMatch documentToMatch(Map map, List<Player> players, List<Game> games) => 
  new SchafkopfMatch(map['_id'], players)
       ..date = parseDate(map['date'])
       ..games = games;

String matchToJson(SchafkopfMatch match) => JSON.encode({
    'id' : match.id.toHexString(),
    'date' : formatDate(match.date),
    'players' : playersToMaps(match.players),
    'games' : gamesToMaps(match.games)
});

// Result
String resultToJson(Map<Player, int> map) {
  var result = {};
  map.forEach((player, value) => result[player.id.toHexString()] = value);
  return JSON.encode(result);
}

// DateTime
String formatDate(DateTime date) => _dateFormat.format(date);

DateTime parseDate(String date) => _dateFormat.parse(date);

// Currency
String formatAmount(num number) => _currencyFormat.format(number);
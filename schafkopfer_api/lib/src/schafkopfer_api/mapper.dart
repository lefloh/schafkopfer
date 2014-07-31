part of schafkopfer_api;

final _dateFormat = new DateFormat("dd.MM.yyyy");

/// Mapping of PODOs to MongoDocuments and JSON-Objects

class Mapper{}

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
    games.map((game) => {
      'id' : game.id.toHexString(),
      'type' : game.type.value,
      'rating' : game.rating.value,
      'laufende' : game.laufende,
      'leger' : game.leger,
      'winners' : playersToMaps(game.winners)
  }).toList();

String gameToJson(Game game) => JSON.encode(gamesToMaps([game])[0]);

String gamesToJson(List<Game> games) => JSON.encode(gamesToMaps(games));

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
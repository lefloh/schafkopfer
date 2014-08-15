part of schafkopfer_api;

/// dart does not know a enum (yet)
abstract class Enum<T> {

  final T _value;
  const Enum(this._value);

  T get value => _value;
  
  static Enum _fromValue(List<Enum> values, value) {
    if (value == null) {
      return null;
    }
    for (var val in values) {
      if (val._value == value) {
        return val;
      }
    }
    throw new ArgumentError('[$value] not defined in $values');
  }

  toString() => '${this.runtimeType}.$_value';
  
}

/// Type of a SchafkopfGame
class GameType<String> extends Enum<String> {

  const GameType(String) : super(String);
  
  static const RUF = const GameType('Ruf');
  static const SOLO = const GameType('Solo');
  static const WENZ = const GameType('Wenz');
  
  static get values => [RUF, SOLO, WENZ];
  
  static GameType fromValue(value) => Enum._fromValue(values, value);
  
}

/// Rating of a SchafkopfGame
class GameRating<String> extends Enum<String> {
 
  const GameRating(String) : super(String);
  
  static const NORMAL = const GameRating('Normal');
  static const SCHNEIDER = const GameRating('Schneider');
  static const SCHWARZ = const GameRating('Schwarz');
  
  static get values => [NORMAL, SCHNEIDER, SCHWARZ];
  
  static GameRating fromValue(value) => Enum._fromValue(values, value);
  
}

/// A Schafkopf Player
class Player {
  
  static final String collectionName = 'player';
  
  final ObjectId id;
  
  String name;
  
  Player(this.id, this.name);
  
  toString() => 'Player $name (${id.toHexString()})';
  
  int get hashCode => 37 * 17 + id.hashCode;

  bool operator == (other) => id == other.id;

}

/// One Schafkopfgame
class Game {
  
  static final String collectionName = 'game';
  
  final ObjectId id;
  
  GameType type;
  
  GameRating rating;
  
  int laufende;
  
  int leger;
  
  List<Player> winners = [];
  
  Game.initial() : this.id = new ObjectId();
  
  Game(this.id);
  
  toString() => 'Type ${type != null ? type.value : 'null'}' 
                  + ' - Rating ${rating != null ? rating.value : 'null'}' 
                  + ' - winners: ${winners.map((p) => p.name).toList()}'; 

}

/// The whole evening
class SchafkopfMatch {
  
  static final String collectionName = 'match';
  
  final ObjectId id;
  
  DateTime date;
  
  List<Player> players;
  
  List<Game> games;
  
  SchafkopfMatch(ObjectId id, List<Player> players) : this.id = id {
    this.players = players;
    this.date = new DateTime.now();
    this.games = [];
  }
  
  toString() => '${players.map((p) => p.name).toList()} played ${games.length} games ' 
                  + 'on ${formatDate(date)} (${id.toHexString()})';               

}

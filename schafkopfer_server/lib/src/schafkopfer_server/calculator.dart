part of schafkopfer_server;

const int BASE_RUF = 5;
const int BASE_SOLO = 20;
const int BASE_RATING = 10;
const int BASE_LAUFENDE = 5;

/// Calculates with the Raitersaicher Schafkopf-rules.
/// Calculates with cents to avoid rounding-errors.
class _Calculator {
  
  static final _Calculator instance = new _Calculator._internal();
  
  _Calculator._internal();
  
  factory _Calculator() => instance;
  
  int calculate(Game game) {
    var base = game.type == GameType.RUF ? BASE_RUF : BASE_SOLO;
    var rating = game.rating == GameRating.SCHWARZ ? 2 * BASE_RATING : game.rating == GameRating.SCHNEIDER ? BASE_RATING : 0;
    var laufende = game.laufende * BASE_LAUFENDE;
    var sum = base + rating + laufende;
    return sum * pow(2, game.leger);
  }
  
}

/// Holds the calculationResult for a List of games
/// Calculates with cents to avoid rounding-errors.
class CalculatedGames {
  
  final List<Game> games;
  
  final List<Player> players;
  
  CalculatedGames(this.games, this.players);
  
  Map<Player, int> calculate() {
    var calculator = new _Calculator();
    var map = new Map.fromIterable(players, key: (v) => v, value: (v) => 0);
    for (Game game in games) {
      var result = calculator.calculate(game);
      for (Player player in players) {
        if (game.winners.contains(player)) {
          game.type == GameType.RUF ? map[player] += result : map[player] += ((players.length - 1) * result);
        } else {
          map[player] -= result;
        }
      }
    }
    return map;
  }
  
}
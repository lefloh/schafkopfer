import 'package:schafkopfer_api/schafkopfer_api.dart';
import 'package:schafkopfer_server/schafkopfer_server.dart';

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

main() {
  
  useVMConfiguration();
  
  group('Calculator Tests', () {
  
    test('One Calculation', () {
      
      var players = namesToPlayers(['Hannes', 'Jochen', 'Thomas', 'Flo']); 
      var games = [_newGame(GameType.RUF, GameRating.NORMAL, 0, 0, [players.first, players.last])];
      var result = new Calculator(games, players).calculate();
      _checkCalculation(result, 5, -5, -5, 5);
      
      games = [_newGame(GameType.SOLO, GameRating.NORMAL, 0, 0, [players.first])];
      result = new Calculator(games, players).calculate();
      _checkCalculation(result, 60, -20, -20, -20);
      
      games = [_newGame(GameType.WENZ, GameRating.NORMAL, 0, 0, [players.first])];
      result = new Calculator(games, players).calculate();
      _checkCalculation(result, 60, -20, -20, -20);
      
      games = [_newGame(GameType.RUF, GameRating.SCHNEIDER, 0, 0, [players.first, players.last])];
      result = new Calculator(games, players).calculate();
      _checkCalculation(result, 15, -15, -15, 15);
      
      games = [_newGame(GameType.RUF, GameRating.SCHWARZ, 0, 0, [players.first, players.last])];
      result = new Calculator(games, players).calculate();
      _checkCalculation(result, 25, -25, -25, 25);
      
      games = [_newGame(GameType.SOLO, GameRating.SCHNEIDER, 0, 0, [players.last])];
      result = new Calculator(games, players).calculate();
      _checkCalculation(result, -30, -30, -30, 90);
      
      games = [_newGame(GameType.WENZ, GameRating.SCHWARZ, 0, 0, [players.first])];
      result = new Calculator(games, players).calculate();
      _checkCalculation(result, 120, -40, -40, -40);
      
      games = [_newGame(GameType.RUF, GameRating.SCHNEIDER, 3, 0, [players.first, players.last])];
      result = new Calculator(games, players).calculate();
      _checkCalculation(result, 30, -30, -30, 30);
      
      games = [_newGame(GameType.RUF, GameRating.SCHWARZ, 5, 0, [players.first, players.last])];
      result = new Calculator(games, players).calculate();
      _checkCalculation(result, 50, -50, -50, 50);
      
      games = [_newGame(GameType.RUF, GameRating.SCHNEIDER, 3, 1, [players.first, players.last])];
      result = new Calculator(games, players).calculate();
      _checkCalculation(result, 60, -60, -60, 60);
      
      games = [_newGame(GameType.RUF, GameRating.SCHWARZ, 5, 2, [players.first, players.last])];
      result = new Calculator(games, players).calculate();
      _checkCalculation(result, 200, -200, -200, 200);
      
      games = [_newGame(GameType.RUF, GameRating.NORMAL, 0, 5, [players.first, players.last])];
      result = new Calculator(games, players).calculate();
      _checkCalculation(result, 160, -160, -160, 160);
    
    });
    
    test('More Calculations', () {
      var players = namesToPlayers(['Hannes', 'Jochen', 'Thomas', 'Flo']); 
      var games = [_newGame(GameType.RUF, GameRating.NORMAL, 0, 0, [players.first, players.last]),
                   _newGame(GameType.RUF, GameRating.NORMAL, 0, 0, [players.first, players.last]),
                   _newGame(GameType.RUF, GameRating.NORMAL, 0, 0, [players.first, players.last])];
      var result = new Calculator(games, players).calculate();
      _checkCalculation(result, 15, -15, -15, 15);
      
      games = [_newGame(GameType.RUF, GameRating.NORMAL, 0, 0, [players[0], players[3]]),
                 _newGame(GameType.SOLO, GameRating.NORMAL, 2, 0, [players[0]]),
                 _newGame(GameType.RUF, GameRating.SCHNEIDER, 0, 1, [players[2], players[3]])];
      result = new Calculator(games, players).calculate();
      _checkCalculation(result, 65, -65, -5, 5);
      
    });
  });

}

void _checkCalculation(result, first, second, third, fourth) {
  var list = result.values.toList();
  expect(list[0], first);
  expect(list[1], second);
  expect(list[2], third);
  expect(list[3], fourth);
}

Game _newGame(type, rating, laufende, leger, winners) 
  => new Game.initial()
    ..type = type
    ..rating = rating
    ..laufende = laufende
    ..leger = leger
    ..winners = winners;
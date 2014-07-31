import 'dart:async';

import 'package:schafkopfer_api/schafkopfer_api.dart';
import 'package:schafkopfer_server/config.dart';
import 'package:schafkopfer_server/schafkopfer_server.dart';

import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

main() {
  
  useVMConfiguration();
  
  Logger.root.onRecord.listen(new LogPrintHandler());
  
  group('Persistence Tests', () {

    setUp(() {
      var db = new Db(new Config().mongoUrl);
      // return the future that test() knows to wait for the result
      return db.open().then((_) => db.drop()).then((_) => db.close());
    });
    
    test('match', () {
      var documents = new Documents();
      documents.createMatch(['Hannes', 'Jochen', 'Thomas', 'Flo']).then(expectAsync((match) {
        documents.findPlayers(match.players.map((player) => player.id).toList()).then(expectAsync((players) {
          expect(players.length, 4);
          players.forEach((player) {
            documents.findPlayers([player.id]).then(expectAsync((fetchedPlayers) {
              expect(fetchedPlayers.length, 1);
              var fetchedId = fetchedPlayers.toList().first.id;
              expect(fetchedId, player.id);
            }));
          });
        })).then(expectAsync((_) {
          documents.findMatch(match.id).then((fetchedMatch) {
            expect(fetchedMatch.players.length, 4);
            expect(fetchedMatch.games.length, 0);
          });
        }));
      }));
    });
    
    test('games', () {
      var documents = new Documents();
      documents.createMatch(['Hannes', 'Jochen', 'Thomas', 'Flo']).then(expectAsync((match) {
        var games = createGames(match);
        Future.wait([documents.createGame(match.id, games.first), documents.createGame(match.id, games.last)])
          .then(expectAsync((_) {
          documents.findGames([games.first.id, games.last.id]).then(expectAsync((games) {
            expect(games.first.winners.map((player) => player.name), ['Hannes', 'Flo']);
            expect(games.last.winners.map((player) => player.name).first, 'Thomas');
            return games.map((game) => game.id);
          })).then(expectAsync((gameIds) {
            return documents.findMatch(match.id).then(expectAsync((fetchedMatch) {
              var fetchedGameIds = fetchedMatch.games.map((game) => game.id).toList();
              expect(gameIds, unorderedEquals(fetchedGameIds));
            }));
          }));
        }));
      }));
    });
    
    test('gamesByMatch', () {
      var documents = new Documents();
      documents.createMatch(['Hannes', 'Jochen', 'Thomas', 'Flo']).then(expectAsync((match) {
        var games = createGames(match);
        Future.wait([documents.createGame(match.id, games.first), documents.createGame(match.id, games.last)])
          .then(expectAsync((_) {
          documents.findGamesByMatchId(match.id).then(expectAsync((games) {
            expect(games.first.winners.map((player) => player.name), ['Hannes', 'Flo']);
            expect(games.last.winners.map((player) => player.name).first, 'Thomas');
          })).then((_) => documents.close()); // last test closes DB
        }));
      }));
    });

  });

}

List<Game> createGames(SchafkopfMatch match) => [
  new Game.initial()
    ..type = GameType.RUF
    ..rating = GameRating.SCHNEIDER
    ..laufende = 2
    ..leger = 1
    ..winners = [match.players.first, match.players.last],
  new Game.initial()
    ..type = GameType.SOLO
    ..rating = GameRating.SCHWARZ
    ..laufende = 4
    ..leger = 1
    ..winners = [match.players[2]]
];


import 'dart:io';
import 'dart:convert' show UTF8, JSON;

import 'package:schafkopfer_api/schafkopfer_api.dart';
import 'package:schafkopfer_server/config.dart';

import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

main() {
  
  useVMConfiguration();
  
  Logger.root.onRecord.listen(new LogPrintHandler());

  group('Resources Tests', () {
  
    test('Match and Games', () {
      
      var host = InternetAddress.LOOPBACK_IP_V4.host;
      var port = new Config().serverPort;
      HttpClient client = new HttpClient();
      Map matchRequest = { 'players': ['Hannes', 'Jochen', 'Thomas', 'Flo'] };
      
      var createMatch = client.post(host, port, '/matches/').then((request) {
        request.headers.contentType = ContentType.JSON;
        request.write(JSON.encode(matchRequest));
        return request.close();
      }).then(expectAsync((HttpClientResponse response) {
        expect(response.statusCode, 201);
        return response.headers.value('Location');
      }));
      
      var fetchedMatch = createMatch.then(expectAsync((location) {
        return client.get(host, port, location).then((request) {
          return request.close();  
        }).then(expectAsync((HttpClientResponse response) {
          expect(response.statusCode, 200);
          return UTF8.decodeStream(response).then(expectAsync((payload) {
            var match = JSON.decode(payload);
            expect(match['players'].length, 4);
            return match;
          }));
        }));    
      }));
      
      fetchedMatch.then(expectAsync((match) {
        var game = new Game.initial()
                        ..type = GameType.RUF
                        ..rating = GameRating.SCHNEIDER
                        ..laufende = 2
                        ..leger = 1
                        ..winners = mapsToPlayers(match['players'].sublist(0,2));
        var createGame = client.post(host, port, '/matches/${match["id"]}/games/').then((request) {
          request.headers.contentType = ContentType.JSON;
          request.write(gameToJson(game));
          return request.close();
        }).then(expectAsync((HttpClientResponse response) {
          expect(response.statusCode, 201);        
          return response.headers.value('Location');
        }));
        
        return createGame.then(expectAsync((location) {
          return client.get(host, port, location).then((request) {
             return request.close();
           }).then(expectAsync((HttpClientResponse response) {
              expect(response.statusCode, 200);
              return UTF8.decodeStream(response).then(expectAsync((payload) {
                var fetchedGame = jsonToGame(payload);
                expect(fetchedGame.type, GameType.RUF);
                expect(fetchedGame.rating, GameRating.SCHNEIDER);
                return { 'matchId' : match['id'], 'gameId' : fetchedGame.id };
              }));
           }));
        }));
        
      })).then(expectAsync((ids) {
        return client.get(host, port, '/matches/${ids["matchId"]}/games/').then((request) {
            return request.close();
          }).then(expectAsync((HttpClientResponse response) {
            expect(response.statusCode, 200);
            return UTF8.decodeStream(response).then(expectAsync((payload) {
              var games = jsonToGames(payload.toString());
              expect(games.first.id, ids['gameId']);
              return ids["matchId"];
            }));
        }));
      
      })).then(expectAsync((matchId) {
        client.get(host, port, '/matches/$matchId/results/').then((request) {
          return request.close();
        }).then(expectAsync((HttpClientResponse response) {
          expect(response.statusCode, 200);
          return UTF8.decodeStream(response).then(expectAsync((payload) {
            var results = JSON.decode(payload).values.toList();
            expect(results, [50, 50, -50, -50]);
          })).then((_) => client.close());
        }));
      }));

    });

  });
  
}
part of schafkopfer_server;

class Documents {

  static final Documents _instance = new Documents._internal();

  static _MongoDbPool _pool;

  factory Documents() {
    if (_pool == null) {
      var config = new Config();
      _pool = new _MongoDbPool(config.mongoUrl, config.mongoPoolSize);
    }
    return _instance;
  }

  Documents._internal();

  /// Persits a SchafkopfMatch and Players and returns a Future of the Match
  Future<SchafkopfMatch> createMatch(List<String> playerNames) {
    var players = namesToPlayers(playerNames);
    var match = new SchafkopfMatch(new ObjectId(), players);
    return _execute((conn) {
      var insertPlayers = conn.collection(Player.collectionName).insertAll(playersToDocuments(players));
      var insertMatch = conn.collection(SchafkopfMatch.collectionName).insert(matchToDocument(match));
      return Future.wait([insertPlayers, insertMatch]).then((_) => new Future.value(match));
    });
  }
  
  /// Finds the Match for the given id. Collects players and matches.
  Future<SchafkopfMatch> findMatch(ObjectId id) {
    return _execute((conn) {
      return conn.collection(SchafkopfMatch.collectionName).findOne({ '_id' : id }).then((match) {
        if (match == null) {
          return new Future.value(null);
        }
        var players = findPlayers(match['players']);
        var games = findGames(match['games']);
        return Future.wait([players, games]).then((result) => documentToMatch(match, result[0], result[1]));
      });
    });
  }
  
  /// Returns a Future with all Players found for given ids.
  Future<List<Player>> findPlayers(List<ObjectId> ids) {
    return _execute((conn) {
      return conn.collection(Player.collectionName).find({ '_id' : { '\$in' : ids } }).toList();
    }).then((players) {
       return documentsToPlayers(players);
    });
  }
  
  /// Persists the game, adds the id to the match and returns a future of the game.
  Future<Game> createGame(ObjectId matchId, Game game) {
   return _execute((conn) {
     Future insertGame = conn.collection(Game.collectionName).insert(gameToDocument(game));
     Future updateMatch = conn.collection(SchafkopfMatch.collectionName).update(
       where.id(matchId), modify.push('games', game.id)    
     );
     return Future.wait([insertGame, updateMatch]).then((_) => new Future.value(game));
   }); 
  }
  
  /// Returns a Future with all Games found for given ids. Collects players.
  Future<List<Game>> findGames(List<ObjectId> ids) {
    return _execute((conn) {
      return conn.collection(Game.collectionName).find({ '_id' : { '\$in' : ids } }).toList();
    }).then((games) {
      if (games == null) {
        return new Future.value(null);
      }
      var playerIds = new Set();
      games.forEach((game) => game['winners'].forEach((winner) => playerIds.add(winner)));
      return findPlayers(playerIds.toList()).then((players) {
        return games.map((game) => documentToGame(game, players)).toList(); 
      });
    });
  }
  
  /// Returns a Future with all Games found for given matchId. Collects players.
  Future<List<Game>> findGamesByMatchId(ObjectId matchId) {
    return _execute((conn) {
      return conn.collection(SchafkopfMatch.collectionName).findOne({ '_id' : matchId }).then((match) {
        if (match == null) {
          return new Future.value(null);
        }
        return findGames(match['games']);
      });
    });
  }
  
  /// Generic method that fetches a connection from the pool
  /// execute statements with this connection as parameter,
  /// releases the connection in every case and logs errors.
  Future _execute(statements) {
    return _pool.getConnection().then((managedConnection) {
      return statements(managedConnection.conn).then((result) {
        _pool.releaseConnection(managedConnection);
        return new Future.value(result);
      }).catchError((e) {
        _log.severe('Error executing DB statement: ${e.toString()}');
        _pool.releaseConnection(managedConnection);
      });
    });
  }

  /// Close all connection kept in the pool.
  void close() {
    for (var i = 0; i < new Config().mongoPoolSize; i++) {
      _pool.getConnection().then((managedConnection) {
        _pool.closeConnection(managedConnection.conn);
      });
    }
  }

}

/// Uses the pool from connection_pool library.
class _MongoDbPool extends ConnectionPool<Db> {

  String uri;

  _MongoDbPool(String this.uri, int poolSize) : super(poolSize);

  @override
  Future<Db> openNewConnection() {
    var conn = new Db(uri);
    return conn.open().then((_) => conn);
  }

  @override
  void closeConnection(Db conn) {
    conn.close();
  }
  
}
part of schafkopfer_server;

/// Handles HTTP Requests

void root(HttpRequest request) {
  _sendText(request, 200, 'SchafkopferServer up and running');
}

void newMatch(HttpRequest request) {
  if (!_validContentType(request, ContentType.JSON)) {
    return;
  }
  UTF8.decodeStream(request).then((payload) {
    var json = JSON.decode(payload.toString());
    var playerNames = json['players'];
    if (!validateNames(playerNames)) {
      _sendText(request, 400, 'Error creating match for $playerNames');
      return;
    }
    new Documents().createMatch(playerNames).then((match) {  
      request.response.headers.add('Location', urls.MATCHES + match.id.toHexString());
      request.response.statusCode = 201;
      request.response.close();
    });
  }).catchError((e) => _handleError(request, 'Error creating match: ${e.toString()}'));
}

void findMatch(HttpRequest request) {
  var id = urls.findMatch.parse(request.uri.path)[0];
  if (!validateObjectId(id)) {
    _sendText(request, 404, 'Match "$id" not found');
    return;
  }
  new Documents().findMatch(ObjectId.parse(id)).then((match) {
    if (match == null) {
      _sendText(request, 404, 'Match "$id" not found');
      return;
    }
    _sendJson(request, 200, matchToJson(match));
  }).catchError((e) => _handleError(request, 'Error serving match $id: ${e.toString()}'));  
}

void newGame(HttpRequest request) {
  if (!_validContentType(request, ContentType.JSON)) {
    return;
  }
  var matchId = urls.newGame.parse(request.uri.path)[0];
  UTF8.decodeStream(request).then((payload) {
    var game = jsonToGame(payload.toString());
    if (!validateGame(game)) {
      _sendText(request, 400, 'Invalid game');
      return;
    }
    
    new Documents().createGame(ObjectId.parse(matchId), game).then((game) {  
      request.response.headers.add('Location', urls.GAMES + game.id.toHexString());
      var result = new _Calculator().calculate(game);
      _sendJson(request, 201, JSON.encode({ 'result' : result }));
    });
  }).catchError((e) => _handleError(request, 'Error decoding game: ${e.toString()}'));
}

void listGames(HttpRequest request) {
  var matchId = urls.listGames.parse(request.uri.path)[0];
  if (!validateObjectId(matchId)) {
    _sendText(request, 404, 'Match "$matchId" not found');
    return;
  } 
  new Documents().findMatch(ObjectId.parse(matchId)).then((match) {
    if (match == null) {
      _sendText(request, 404, 'Games for match "$matchId" not found');
      return;
    }
    var calculator = new _Calculator();
    var results = <Game, int>{};
    match.games.forEach((game) => results[game] = calculator.calculate(game));
    _sendJson(request, 200, gamesWithResultsToJson(results));
  }).catchError((e) => _handleError(request, 'Error serving games for Match $matchId: ${e.toString()}'));  
}

void findGame(HttpRequest request) {
  var id = urls.findGame.parse(request.uri.path)[0];
  if (!validateObjectId(id)) {
    _sendText(request, 404, 'Game "$id" not found');
    return;
  }
  new Documents().findGames([ObjectId.parse(id)]).then((games) {
    if (games == null) {
      _sendText(request, 404, 'Game "$id" not found');
      return;
    }
    _sendJson(request, 200, gameToJson(games.first));
  }).catchError((e) => _handleError(request, 'Error serving game $id: ${e.toString()}'));
  
}

void results(HttpRequest request) {
  var matchId = urls.results.parse(request.uri.path)[0];
  if (!validateObjectId(matchId)) {
    _sendText(request, 404, 'Match "$matchId" not found');
    return;
  } 
  new Documents().findMatch(ObjectId.parse(matchId)).then((match) {
    if (match == null) {
    _sendText(request, 404, 'Games for match "$matchId" not found');
    return;
  }
  var result = new CalculatedGames(match.games, match.players).calculate();
  _sendJson(request, 200, resultToJson(result));
  }).catchError((e) => _handleError(request, 'Error serving results for Match $matchId: ${e.toString()}'));   
}

bool _validContentType(request, contentType) {
  ContentType requestContentType = request.headers.contentType;
  if (requestContentType == null || requestContentType.mimeType != contentType.mimeType) {
    _sendText(request, 415, 'ContentType "$requestContentType" is not supported');
    return false;
  }  
  return true;
}

void _sendJson(HttpRequest request, status, payload) {
  // allways show the latest results
  request.response.headers.set(HttpHeaders.CACHE_CONTROL, 'private, max-age=0, no-cache');
  _send(request, status, payload, ContentType.JSON);
}

void _sendText(request, status, msg) {
  _send(request, status, msg, ContentType.TEXT);
}

void _send(request, status, payload, contentType) {
  request.response.headers.contentType = contentType;
  request.response.statusCode = status;
  request.response.write(payload);
  request.response.close();
}

void _handleError(request, msg) {
  _log.warning(msg);
  _sendText(request, 500, 'Internal Server Error');
}
part of schafkopfer_client;

/// The page where the games are entered and the result is displayed
class _PlayPage extends _Page {
  
  String get id => 'play';
  
  String get errorId => 'saveGameError';
  
  String get matchId => window.location.hash.substring(1);
  
  List<Player> players;
  
  @override
  void registerPage() {
    initMatch().then((fetchedPlayers) {
      players = fetchedPlayers;
      showResults();
      initPlayGameForm();
      registerEvents();
    });
  }
  
  Future<List<Player>> initMatch() {
    return HttpRequest.getString(urls.showMatch(serverUrl, matchId)).then((response) {
      var players = JSON.decode(response)['players'];
      return new Future.value(mapsToPlayers(players));
    });
  }
  
  void initPlayGameForm() {
    var form = querySelector('#saveGame');
    addButtonGroup(form, 'winners', 'Sieger', playersToNames(players), toggleActiveWinners);
    var oneToEight = new List<int>.generate(8, (idx) => idx + 1);
    addButtonGroup(form, 'leger', 'Leger', oneToEight, toggleOneActive);
    addButtonGroup(form, 'laufende', 'Laufende', oneToEight, toggleOneActive);
    addButtonGroup(form, 'gameRating', 'Wertung', GameRating.values, toggleOneActive);
    addButtonGroup(form, 'gameType', 'Spieltyp', GameType.values, toggleOneActive);
  }
    
  void addButtonGroup(form, name, label, values, toggle) {
    var div = new DivElement()
                    ..id = '${name}Group'
                    ..classes.add('form-group');
    div.append(new DivElement()).append(new LabelElement()..text = label);
    var btnGroup = new DivElement()..classes.add('btn-group');
    for (var val in values) {
      var btn = new InputElement(type : 'button')
                    ..name = name
                    ..value = val is Enum ? val.value : val.toString()
                    ..classes.add('btn btn-default')
                    ..addEventListener('click', toggle);
      btnGroup.append(btn);
    }
    div.append(btnGroup);
    form.insertAdjacentElement('afterBegin', div);
  }
  
  void toggleActiveWinners(event) {
    // HACK removing .active does not remove :active so we are overriding
    // :active with another classe
    if (querySelectorAll('[name=${event.target.name}].active').length == 0) {
      querySelectorAll('[name=${event.target.name}]').classes.add('non-active'); 
    }
    event.target.classes.toggleAll(['active', 'non-active']);
  }
  
  void toggleOneActive(event) {
    querySelectorAll('[name=${event.target.name}]').classes.remove('active');
    event.target.classes.add('active');
  }
  
  void registerEvents() {
    // No Schneider on Solo and Wenz
    querySelectorAll('#gameTypeGroup input').onClick.listen((event) {
      querySelectorAll('#gameRatingGroup input')
        .firstWhere((input) => input.value == GameRating.SCHNEIDER.value)
        .disabled = event.target.value != GameType.RUF.value;
    });
    // submit the game
    querySelector('#saveGame').onSubmit.listen(saveGame);
    // show modal on click on logo
    var span = querySelector('header span');
    span.replaceWith(new AnchorElement(href: '#modal')
          ..text = span.text
          ..dataset['toggle'] = 'modal'
          ..addEventListener('click', showGames));
    // end match button
    querySelector('#endMatch').onClick.listen((event) {
      window.location.hash = '';
      window.location.reload();
    });
  }
  
  void showResults({result}) {
    var table = querySelector('#results');
    table..classes.remove('fade-in')..classes.add('fade-out');
    table.children.clear();
    
    if (result != null) {
      var p = querySelector('#lastResult');
      p..classes.remove('fade-out')
       ..classes.add('fade-in')
       ..text = 'Ergebnis: ${formatAmount(result / 100)}';
     new Future.delayed(const Duration(seconds: 2), () => "2")
          .then((_) => p..classes.toggleAll(['fade-out', 'fade-in'])..text = '');
    }
    
    HttpRequest.getString(urls.showResults(serverUrl, matchId)).then((response) {
      var headers = table.createTHead().insertRow(-1);
      var scores = table.createTBody().insertRow(-1);
      JSON.decode(response).forEach((k, v) {
        var name = players.firstWhere((p) => p.id.toHexString() == k).name;
        var th = new Element.tag('th')..text = name;
        headers.insertAdjacentElement('beforeend', th);
        scores.addCell().text = formatAmount(v / 100); // we are getting cents
      });
      table..classes.remove('fade-out')..classes.add('fade-in');
      querySelectorAll('#gameRatingGroup input')
        .firstWhere((input) => input.value == GameRating.SCHNEIDER.value)
        .disabled = false;      
    });
  }

  void showGames(event) {
    HttpRequest.getString(urls.showGames(serverUrl, matchId)).then((response) {
      var tableBody = querySelector('#gameslist tbody');
      tableBody.children.clear();
      var results = JSON.decode(response);
      results.reversed.forEach((map) {
        var row = tableBody.insertRow(-1);
        row.addCell().text = map['type'] + ' / ' + map['rating'] + ' / ' 
                            + map['laufende'].toString() + ' / ' + map['leger'].toString();
        row.addCell().text = map['winners'].map((m) => m['name']).join(', ');
        row.addCell().text = formatAmount(map['result'] / 100);
      });
    });
  }
  
  void saveGame(Event event) {
    event.preventDefault();
    var game = new Game.initial()
                      ..type = getEnumValue('gameType', GameType.fromValue)
                      ..rating = getEnumValue('gameRating', GameRating.fromValue)
                      ..laufende = getIntValue('laufende')
                      ..leger = getIntValue('leger')
                      ..winners = getWinners();
    var errors = validateGame(game);
    if (errors.isEmpty) {
      hideError();
    } else {
      showError(errors);
      return;
    }
    HttpRequest.request(urls.createGame(serverUrl, matchId), method: 'POST', 
      requestHeaders: { 'Content-Type': 'application/json;charset=utf-8' },
      sendData : gameToJson(game)
    ).then((request) {
      var result = JSON.decode(request.responseText)['result'];
      showResults(result: result);
      querySelectorAll('.active')..classes.remove('active');
    }).catchError((e) {
      showError(['Das Spiel konnte nicht gespeichert werden.']);
    });  
  }
  
  Enum getEnumValue(String identifier, dynamic converter(String val)) {
    var element = querySelector('[name=${identifier}].active');
    if (element == null) {
      return null;
    }
    return converter((element as InputElement).value);
  }
  
  int getIntValue(String identifier) {
    var element = querySelector('[name=${identifier}].active');
    return element == null ? 0 : num.parse(element.value);
  }
  
  List<Player> getWinners() {
    var winners = querySelectorAll('[name=winners].active').map((e) => e.value).toList();
    return players.where((player) => winners.contains(player.name)).toList();
  }
  
  List<String> validateGame(Game game) {
    var messages = [];
    gameValidationRules.forEach((func, msg) {
      if (func(game)) {
        messages.add(msg);
      }
    });
    return messages;
  }
  
  var gameValidationRules = <Function, String>{
    (Game game) => game.type == null : 'Bitte wählen Sie einen Typ aus',
    (Game game) => game.rating == null : 'Bitte wählen Sie eine Wertung aus',
    (Game game) => game.type != null && game.type == GameType.RUF && game.winners.length != 2 : 'Ein Ruf hat zwei Sieger',
    (Game game) => game.type != null && game.type != GameType.RUF && game.winners.length != 1 : 'Ein Solo oder Wenz hat einen Sieger'
  };
  
}
part of schafkopfer_server;

final namePattern = new RegExp(r"[a-zA-ZäöüÄÖÜ .'-]{3,30}");

bool validateObjectId(id) {
  try {
    ObjectId.parse(id);
    return true;
  } catch(e) {
    _log.severe('Error parsing ObjectId "$id"');
    return false;
  }  
}

bool validateNames(List<String> names) {
  if (names.isEmpty || names.length > 4 || names.length < 3) {
    return false;
  }
  return names.every((name) => validateName(name));
}

bool validateName(String name) {
  return namePattern.hasMatch(name);
}

bool validateGame(Game game) {
  return game.type != null
      && game.rating != null
      && game.laufende >= 0 && game.laufende < 9
      && game.leger >= 0
      && game.winners != null
      && game.type == GameType.RUF ? game.winners.length == 2 : game.winners.length == 1;
}
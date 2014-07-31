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
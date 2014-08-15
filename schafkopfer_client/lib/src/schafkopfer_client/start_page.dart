part of schafkopfer_client;

/// First page: Holds a form for entering the player names.
class _StartPage extends _Page {

  String get id => 'start';
  
  String get errorId => 'startMatchError';
  
  @override
  void registerPage() {
    querySelector('#startMatch').onSubmit.listen(startMatch);
  }
  
  void startMatch(Event event) {
    event.preventDefault();
    
    hideError();
    Map matchRequest = { 'players': querySelectorAll('#startMatch input').map((input) => input.value).toList() };
    
    HttpRequest.request(urls.createMatch(serverUrl), method: 'POST', 
      requestHeaders: { 'Content-Type': 'application/json;charset=utf-8' },
      sendData : JSON.encode(matchRequest)
    ).then((request) {
      var matchId = request.responseHeaders['location'].replaceAll(urls.MATCHES, '');
      window.location.hash = matchId;
      new _PlayPage().register(serverUrl);
    }).catchError((e) {
      showError(['Das Spiel konnte nicht angelegt werden. Bitte überprüfen Sie die Namen.']);
    });
    
  }
  
}
part of schafkopfer_client;

/// BaseClass for every Page
abstract class _Page {
  
  String get id;
  
  String get errorId; // id of the div where errors should be displayed
  
  String serverUrl;
  
  void register(String serverUrl) {
    this.serverUrl = serverUrl;
    _log.info('registering Page "$id"');
    registerPage();
    showPage();
  }
  
  /// InitFunction. Called before page is displayed.
  void registerPage();
  
  void showError(List<String> messages) {
    _log.warning('Will display following Errors: $messages');
    var div = querySelector('#$errorId')..classes.remove('hidden')..children.clear();
    messages.forEach((msg) => div.appendHtml('<p>$msg</p>'));
  }
  
  void hideError() {
    querySelector('#$errorId').classes.add('hidden');
  }
  
  void showPage() {
    querySelectorAll('article').forEach((HtmlElement article) {
      if (article.id == id) {
        article.classes.add('fade-in');
      } else if (article.classes.contains('fade-in')) {
        article..classes.add('hidden')..classes.remove('fade-in');
      }
    });
  }
  
}
import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';

import 'package:schafkopfer_client/schafkopfer_client.dart';

void main() {
  
  Logger.root.onRecord.listen(new LogPrintHandler());

  new SchafkopferClient().init();
  
}
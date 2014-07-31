import 'package:schafkopfer_server/schafkopfer_server.dart';

import 'package:logging/logging.dart';
import 'package:logging_handlers/logging_handlers_shared.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

main() {
  
  useVMConfiguration();
  
  Logger.root.onRecord.listen(new LogPrintHandler());

  group('Validator Tests', () {
  
    test('validName', () {
      
      expect(validateName('Flo'), true);
      expect(validateName('Jöchen \'-1.'), true);
      expect(validateName('Fh'), false);
      expect(validateName('1234567890123456789012345678901'), false);
      expect(validateName('!#+*'), false);
      
    });
    
    test('validNames', () {
      
      expect(validateNames(['Jochen', 'Hannes', 'Thomas', 'Flo']), true);
      expect(validateNames(['Jochen', 'Hannes', 'Thomas', 'Flo', 'Fritz']), false);
      expect(validateNames(['Jochen', 'Hannes']), false);
      expect(validateNames(['Jochen', 'Hannes', 'Thomas', 'Fl#']), false);
      
    });
    
  });
  
}
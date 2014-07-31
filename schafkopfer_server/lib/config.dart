library config;

import 'dart:io';

import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

const String CONFIG_NAME = '_config.yaml';

const String ENV_IDENTIFER = 'SCHAFKOPFER_ENV';

final _logger = new Logger("schafkopfer-config");

/// Holds configuration for the schafkopfer-server
/// as a singleton.
class Config {
  
  static final Config _instance = new Config._internal();
  
  static Map _config;
  
  static Directory _rootDir = new File.fromUri(Platform.script).parent.parent; // assuming we are always executed in ./test or ./bin
  
  factory Config() {
    if (_config == null) {
      String type = Platform.environment.containsKey(ENV_IDENTIFER) ? Platform.environment[ENV_IDENTIFER] : 'default';
      _config = _loadConfig(type + CONFIG_NAME);
    }
    return _instance;
  }
  
  Config._internal();
  
  int get serverPort => _config['serverPort'];
  String get mongoUrl => _config['mongoUrl'];
  int get mongoPoolSize => _config['mongoPoolSize'];
  
  static Map _loadConfig(String fileName) {
    String filePath = _rootDir.path + '/resources/' + fileName;
    String conf = new File(filePath).readAsStringSync();
    _logger.info('Using config $filePath:\n$conf');
    return loadYaml(conf);
  }
  
}
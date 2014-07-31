library schafkopfer_server;

import 'dart:async';
import 'dart:convert' show UTF8, JSON;
import 'dart:io';
import 'dart:math';

import 'package:connection_pool/connection_pool.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'package:schafkopfer_api/schafkopfer_api.dart';
import 'package:schafkopfer_api/schafkopfer_urls.dart' as urls;
import 'package:schafkopfer_server/config.dart';

part 'src/schafkopfer_server/calculator.dart';
part 'src/schafkopfer_server/persistence.dart';
part 'src/schafkopfer_server/resources.dart';
part 'src/schafkopfer_server/validator.dart';

final _log = new Logger("schafkopfer");
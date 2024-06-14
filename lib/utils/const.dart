import 'package:logger/web.dart';
import 'package:terpiez/utils/redis_client.dart';

Logger logger = Logger();

final redis = RedisClient.instance;

class ConnectionStatus {
  static String connected = 'succesfull';
  static String disconnected = 'failed';
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:redis/redis.dart';
import 'package:terpiez/utils/const.dart';

class RedisClient {
  late Command _command;
  static final _instance = RedisClient._();
  final _storage = const FlutterSecureStorage();

  RedisClient._();

  static RedisClient get instance => _instance;

  Future<bool> connect({String? user, String? pass}) async {
    final conn = RedisConnection();
    try {
      // connection to 436 redis server
      Command command =
          await conn.connect('cmsc436-0101-redis.cs.umd.edu', 6380);

      // auth connection to the server
      // Retrieve credentials securely from flutter_secure_storage
      String? username =
          user ?? await _storage.read(key: 'auth_redis_username');
      String? password =
          pass ?? await _storage.read(key: 'auth_redis_password');

      if (username == null || password == null) {
        throw Exception('Username or password not found');
      }

      await command.send_object(['AUTH', username, password]);

      _instance._command = command;
      return true;
    } on RedisError catch (e) {
      logger.d(e);
      return false;
    } catch (e) {
      logger.d(e);
      return false;
    }
  }

  // Function to securely store credentials
  Future<void> storeCredentials(String username, String password) async {
    await _storage.write(key: 'auth_redis_username', value: username);
    await _storage.write(key: 'auth_redis_password', value: password);
  }

  Future<void> closeConnection() async {
    await _instance._command.get_connection().close();
  }

  Future<dynamic> get(String key, String path) async {
    return await _instance._command.send_object(['JSON.GET', key, path]);
  }

  Future<bool> set(List<String> path, String value) async {
    String formattedPath = '.${path.join('.')}';
    return await _instance._command
        .send_object(['JSON.SET', 'jvaldiv8', formattedPath, value]);
  }

  Future<bool> arrayAppend(List<String> path, String value) async {
    String formattedPath = '.${path.join('.')}';
    return await _instance._command
        .send_object(['JSON.ARRAPPEND', 'jvaldiv8', formattedPath, value]);
  }

  Future<bool> arrayInsert(List<String> path, String value) async {
    String formattedPath = '.${path.join('.')}';
    return await _instance._command
        .send_object(['JSON.ARRINSERT', 'jvaldiv8', formattedPath, value]);
  }
}

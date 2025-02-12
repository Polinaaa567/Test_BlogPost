import 'package:postgres/postgres.dart';
import '../configure/config.dart';

class FactoryDatabase {
  static IDatabase createDatatabase() {
    return Database();
  }
}

abstract class IDatabase {
  Future<void> connect();
  Future<Result> execute(String query, {Map<String, dynamic>? params});
}

class Database implements IDatabase {
  late final Connection conn;

  @override
  Future<void> connect() async {
    conn = await Connection.open(
      Endpoint(
        host: LocalDataAboutDB.host,
        database: LocalDataAboutDB.database,
        port: LocalDataAboutDB.port,
        username: LocalDataAboutDB.username,
        password: LocalDataAboutDB.password,
      ),
      settings: ConnectionSettings(sslMode: SslMode.disable),
    );

  }

  @override
  Future<Result> execute(String query, {Map<String, dynamic>? params}) async {
    return await conn.execute(Sql.named(query), parameters: params);
  }
}

import 'package:shopping_list/providers/db_provider.dart';

class HouseholdRepository {
  final DBProvider dbProvider = DBProvider();

  Future<int> addHousehold(String name, int ownerId, bool isPrivate) async {
    final db = await dbProvider.db;
    return await db.insert('households', {
      'name': name,
      'owner_id': ownerId,
      'is_private': isPrivate ? 1 : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getAllHouseholds() async {
    final db = await dbProvider.db;
    return await db.query('households');
  }

  Future<void> deleteHousehold(int id) async {
    final db = await dbProvider.db;
    await db.delete('households', where: 'id = ?', whereArgs: [id]);
  }
}
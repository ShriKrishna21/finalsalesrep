
import 'package:finalsalesrep/database/model/agencymodel.dart';
import 'package:finalsalesrep/database/promotiondatabase.dart';
import 'package:sqflite/sqflite.dart';

class AgencyDao {
  Future<void> insertAgencies(List<Agencyy> agencies) async {
    final db = await PromotionDatabase.instance.database;

    await db.transaction((txn) async {
      await txn.delete('agency_master');

      final batch = txn.batch();

      for (final agency in agencies) {
        batch.insert(
          'agency_master',
          agency.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  Future<List<Agencyy>> getAgencies() async {
    final db = await PromotionDatabase.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'agency_master',
      orderBy: 'location_name ASC',
    );

    return maps.map((map) => Agencyy.fromMap(map)).toList();
  }

  Future<void> deleteAgencies() async {
    final db = await PromotionDatabase.instance.database;
    await db.delete('agency_master');
  }
}

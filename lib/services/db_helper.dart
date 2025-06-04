// lib/services/db_helper.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._();
  factory DBHelper() => _instance;
  DBHelper._();

  Database? _db;
  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'txns.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, v) {
        return db.execute('''
        CREATE TABLE transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT,
          amount REAL,
          currency TEXT,
          counterparty TEXT,
          timestamp TEXT,
          pdfPath TEXT,
          transactionNo TEXT,
          fee REAL
        )
        ''');
      },
    );
    return _db!;
  }

  Future<int> insertTxn(TransactionRecord txn) async {
    final d = await db;
    return d.insert('transactions', txn.toMap());
  }

  Future<List<TransactionRecord>> fetchAll() async {
    final d = await db;
    final rows = await d.query('transactions', orderBy: 'id DESC');
    return rows.map((r) => TransactionRecord.fromMap(r)).toList();
  }
}

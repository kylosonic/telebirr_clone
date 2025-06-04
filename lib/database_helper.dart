import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('telebirr.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = path.join(directory.path, filePath);
    return await openDatabase(dbPath, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE bank_accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        bank_name TEXT NOT NULL,
        account_number TEXT NOT NULL,
        name TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender_id INTEGER,
        recipient_id INTEGER,
        bank_account_id INTEGER,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        transaction_number TEXT NOT NULL,
        FOREIGN KEY (sender_id) REFERENCES users (id),
        FOREIGN KEY (recipient_id) REFERENCES users (id),
        FOREIGN KEY (bank_account_id) REFERENCES bank_accounts (id)
      )
    ''');

    // Insert dummy users
    await db.insert('users', {'name': 'Yonatan', 'phone': '+251945124578'});
    await db.insert('users', {'name': 'Areagwi', 'phone': '+251967293513'});
    await db.insert('users', {'name': 'Samrawi', 'phone': '+251941243538'});
    await db.insert('users', {'name': 'Haimanot', 'phone': '+251911223355'});
    await db.insert('users', {'name': 'Bekelle', 'phone': '+251911223366'});

    // Insert dummy bank accounts with name
    await db.insert('bank_accounts', {
      'user_id': 1,
      'bank_name': 'Commercial Bank of Ethiopia',
      'account_number': '1000006955502',
      'name': 'BEKELE MOLLA HOTEL PLC',
    });
    await db.insert('bank_accounts', {
      'user_id': 2,
      'bank_name': 'Dashen Bank',
      'account_number': '20004567891234',
      'name': 'Areagwi',
    });
    await db.insert('bank_accounts', {
      'user_id': 3,
      'bank_name': 'Commercial Bank of Ethiopia',
      'account_number': '1000293169237',
      'name': 'BORA AMUSEMENT PARK EMEBET WOLDHER',
    });
    await db.insert('bank_accounts', {
      'user_id': 4,
      'bank_name': 'Bank of Abyssinia',
      'account_number': '10983878',
      'name': 'Haimanot',
    });

    // Insert dummy transactions
    await db.insert('transactions', {
      'sender_id': 1,
      'recipient_id': 2,
      'amount': 50.00,
      'type': 'Send Money',
      'timestamp': '2023-10-15 12:00:00',
      'transaction_number': 'CCC1740SJD',
    });
    await db.insert('transactions', {
      'sender_id': 1,
      'bank_account_id': 1,
      'amount': 893.00,
      'type': 'Transfer to Bank',
      'timestamp': '2023-10-15 12:05:00',
      'transaction_number': 'CBM3UQQ4SL',
    });
  }

  Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<List<Map<String, dynamic>>> getBankAccounts() async {
    final db = await database;
    return await db.query('bank_accounts');
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return await db.query('transactions');
  }

  Future<String> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    final timestamp = DateTime.now().toIso8601String();
    final transactionNumber =
        'CBM${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    await db.insert('transactions', {
      ...transaction,
      'timestamp': timestamp,
      'transaction_number': transactionNumber,
    });
    return transactionNumber;
  }

  Future<int> insertBankAccount(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('bank_accounts', row);
  }

  Future<Map<String, dynamic>?> getBankAccountByNumber(
    String accountNumber,
  ) async {
    final db = await database;
    final result = await db.query(
      'bank_accounts',
      where: 'account_number = ?',
      whereArgs: [accountNumber],
    );
    return result.isNotEmpty ? result.first : null;
  }
}

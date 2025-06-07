import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'users.db');
    return openDatabase(
      path,
      version: 3, // Tingkatkan versi jika ada perubahan struktur
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE cart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        harga REAL,
        alamat TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  )
''');

  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Kosongkan dulu, bisa digunakan jika ada struktur baru di masa depan
  }

  // CRUD Users

  Future<int> insertUser(String name, String email, String password) async {
    final db = await database;
    return await db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<bool> userExists(String email) async {
    final db = await database;
    final res = await db.query('users', where: 'email = ?', whereArgs: [email]);
    return res.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateUserName(String email, String newName) async {
    final db = await database;
    return await db.update(
      'users',
      {'name': newName},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // CRUD Favorites

  Future<int> addFavorite(int userId, int productId) async {
    final db = await database;
    return await db.insert('favorites', {
      'user_id': userId,
      'product_id': productId,
    });
  }

  Future<int> removeFavorite(int userId, int productId) async {
    final db = await database;
    return await db.delete(
      'favorites',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
    );
  }

  Future<bool> isFavorited(int userId, int productId) async {
    final db = await database;
    final res = await db.query(
      'favorites',
      where: 'user_id = ? AND product_id = ?',
      whereArgs: [userId, productId],
      limit: 1,
    );
    return res.isNotEmpty;
  }

  Future<List<int>> getFavoriteProductIdsByUser(int userId) async {
    final db = await database;
    final res = await db.query(
      'favorites',
      columns: ['product_id'],
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return res.map<int>((row) => row['product_id'] as int).toList();
  }

  Future<void> deleteDatabaseDebug() async {
    final path = join(await getDatabasesPath(), 'users.db');
    await deleteDatabase(path);
  }

  Future<List<Map<String, dynamic>>> getAllFavorites() async {
  final db = await database;
  return await db.query('favorites');
}

// Fungsi mengambil semua user (List<Map<String,dynamic>>)
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');  // ambil semua data dari tabel users
  }

  // CRUD CART

  Future<void> addToCart(int userId, int productId, double harga) async {
  final db = await database;

  // Cek apakah produk sudah ada di keranjang user ini
  final existing = await db.query(
    'cart',
    where: 'user_id = ? AND product_id = ?',
    whereArgs: [userId, productId],
  );

  if (existing.isEmpty) {
    await db.insert('cart', {
      'user_id': userId,
      'product_id': productId,
      'harga': harga,
    });
    // Debugging ke console
    print('✅ Ditambahkan ke cart: user_id=$userId, product_id=$productId, harga=$harga');
  }
}


Future<List<Map<String, dynamic>>> getCartByUser(int userId) async {
  final db = await database;
  return await db.query(
    'cart',
    where: 'user_id = ?',
    whereArgs: [userId],
  );
}

Future<int> updateCartItem(int id, double harga, String alamat) async {
  final db = await database;
  return await db.update(
    'cart',
    {
      'harga': harga,
      'alamat': alamat,
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

Future<int> clearCartByUser(int userId) async {
  final db = await database;
  return await db.delete(
    'cart',
    where: 'user_id = ?',
    whereArgs: [userId],
  );
}

Future<void> upsertAlamat(int userId, String alamat) async {
  final db = await database;

  // Cek apakah alamat untuk user_id sudah ada
  final existing = await db.query(
    'cart',
    where: 'user_id = ?',
    whereArgs: [userId],
  );

  if (existing.isEmpty) {
    // Insert alamat baru
    await db.insert('cart', {
      'user_id': userId,
      'alamat': alamat,
    });
    print('✅ Alamat baru ditambahkan untuk user_id=$userId');
  } else {
    // Update alamat yang sudah ada
    await db.update(
      'cart',
      {'alamat': alamat},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    print('✅ Alamat diperbarui untuk user_id=$userId');
  }
}




}

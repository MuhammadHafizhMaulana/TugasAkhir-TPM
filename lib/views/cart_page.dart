import 'package:flutter/material.dart';
import 'package:royal_clothes/db/database_helper.dart';
import 'package:royal_clothes/network/base_network.dart';
import 'package:royal_clothes/views/SettingsPage.dart';
import 'package:royal_clothes/views/appBar_page.dart';
import 'package:royal_clothes/views/sidebar_menu_page.dart';

class CartPage extends StatefulWidget {
  final int userId;

  const CartPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> _cartItems = [];
  double _total = 0.0;

  CurrencyOption _selectedCurrency = CurrencyOption.USD;
  final SettingsService _settingsService = SettingsService();
  final DBHelper _dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadCart();
    _loadCurrencySetting();
  }

  Future<void> _loadCurrencySetting() async {
    CurrencyOption currency = await _settingsService.loadCurrency();
    setState(() {
      _selectedCurrency = currency;
    });
  }

  Future<void> _loadCart() async {
  final cartData = await _dbHelper.getCartByUser(widget.userId);

  List<Map<String, dynamic>> fullCartItems = [];
  double total = 0.0;

  for (var cartItem in cartData) {
    try {
      print("📦 Mengambil detail produk ID: ${cartItem['product_id']}");
      final productDetail = await BaseNetwork.getDetalDataProduct('phones', cartItem['product_id']);
      print("✅ Detail produk berhasil: $productDetail");

      final productData = productDetail['data'];
      if (productData is Map<String, dynamic>) {
        final fullItem = {...cartItem, ...productData};
        fullCartItems.add(fullItem);
      } else {
        print("⚠️ 'data' bukan Map<String, dynamic>: ${productDetail['data'].runtimeType}");
        fullCartItems.add(cartItem); // fallback
      }

      final harga = (cartItem['harga'] as num?)?.toDouble() ?? 0.0;
      final jumlah = (cartItem['jumlah'] as int?) ?? 1;
      total += harga * jumlah;
    } catch (e) {
      print("❌ Gagal mengambil produk ID ${cartItem['product_id']}: $e");
      fullCartItems.add(cartItem); // fallback
    }
  }

  setState(() {
    _cartItems = fullCartItems;
    _total = total;
  });
}


  Future<void> _deleteCartItem(int id) async {
    final db = await DBHelper().database;
    await db.delete('cart', where: 'id = ?', whereArgs: [id]);
    await _loadCart();
  }

  Future<void> _clearCart() async {
    await DBHelper().clearCartByUser(widget.userId);
    await _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 98, 95, 95),
      appBar: AppbarPage(
        title: ("Your Cart"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Clear Cart"),
                  content: const Text("Are you sure you want to clear the cart?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
                  ],
                ),
              );

              if (confirm == true) {
                await _clearCart();
              }
            },
          ),
        ],
      ),
      drawer: SidebarMenu(),
      body: _cartItems.isEmpty
          ? const Center(child: Text("Cart is empty"))
          : ListView.builder(
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final item = _cartItems[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text("Nama Item: ${item['model'] ?? 'Unknown'}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatPrice((item['price'] ?? item['harga'])?.toDouble() ?? 0.0, _selectedCurrency)),
                        Text("Alamat: ${item['alamat'] ?? '-'}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteCartItem(item['id']),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.grey[200],
        child: Text(
          "Total Harga: Rp ${formatPrice(_total, _selectedCurrency)} ",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

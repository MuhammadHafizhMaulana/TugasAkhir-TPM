import 'package:flutter/material.dart';
import 'package:royal_clothes/views/SettingsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:royal_clothes/network/base_network.dart';
import 'package:royal_clothes/views/appBar_page.dart';
import 'package:royal_clothes/views/sidebar_menu_page.dart';
import 'package:royal_clothes/db/database_helper.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  final String endpoint;

  const DetailScreen({super.key, required this.id, required this.endpoint});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _detailData;
  String? _errorMessage;
  bool _isFavorited = false;

  CurrencyOption _selectedCurrency = CurrencyOption.USD;
  final SettingsService _settingsService = SettingsService();
  final DBHelper _dbHelper = DBHelper();

  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndInit();
    _loadCurrencySetting();
  }

  Future<void> _loadCurrencySetting() async {
    CurrencyOption currency = await _settingsService.loadCurrency();
    setState(() {
      _selectedCurrency = currency;
    });
  }

  Future<void> _loadUserIdAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      setState(() {
        _errorMessage = "User belum login.";
        _isLoading = false;
      });
      return;
    }

    setState(() {
      currentUserId = userId;
    });

    await _fetchDetailData();
    await _loadFavoriteStatus();
  }

  Future<void> _fetchDetailData() async {
    try {
      final data = await BaseNetwork.getDetalDataProduct(widget.endpoint, widget.id);
      setState(() {
        _detailData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFavoriteStatus() async {
    if (currentUserId == null) return;
    bool status = await _dbHelper.isFavorited(currentUserId!, widget.id);
    setState(() {
      _isFavorited = status;
    });
  }

  Future<void> _toggleFavorite() async {
    if (currentUserId == null) return;

    if (_isFavorited) {
      await _dbHelper.removeFavorite(currentUserId!, widget.id);
    } else {
      await _dbHelper.addFavorite(currentUserId!, widget.id);
    }

    bool status = await _dbHelper.isFavorited(currentUserId!, widget.id);
    setState(() {
      _isFavorited = status;
    });
  }

  Future<void> _addToCart() async {
    if (currentUserId == null || _detailData == null) return;

    final productId = _detailData!['data']['id'];
    final harga = (_detailData!['data']['price'].toDouble());

    try {
      await _dbHelper.addToCart(currentUserId!, productId, harga);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk berhasil dimasukkan ke keranjang.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan ke keranjang: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFF121212),
        appBar: AppbarPage(title: 'Detail Product', actions: []),
        drawer: SidebarMenu(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Color(0xFF121212),
        appBar: AppbarPage(title: 'Detail Product', actions: []),
        drawer: SidebarMenu(),
        body: Center(
          child: Text(
            _errorMessage!,
            style: TextStyle(color: Colors.redAccent, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppbarPage(title: 'Detail Product', actions: []),
      drawer: SidebarMenu(),
      body: _detailData == null
          ? Center(
              child: Text(
                "No detail data available",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_detailData!['data']['imageUrl'] != null)
                    Center(
                      child: Image.network(
                        _detailData!['data']['imageUrl'],
                        height: 250,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.broken_image, size: 100, color: Colors.grey),
                      ),
                    ),
                  SizedBox(height: 24),
                  Text(
                    _detailData!['data']['model'] ?? 'No Title',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Garamond',
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    _detailData!['data']['price'] != null
                        ? formatPrice((_detailData!['data']['price'] as num).toDouble(), _selectedCurrency)
                        : 'No Price',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'Garamond',
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorited ? Colors.red : Colors.white70,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                      ElevatedButton.icon(
                        onPressed: _addToCart,
                        icon: Icon(Icons.add_shopping_cart),
                        label: Text("Tambah"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    _detailData!['data']['brand'] ?? 'No description available.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontFamily: 'Garamond',
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

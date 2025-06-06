import 'package:flutter/material.dart';
import 'package:royal_clothes/views/SettingsPage.dart';
import 'package:royal_clothes/views/appBar_page.dart';
import 'package:royal_clothes/db/database_helper.dart';
import 'package:royal_clothes/models/product_model.dart';
import 'package:royal_clothes/network/base_network.dart';
import 'package:royal_clothes/views/detail_product_page.dart';
import 'package:royal_clothes/views/sidebar_menu_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePage extends StatefulWidget {
  final String endpoint;

  const FavoritePage({Key? key, required this.endpoint}) : super(key: key);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final DBHelper _dbHelper = DBHelper();
  List<Product> favoriteProductList = [];
  bool isLoading = false;
  String? errorMessage;
  int? userId;

  CurrencyOption _selectedCurrency = CurrencyOption.USD;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFavorites();
    _loadCurrencySetting();
  }

  Future<void> _loadCurrencySetting() async {
    CurrencyOption currency = await _settingsService.loadCurrency();
    setState(() {
      _selectedCurrency = currency;
    });
  }

  Future<void> _loadUserIdAndFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final int? savedUserId = prefs.getInt('userId');

    if (savedUserId == null) {
      setState(() {
        errorMessage = "User belum login.";
      });
      return;
    }

    setState(() {
      userId = savedUserId;
    });

    await _loadFavoriteProducts(savedUserId);
  }

  Future<void> _loadFavoriteProducts(int userId) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      favoriteProductList = [];
    });

    try {
      final favoriteProductIds = await _dbHelper.getFavoriteProductIdsByUser(userId);
      List<Product> products = [];

      for (var productId in favoriteProductIds) {
        try {
          final response = await BaseNetwork.getDetalDataProduct("phones", productId);
          final productJson = response['data']; // ambil objek pertama dalam array
          products.add(Product.fromJson(productJson));

        } catch (e) {
          print('❌ Gagal ambil data produk ID $productId: $e');
        }
      }

      setState(() {
        favoriteProductList = products;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Gagal memuat data favorit: $e";
        isLoading = false;
      });
    }
  }

  Widget productCard(Product product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              id: product.id,
              endpoint: widget.endpoint,
            ),
          ),
        ).then((_) {
          _loadUserIdAndFavorites(); // Refresh kembali ke halaman favorite
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                product.model,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Garamond',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                formatPrice(product.price, _selectedCurrency),
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Garamond',
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppbarPage(
        title: ('Favorite Products'),
      ),
      drawer: SidebarMenu(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                )
              : favoriteProductList.isEmpty
                  ? Center(
                      child: Text(
                        "Tidak ada produk favorit.",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.all(16),
                      child: GridView.builder(
                        itemCount: favoriteProductList.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 0.65,
                        ),
                        itemBuilder: (context, index) {
                          final product = favoriteProductList[index];
                          return productCard(product);
                        },
                      ),
                    ),
    );
  }
}

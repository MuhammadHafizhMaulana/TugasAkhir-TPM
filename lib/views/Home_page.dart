import 'package:flutter/material.dart';
import 'package:royal_clothes/presenters/product_presenter.dart';
import 'package:royal_clothes/models/product_model.dart';
import 'package:royal_clothes/views/SettingsPage.dart';
import 'package:royal_clothes/views/cart_page.dart';
import 'package:royal_clothes/views/sidebar_menu_page.dart';
import 'package:royal_clothes/views/appBar_page.dart';
import 'package:royal_clothes/views/detail_product_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> implements ProductView {
  late ProductPresenter presenter;
  List<Product> productList = [];
  List<Product> _filteredProducts = [];
  bool isLoading = false;
  String? errorMessage;
  CurrencyOption _selectedCurrency = CurrencyOption.USD;
  final SettingsService _settingsService = SettingsService();

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    presenter = ProductPresenter(this);
    presenter.loadProductData('phones');
    _loadCurrencySetting();
  }

  Future<void> _loadCurrencySetting() async {
    CurrencyOption currency = await _settingsService.loadCurrency();
    setState(() {
      _selectedCurrency = currency;
    });
  }

  void _filterSearchResults(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(productList);
      } else {
        _filteredProducts = productList
            .where((product) =>
                product.model.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void showProductList(List<Product> products) {
    setState(() {
      productList = products;
      _filteredProducts = List.from(products); // Set awal filter
      errorMessage = null;
    });
  }

  @override
  void showError(String message) {
    setState(() {
      errorMessage = message;
      productList = [];
      _filteredProducts = [];
    });
  }

  @override
  void showLoading() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppbarPage(
        title: 'Royal Phones',
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              int? userId = prefs.getInt('userId');

              if (userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartPage(userId: userId)),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("UserId tidak ditemukan!")),
                );
              }
            },
          ),
        ],
      ),
      drawer: SidebarMenu(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 🔍 Search TextField
                      TextField(
                        controller: _searchController,
                        onChanged: _filterSearchResults,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Cari produk...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search, color: Colors.white),
                          filled: true,
                          fillColor: const Color(0xFF2C2C2C),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ❌ Jika tidak ada hasil
                      if (_filteredProducts.isEmpty)
                        const Expanded(
                          child: Center(
                            child: Text(
                              "Produk tidak ditemukan",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        )
                      else
                        // ✅ Menampilkan Grid produk
                        Expanded(
                          child: GridView.builder(
                            itemCount: _filteredProducts.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 15,
                              crossAxisSpacing: 15,
                              childAspectRatio: 0.65,
                            ),
                            itemBuilder: (context, index) {
                              final product = _filteredProducts[index];
                              return productCard(product);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget productCard(Product product) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              id: product.id,
              endpoint: 'phones',
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                product.model,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Garamond',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                formatPrice(product.price, _selectedCurrency),
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: 'Garamond',
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:royal_clothes/presenters/product_presenter.dart';
import 'package:royal_clothes/models/product_model.dart';
import 'package:royal_clothes/views/appBar_page.dart';
import 'package:royal_clothes/views/sidebar_menu_page.dart';
import 'package:royal_clothes/views/detail_product_page.dart';


class CategoryPage extends StatefulWidget {
  final String initialCategory;

  CategoryPage({required this.initialCategory});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> implements ProductView {
  late ProductPresenter presenter;
  List<Product> productList = [];
  bool isLoading = false;
  String? errorMessage;

  // List kategori yang bisa dipilih user
  final List<String> categories = [ "men's clothing", "women's clothing", "jewelery"];

  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
    presenter = ProductPresenter(this);
    loadCategoryProducts();
  }

  void loadCategoryProducts() {
    showLoading();
    // Panggil presenter method load produk berdasarkan kategori terpilih
    presenter.loadProductDataByCategory('products', selectedCategory);
  }

  void onCategoryChanged(String? newCategory) {
    if (newCategory != null && newCategory != selectedCategory) {
      setState(() {
        selectedCategory = newCategory;
        productList = [];
        errorMessage = null;
      });
      loadCategoryProducts();
    }
  }

  @override
  void showProductList(List<Product> products) {
    setState(() {
      productList = products;
      errorMessage = null;
      isLoading = false;
    });
  }

  @override
  void showError(String message) {
    setState(() {
      errorMessage = message;
      productList = [];
      isLoading = false;
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
      backgroundColor: Color(0xFF121212),
      appBar: AppbarPage(
        title: 'Category: $selectedCategory',
        actions: [],
      ),
      drawer: SidebarMenu(),
      body: Column(
        children: [
          // Dropdown pemilihan kategori
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color(0xFF2C2C2C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              dropdownColor: Color(0xFF2C2C2C),
              iconEnabledColor: Colors.white,
              style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Garamond'),
              items: categories
                  .map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat[0].toUpperCase() + cat.substring(1)),
                      ))
                  .toList(),
              onChanged: onCategoryChanged,
            ),
          ),

          // Expanded konten produk
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage != null
                    ? Center(
                        child: Text(
                          errorMessage!,
                          style: TextStyle(color: Colors.redAccent, fontSize: 16),
                        ),
                      )
                    : productList.isEmpty
                        ? Center(
                            child: Text(
                              "No products in this category",
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: GridView.builder(
                              itemCount: productList.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 15,
                                crossAxisSpacing: 15,
                                childAspectRatio: 0.65,
                              ),
                              itemBuilder: (context, index) {
                                final product = productList[index];
                                return productCard(product);
                              },
                            ),
                          ),
          ),
        ],
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
              endpoint: 'products', // atau gunakan variabel endpoint jika ada
            ),
          ),
        );
      },
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
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image, size: 50, color: Colors.grey),
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
              'Rp${product.price.toStringAsFixed(0)}',
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
    );
  }
}

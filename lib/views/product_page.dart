import 'package:flutter/material.dart';
import 'package:royal_clothes/models/product_model.dart';
import 'package:royal_clothes/presenters/product_presenter.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> implements ProductView {
  late ProductPresenter presenter;
  List<Product> products = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    presenter = ProductPresenter(this);
    presenter.loadProductData("phones"); // wajib kasih endpoint
  }

  @override
  void showLoading() {
    setState(() {
      isLoading = true;
      error = null;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  void showProductList(List<Product> productList) {
    setState(() {
      products = productList;
      error = null;
    });
  }

  @override
  void showError(String message) {
    setState(() {
      error = message;
      products = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(child: Text('Error: $error'))
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: Image.network(
                          product.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image),
                        ),
                        title: Text(product.model),
                        subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                      ),
                    );
                  },
                ),
    );
  }
}

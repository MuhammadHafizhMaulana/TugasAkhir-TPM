import 'package:royal_clothes/models/product_model.dart';
import 'package:royal_clothes/network/base_network.dart';

abstract class ProductView {
  void showLoading();
  void hideLoading();
  void showProductList(List<Product> productList);
  void showError(String message);
}

class ProductPresenter {
  final ProductView view;
  ProductPresenter(this.view);

  Future<void> loadProductData(String endpoint) async {
    try {
      view.showLoading();

      final List<dynamic> data = await BaseNetwork.getDataProduct(endpoint);

      final productList = data.map((json) => Product.fromJson(json)).toList();

      view.showProductList(productList);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }

    // Method baru untuk load produk berdasarkan kategori
  Future<void> loadProductDataByCategory(String endpoint, String category) async {
    try {
      view.showLoading();

      final List<Product> filteredProducts =
          await BaseNetwork.getDataProductByBrand(endpoint, category);

      view.showProductList(filteredProducts);
    } catch (e) {
      view.showError(e.toString());
    } finally {
      view.hideLoading();
    }
  }
}




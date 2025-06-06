import "dart:convert";


import "package:http/http.dart" as http;
import "package:royal_clothes/models/product_model.dart";

class BaseNetwork {
  static const String baseUrl =
      "https://tpm-api-responsi-e-f-872136705893.us-central1.run.app/api/v1"; //base URL for the API

  //Mengambil semua data Produk
  static Future<List<dynamic>> getDataProduct(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    print("RESPONSE STATUS: ${response.statusCode}");
    print("RESPONSE BODY: ${response.body}");

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    return jsonResponse['data'];
  } else {
    throw Exception(
      "Failed to load data Error: ${response.statusCode}",
      ); // Throw an exception if the request fails
    }
  }

  //Mengambil data Produk base ID
  static Future<Map<String, dynamic>> getDetalDataProduct(
    String endpoint,
    int id,
  ) async {
    final url = Uri.parse('$baseUrl/$endpoint/$id');
    print("🔎 Requesting detail from: $url");
    final response = await http.get(url);
    print("🔽 Status Code: ${response.statusCode}");
    print("📦 Response Body: ${response.body}");
    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Decode the JSON response
    } else {
      throw Exception(
        "Failed to load detail data",
      ); // Throw an exception if the request fails
    }
  }

  //Mengambil data Produk berdasarkan kategori namun tidak ada api khususnya
  static Future<List<Product>> getDataProductByBrand(
  String endpoint,
  String brand,
) async {
  final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    List<dynamic> data = jsonResponse["data"];

    List<Product> allProducts =
        data.map((product) => Product.fromJson(product)).toList();

    List<Product> filteredProducts =
        allProducts.where((product) => product.brand == brand).toList();

    return filteredProducts;
  } else {
    throw Exception("Failed to load data by category");
  }
}


}

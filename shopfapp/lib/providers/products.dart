// import 'package:flutter/scheduler.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';
import '../models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red',
    //   price: 30.32,
    //   imageUrl:
    //       'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQD-dOJiA2XM8rPSsE1pWzpHga-Qe4Z5uHSaA&usqp=CAU',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'yellow shirt',
    //   description: 'A yellow shirt - it is pretty Yellow',
    //   price: 30.32,
    //   imageUrl:
    //       'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcS8XgYZS1DLZt7lwEO3mxbbbza5LzoAIRIQuw&usqp=CAU',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'green Shirt',
    //   description: 'A green shirt - it is pretty Green',
    //   price: 30.32,
    //   imageUrl:
    //       'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSzpHKXHH2XdxrOWvuqLxduW6Q5YdIqshh2fQ&usqp=CAU',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'Block Shirt',
    //   description: 'A Block shirt - it is pretty Block',
    //   price: 30.32,
    //   imageUrl:
    //       'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcQ7oLsI3jbPaFNu3uU-imLKupbVSOz-lhWTuA&usqp=CAU',
    // ),
    // Product(
    //   id: 'p5',
    //   title: 'mix Shade  Shirt',
    //   description: 'A mix Shade shirt - it is pretty Orenge',
    //   price: 30.32,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/Tennis-shirt-lacoste.jpg/220px-Tennis-shirt-lacoste.jpg',
    // ),
  ];
  // var _showFavoritesOnly = false;
  final String authToken;
  final String userId;
  // recive the token here
  Products(
    this.authToken,
    this.userId,
    this._items,
  );

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }
  Future<void> fetchAndSetProduct([bool filterByUser = false]) async {
    //  filtering the users logic
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://shopfapp-ff763.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      final extractData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractData == null) {
        return;
      }

      url =
          'https://shopfapp-ff763.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      extractData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          // isFavorite: prodData['isFavorite'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://shopfapp-ff763.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'creatorId': userId,
          // 'isFavorite': product.isFavorite,
        }),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        id: json.decode(response.body)['name'],
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      // _items.insert(0, newProduct); // at the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }

    // print(json.decode(response.body));

    // print(error);
    // throw error;
  }

  Future<void> updateProducts(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    if (productIndex >= 0) {
      final url =
          'https://shopfapp-ff763.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      print('hiii');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://shopfapp-ff763.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(
        existingProductIndex,
        existingProduct,
      );
      notifyListeners();
      throw HttpException('Could not delete product!');
    }
    existingProduct = null;
  }
}

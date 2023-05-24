import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Models/http_exception.dart';
import './Product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<product> _items = [
    // product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavoritesOnly = false;

  final String authToken;

  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items];
  }

  List<product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  product findById(String id) {
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

//following function gets products from database
//using ?auth=$authToken to send the auth token of the user.
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    //using bool as argument in function to display all the products in home screen but in manage products screen show only the products created by that user
    //sending true as an argument in user products screen to only filter products in that screen
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';

    var url = Uri.parse(
        'https://shop-app-8a080-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');

    try {
      final response = await http.get(url);

      //converting the fetched data into useable form
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      //checking if the products are available or not on database or not
      if (extractedData == null) {
        return;
      }

      //Sending request to get the favorite status for that specific user
      url = Uri.parse(
          'https://shop-app-8a080-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');

      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);

      //storing the fetched data in the list
      final List<product> loadedProducts = [];

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[prodId] ?? false,
          ),
        );
      });

      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(product Prod) async {
    //sending requests to database to store data of our new created product
    final url = Uri.parse(
        'https://shop-app-8a080-default-rtdb.firebaseio.com/products.json?auth=$authToken');

    //first we used future statement and then statement and catch erron and the we used async and wait instead of it because it is a more easy and clean approach
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': Prod.title,
          'description': Prod.description,
          'imageUrl': Prod.imageUrl,
          'price': Prod.price,
          'creatorId': userId,
        }),
      );
      final newProduct = product(
        //setting id according to the id in database
        id: json.decode(response.body)['name'],
        title: Prod.title,
        description: Prod.description,
        price: Prod.price,
        imageUrl: Prod.imageUrl,
      );
      _items.add(newProduct);
      //_items.insert(0, newProduct); to insert at the start
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  //updating/editing product on database
  Future<void> updateProduct(String id, product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);

    if (prodIndex >= 0) {
      //fetching products here with respect to user Id. it will fetch the products created by that user
      final url = Uri.parse(
          'https://shop-app-8a080-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken'); // store it in seprate variable for re useablity

      //sending http request to edit data on firebase
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));

      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  //deleting the product while using optimistic approach
  Future<void> deleteproduct(String id) async {
    final url = Uri.parse(
        'https://shop-app-8a080-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

    //storing the index of the product and then removing it
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);

    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      //if the product is not deleted in database than inserting it again in our products list
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Failed to delete product');
    }

    //if the delete is successfull in database then making the existing product null
    existingProduct = null;
  }
}


//Please learn error status codes
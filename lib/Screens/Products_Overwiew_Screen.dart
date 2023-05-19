import 'package:flutter/material.dart';
import '../Providers/products.dart';
import '../Providers/cart.dart';
import '../Widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import './cart_screen.dart';

import '../Widgets/products_grid.dart';
import '../Widgets/badge.dart';

enum popupMenuOPtions {
  favoriteItems,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  //using fetchAndSet function here to fetch products from database using provider from products.dart

  @override
  void initState() {
    //Provider.of<Products>(context).fetchAndSetProducts();
    //won't work huere so, we have to use didChangeDependencies to implement it
    //It will work if we set listen: false. Then it will work

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }

    _isInit = false;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Shop"),
        actions: [
          PopupMenuButton(
            onSelected: (popupMenuOPtions selectedValue) {
              setState(
                () {
                  if (selectedValue == popupMenuOPtions.favoriteItems) {
                    _showOnlyFavorites = true;
                  } else {
                    _showOnlyFavorites = false;
                  }
                },
              );
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text("Favorites"),
                value: popupMenuOPtions.favoriteItems,
              ),
              PopupMenuItem(
                child: Text("All items"),
                value: popupMenuOPtions.all,
              ),
            ],
            icon: Icon(Icons.more_vert),
          ),
          // provider is used here because we only want a change in out cart icon
          Consumer<Cart>(
            builder: (_, cartData, ch) => Badge(
              //ch here represents the icon button below. It is defined outside so that it does not rebuild whenever the change occur
              child: ch,
              value: cartData.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(
                Icons.shopping_cart,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}

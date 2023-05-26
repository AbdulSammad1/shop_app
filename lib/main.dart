import 'package:flutter/material.dart';
import './Screens/Products_Overwiew_Screen.dart';
import './Screens/splash_screen.dart';
import './Providers/auth.dart';
import './Screens/user_product_screen.dart';
import './Providers/orders.dart';
import './Providers/cart.dart';
import 'package:provider/provider.dart';
import './Screens/Product_Detail_Screen.dart';
import './Providers/products.dart';
import './Screens/cart_screen.dart';
import './Screens/orders_screen.dart';
import './Screens/edit_product_screen.dart';
import './Screens/auth_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        //using auth provider here to use authorization
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        //using changenotifierProxyProvider here to pass token in products through auth
        ChangeNotifierProxyProvider<Auth, Products>(
          update: (ctx, auth, previousProducts) => Products(
              auth.Token,
              auth.UserId,
              previousProducts == null ? [] : previousProducts.items),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        //using changenotifierProxyProvider here to pass token in order through auth
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrders) => Orders(auth.Token, auth.UserId,
              previousOrders == null ? [] : previousOrders.orders),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: "Shop_App",
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey)
                .copyWith(secondary: Color.fromARGB(222, 220, 161, 60)),
            // fontFamily: 'Lato',
          ),
          debugShowCheckedModeBanner: false,
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductScreen.routeName: (ctx) => UserProductScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_complete_guide/Providers/auth.dart';
import '../Providers/cart.dart';
import '../Providers/Product.dart';
import 'package:provider/provider.dart';
import '../Screens/Product_Detail_Screen.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final productHolder = Provider.of<product>(context, listen: false);
    final cartData = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                ProductDetailScreen.routeName,
                arguments: productHolder.id,
              );
            },

            //Hero is an animation used here and in products detail screen
            child: Hero(
              tag: productHolder.id,
              //here fadeInImage is an animation it will show a placeholder image while real image is loading
              child: FadeInImage(
                placeholder: AssetImage('assets/product-placeholder.png'),
                image: NetworkImage(productHolder.imageUrl),
                fit: BoxFit.cover,
              ),
            )),
        footer: GridTileBar(
          backgroundColor: Colors.black45,
          leading: Consumer<product>(
            builder: (ctx, productHolder, _) => IconButton(
              icon: Icon(
                productHolder.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              onPressed: () {
                productHolder.toggleFavoriteStatus(
                    authData.Token, authData.UserId);
              },
              color: Theme.of(context).accentColor,
            ),
          ),
          title: Text(
            productHolder.title,
            textAlign: TextAlign.center,
            // style: TextStyle(
            //   fontSize: 18,
            //   fontWeight: FontWeight.bold,
            // ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              cartData.addItem(
                  productHolder.id, productHolder.price, productHolder.title);

              //this will hide the previous snackbar before showing up the new one.
              Scaffold.of(context).hideCurrentSnackBar();
              //below code is used to show a popup message through snackbar widget
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Item Added Successfully',
                  ),
                  duration: Duration(seconds: 2),
                  //displaying undo action in snackbar to undo our recently performed action
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      cartData.removeSingleItem(productHolder.id);
                    },
                  ),
                ),
              );
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}

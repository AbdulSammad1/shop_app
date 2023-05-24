import 'package:flutter/material.dart';

// used show below because we had two classes of the same name CartItem. so, to differentiate between them, we used show and then give it the name
import '../Widgets/cart_item.dart';
import '../Providers/cart.dart' show Cart;
import 'package:provider/provider.dart';
import '../Providers/orders.dart';

class CartScreen extends StatelessWidget {
  //route name
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Cart"),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cartData.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Theme.of(context)
                            .primaryTextTheme
                            .headline6
                            .color, //!depreciated
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  OrderButton(cartData: cartData),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: cartData.items.length,
              itemBuilder: (ctx, i) => cartItem(
                //so here we used values.toList() because our items are actually a Map (stored in a map as defined in the cart class) so that is why we want to use .values and then convert them to list so that we get their values
                cartData.items.values.toList()[i].id,
                //the key used below is used because of productId we passed in cart item,
                cartData.items.keys.toList()[i],
                cartData.items.values.toList()[i].price,
                cartData.items.values.toList()[i].quantity,
                cartData.items.values.toList()[i].title,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cartData,
  }) : super(key: key);

  final Cart cartData;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : FlatButton(
            //deprecated
            //checking if our cart is empty than disbaling the button else enabling it
            onPressed: (widget.cartData.totalAmount <= 0 ||
                    _isLoading) //implement business logic in separate file not in UI file
                ? null
                : () async {
                    //
                    setState(() {
                      _isLoading = true;
                    });

                    //passing values to addOrder function through cart Provider
                    await Provider.of<Orders>(context, listen: false).addOrder(
                        //using tolist here to convert the map into list
                        widget.cartData.items.values.toList(),
                        widget.cartData.totalAmount);

                    //
                    setState(() {
                      _isLoading = false;
                    });

                    widget.cartData.clear();
                  },
            child: Text('Order Now'),
            textColor: Theme.of(context).primaryColor,
          );
  }
}

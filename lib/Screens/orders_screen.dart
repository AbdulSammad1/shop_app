import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//as we only had to use Orders from orders.dart and to avoid clash as the OrderItem class is used in both orders.dart and order_item.dart
import '../Providers/orders.dart' show Orders;

import '../Widgets/order_item.dart';
import '../Widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  var _isLoading = false; // no need to add _

  //Here we will fetch orders using Future Builder method which is a more elegant method

  Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  //we have done these steps to avoid building our orders again and again in case if the widgets rebuilds
  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //to avoid infinite loop we will not use the below statement here
    //final orderData = Provider.of<Orders>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text("Your Orders"),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: _ordersFuture,
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapshot.error != null) {
                //
                return Center(
                  child: Text('An error occured'),
                );
              } else {
                //using provider package here instead of above to use only one time
                return Consumer<Orders>(
                  builder: (ctx, orderData, child) => ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                  ),
                );
              }
            }
          },
        )); //! add colon to make code more read able
  }
}

import 'package:flutter/material.dart';
import '../Providers/products.dart';
import 'package:provider/provider.dart';
import '../Screens/edit_product_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  UserProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(children: [
          IconButton(
            icon: Icon(Icons.edit),
            color: Theme.of(context).primaryColor,
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditProductScreen.routeName, arguments: id);
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            color: Theme.of(context).errorColor,
            onPressed: () async {
              //checking for if the item is deleted or not and showing error. logic written in products.dart

              try {
                await Provider.of<Products>(context, listen: false)
                    .deleteproduct(id);
              } catch (e) {
                scaffold.showSnackBar(
                  SnackBar(
                    content: Text('Deleting failed'),
                  ),
                );
              }
            },
          ),
        ]),
      ),
    );
  }
}

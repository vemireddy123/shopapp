import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';
import '../providers/orders.dart' show Orders;

class OrderScreen extends StatelessWidget {
  static const routeName = '/orders';

  // @override
  // _OrderScreenState createState() => _OrderScreenState();
// }

// class _OrderScreenState extends State<OrderScreen> {
  // var _isLoading = false;
 
  // @override
  // void initState() {
  //   //'''''''''''''''''''''''''''''''''''''''''
  //   //Old code Start
  //   //'''''''''''''''''''''''''''''''''''''''''
  //   // Future.delayed(Duration.zero).then(
  //   //   (_) async {
  //   //     setState(
  //   //       () {
  //   //         _isLoading = true;
  //   //       },
  //   //     );
  //   //     await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  //   //     setState(() {
  //   //       _isLoading = false;
  //   //     });
  //   //   },
  //   // );
  //   //''''''''''''''''''''''''''''''''''''''''''''
  //   // Old code end
  //   //''''''''''''''''''''''''''''''''''''''''''''

  //   //''''''''''''''''''''''''''''''''''''''''''''
  //   // New code Start
  //   //''''''''''''''''''''''''''''''''''''''''''''
  //   // _isLoading = true;
  //   // Provider.of<Orders>(context, listen: false).fetchAndSetOrders().then((_) {
  //   //   setState(() {
  //   //     _isLoading = false;
  //   //   });
  //   // });

  //   //''''''''''''''''''''''''''''''''''''''''''''
  //   // New code end
  //   //''''''''''''''''''''''''''''''''''''''''''''

  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // final ordersData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (context, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapshot.error != null) {
              // erro handlind stuff
              return Center(
                child: Text('An errr occurred!'),
              );
            } else {
              return Consumer<Orders>(builder: (context, ordersData, child) => ListView.builder(
                itemCount: ordersData.orders.length,
                itemBuilder: (context, i) => OrderItem(
                  ordersData.orders[i],
                ),
              ), );
              
            }
          }
        },
      ),
    );
  }
}

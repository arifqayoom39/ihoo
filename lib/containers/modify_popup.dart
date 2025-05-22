import 'package:flutter/material.dart';
import 'package:ihoo/containers/additional_confirm.dart';
import 'package:ihoo/controllers/db_service.dart';
import 'package:ihoo/models/orders_model.dart';

class ModifyPopup extends StatelessWidget {
  final OrdersModel order;
  const ModifyPopup({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildDialogContent(context),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 60.0,
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          margin: EdgeInsets.only(top: 40.0),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Modify Order",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                "Choose what you want to do",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
              SizedBox(height: 20.0),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => AdditionalConfirm(
                            contentText:
                                "After canceling, this cannot be changed. You need to order again.",
                            onYes: () async {
                              await DbService().updateOrderStatus(
                                  orderId: order.id,
                                  statusData: {"status": "CANCELLED"});
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Order Updated")),
                              );
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            onNo: () {
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                      child: Text(
                        "Cancel Order",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.0),
                    ElevatedButton(
                      onPressed: () {
                        // Add any functionality for "Modify Order" if necessary
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: Text(
                        "Modify Order",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 16.0,
          right: 16.0,
          child: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            radius: 30.0,
            child: Icon(
              Icons.edit_outlined,
              color: Colors.white,
              size: 22.0,
            ),
          ),
        ),
      ],
    );
  }
}

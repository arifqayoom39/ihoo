import 'package:ihoo/contants/discount.dart';
import 'package:ihoo/models/cart_model.dart';
import 'package:ihoo/providers/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartContainer extends StatefulWidget {
  final String image, name, productId;
  final int new_price, old_price, maxQuantity, selectedQuantity;

  const CartContainer({
    super.key,
    required this.image,
    required this.name,
    required this.productId,
    required this.new_price,
    required this.old_price,
    required this.maxQuantity,
    required this.selectedQuantity,
  });

  @override
  State<CartContainer> createState() => _CartContainerState();
}

class _CartContainerState extends State<CartContainer> {
  int count = 1;

  // Increase the count with the max quantity constraint
  increaseCount(int max) async {
    if (count >= max) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Maximum Quantity reached"),
        ),
      );
    } else {
      Provider.of<CartProvider>(context, listen: false)
          .addToCart(CartModel(productId: widget.productId, quantity: count));
      setState(() {
        count++;
      });
    }
  }

  // Decrease the count with a minimum of 1 constraint
  decreaseCount() async {
    if (count > 1) {
      Provider.of<CartProvider>(context, listen: false)
          .decreaseCount(widget.productId);
      setState(() {
        count--;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    count = widget.selectedQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.image,
                height: 100,
                width: 100,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          Provider.of<CartProvider>(context, listen: false)
                              .deleteItem(widget.productId);
                        },
                        icon: Icon(Icons.delete_outline),
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "₹${widget.new_price}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "₹${widget.old_price}",
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                        ),
                        child: Text(
                          "${discountPercent(widget.old_price, widget.new_price)}% off",
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: decreaseCount,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.remove, size: 16),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                count.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => increaseCount(widget.maxQuantity),
                              child: Container(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.add, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                    
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:appwrite/models.dart';
import 'package:ihoo/controllers/db_service.dart';
import 'package:ihoo/models/orders_model.dart';
import 'package:ihoo/providers/cart_provider.dart';
import 'package:ihoo/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:ihoo/widgets/address_form_dialog.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:ihoo/widgets/payment_status_dialog.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  TextEditingController _couponController = TextEditingController();
  int discount = 0;
  int toPay = 0;
  String discountText = "";
  bool paymentSuccess = false;
  bool isLoading = true;
  bool isCalculatingTotal = true;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadData();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // Simulate loading of data
  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isLoading = false;
      isCalculatingTotal = false;
    });
  }

  // Function to calculate discount
  discountCalculator(int disPercent, int totalCost) {
    setState(() {
      discount = (disPercent * totalCost) ~/ 100;
      isCalculatingTotal = false;
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PaymentStatusDialog(
          isSuccess: true,
          message: "Your payment was successful! Your order has been placed and will be delivered soon. Thank you for shopping with us!",
          onClose: () async {
            Navigator.pop(context); // Close dialog

            // Process the order
            final user = Provider.of<UserProvider>(context, listen: false);
            final cart = Provider.of<CartProvider>(context, listen: false);
            final userId = await DbService().getUserId();
            List<OrderProductModel> products = [];

            for (int i = 0; i < cart.products.length; i++) {
              products.add(OrderProductModel(
                id: cart.products[i].id,
                name: cart.products[i].name,
                image: cart.products[i].image,
                quantity: cart.carts[i].quantity,
                single_price: cart.products[i].new_price,
                total_price: cart.products[i].new_price * cart.carts[i].quantity,
              ));
            }

            OrdersModel orderData = OrdersModel(
              id: 'unique()',
              user_id: userId!,
              name: user.name,
              email: user.email,
              address: user.address,
              phone: user.phone,
              discount: discount,
              total: cart.totalCost - discount,
              products: products,
              status: 'PAID',
              created_at: DateTime.now().millisecondsSinceEpoch,
            );

            await DbService().createOrder(orderData: orderData);

            for (int i = 0; i < cart.products.length; i++) {
              await DbService().reduceQuantity(
                  productId: cart.products[i].id, quantity: cart.carts[i].quantity);
            }

            await DbService().emptyCart();
            paymentSuccess = true;
            
            // Navigate back to home/previous screen
            Navigator.of(context).popUntil((route) => route.isFirst);

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Payment Successful", style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
            ));
          },
        );
      },
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PaymentStatusDialog(
          isSuccess: false,
          message: "We couldn't process your payment. Please check your payment details and try again.",
          onClose: () {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Close checkout page
          },
        );
      },
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("External Wallet Selected: ${response.walletName}"),
    ));
  }

  void startPayment(int amount) {
    var options = {
      'key': 'rzp.....',  // Replace with your Razorpay key
      'amount': amount * 100, // Amount in paisa
      'name': 'Ihoo',
      'description': 'Order Payment',
      'prefill': {
        'contact': Provider.of<UserProvider>(context, listen: false).phone,
        'email': Provider.of<UserProvider>(context, listen: false).email,
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(fontSize: 18, color: Colors.white)),
        backgroundColor: Colors.blue.shade500,
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blue.shade500),
                  const SizedBox(height: 16),
                  Text("Loading checkout details...", 
                    style: TextStyle(color: Colors.grey.shade600))
                ],
              ))
          : Consumer<UserProvider>(
              builder: (context, userData, child) => Consumer<CartProvider>(
                builder: (context, cartData, child) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Delivery Address Section
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Delivery Address", 
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade800
                                    )),
                                  TextButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => const AddressFormDialog(),
                                      ).then((_) {
                                        // Refresh user data after dialog is closed
                                        Provider.of<UserProvider>(context, listen: false).loadUserData();
                                      });
                                    },
                                    child: Text("CHANGE",
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500
                                      )),
                                  )
                                ],
                              ),
                              const Divider(),
                              Text(userData.name,
                                style: const TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(userData.address,
                                style: TextStyle(color: Colors.grey.shade700)),
                              const SizedBox(height: 4),
                              Text(userData.phone,
                                style: TextStyle(color: Colors.grey.shade700)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Price Details Section
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("PRICE DETAILS",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800
                                )),
                              const SizedBox(height: 16),
                              isCalculatingTotal
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blue.shade500,
                                    ))
                                : Column(
                                    children: [
                                      _priceRow(
                                        "Price (${cartData.totalQuantity} items)",
                                        "₹${cartData.totalCost}"
                                      ),
                                      const SizedBox(height: 8),
                                      _priceRow(
                                        "Discount",
                                        "- ₹$discount",
                                        discountColor: Colors.green
                                      ),
                                      const SizedBox(height: 8),
                                      _priceRow(
                                        "Delivery Charges",
                                        "FREE",
                                        rightTextColor: Colors.green
                                      ),
                                      const Divider(height: 24),
                                      _priceRow(
                                        "Total Amount",
                                        "₹${cartData.totalCost - discount}",
                                        isBold: true
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "You will save ₹$discount on this order",
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500
                                        ),
                                      )
                                    ],
                                  ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Coupon Section
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.local_offer_outlined,
                                    color: Colors.green),
                                  SizedBox(width: 8),
                                  Text("Apply Coupon",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500
                                    )),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _couponController,
                                textCapitalization: TextCapitalization.characters,
                                decoration: InputDecoration(
                                  hintText: "Enter Coupon Code",
                                  border: const OutlineInputBorder(),
                                  suffixIcon: TextButton(
                                    onPressed: () async {
                                      setState(() {
                                        isCalculatingTotal = true;
                                      });

                                      List<Document> querySnapshot = await DbService().verifyDiscount(code: _couponController.text.toUpperCase());

                                      if (querySnapshot.isNotEmpty) {
                                        Document doc = querySnapshot.first;
                                        String code = doc.data['code'];
                                        int percent = doc.data['discount'];

                                        discountText = "A discount of $percent% has been applied.";
                                        discountCalculator(percent, cartData.totalCost);
                                      } else {
                                        discountText = "No discount code found";
                                        setState(() {
                                          isCalculatingTotal = false;
                                        });
                                      }
                                    },
                                    child: Text("APPLY",
                                      style: TextStyle(
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w500
                                      )),
                                  ),
                                ),
                              ),
                              if (discountText.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(discountText,
                                    style: TextStyle(
                                      color: discount > 0 ? Colors.green : Colors.red
                                    )),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("₹${Provider.of<CartProvider>(context).totalCost - discount}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    )),
                  Text("View price details",
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      decoration: TextDecoration.underline
                    )),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  final user = Provider.of<UserProvider>(context, listen: false);
                  if (user.address.isEmpty || user.phone.isEmpty || user.name.isEmpty || user.email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill your delivery details.")));
                    return;
                  }
                  final cart = Provider.of<CartProvider>(context, listen: false);
                  startPayment(cart.totalCost - discount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade500,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text("PLACE ORDER"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {
    bool isBold = false,
    Color? rightTextColor,
    Color? discountColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
            color: Colors.grey.shade800
          )),
        Text(value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w500 : FontWeight.normal,
            color: rightTextColor ?? discountColor ?? Colors.grey.shade800
          )),
      ],
    );
  }
}





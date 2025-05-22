import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class PaymentStatusDialog extends StatelessWidget {
  final bool isSuccess;
  final String message;
  final VoidCallback onClose;

  const PaymentStatusDialog({
    Key? key,
    required this.isSuccess,
    required this.message,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              isSuccess
                  ? 'assets/images/payment-success.json'
                  : 'assets/images/payment-failed.json',
              width: 150,
              height: 150,
              repeat: isSuccess ? false : true,
            ),
            SizedBox(height: 20),
            Text(
              isSuccess ? 'Payment Successful!' : 'Payment Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? Colors.green : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: Text(
                isSuccess ? 'Great!' : 'Try Again',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

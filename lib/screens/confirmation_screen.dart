// lib/screens/confirmation_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:telebirr/models/transaction.dart';
import 'package:telebirr/screens/pdf_utils.dart';
import 'package:telebirr/services/db_helper.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  ConfirmationScreenState createState() => ConfirmationScreenState();
}

class ConfirmationScreenState extends State<ConfirmationScreen> {
  static const Color lightGreen = Color(0xFF8BC83D);

  // Generated once per screen instance
  final DateTime transactionTime = DateTime.now();
  final String transactionNumber = _generateTransactionNumber();

  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_pageController.hasClients) {
        int next = _currentPage + 1;
        if (next >= _carouselImages.length) next = 0;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  static String _generateTransactionNumber() {
    const length = 10;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    String txn = 'C';
    for (var i = 1; i < length; i++) {
      txn += chars[rand.nextInt(chars.length)];
    }
    return txn;
  }

  /// Calculates the service fee based on the transaction amount.
  double _calculateServiceFee(double amount) {
    const double vatRate = 0.15;
    if (amount < 1) {
      return 0.0;
    } else if (amount <= 50) {
      return 0.0;
    } else if (amount <= 100) {
      return 1.0 / (1 + vatRate);
    } else if (amount <= 300) {
      return 2.0 / (1 + vatRate);
    } else if (amount <= 500) {
      return 4.0 / (1 + vatRate);
    } else if (amount <= 1000) {
      return 5.0 / (1 + vatRate);
    } else if (amount <= 3000) {
      return 7.0 / (1 + vatRate);
    } else if (amount <= 5000) {
      return 9.0 / (1 + vatRate);
    } else if (amount <= 8000) {
      return 12.0 / (1 + vatRate);
    } else {
      return 0.0;
    }
  }

  final List<String> _carouselImages = [
    'assets/images/financial_services8.png',
    'assets/images/financial_services6.png',
    'assets/images/financial_services2.png',
    'assets/images/financial_services3.png',
    'assets/images/financial_services4.png',
  ];

  Widget _buildCarousel() {
    return Column(
      children: [
        Container(
          height: 110,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
          child: PageView.builder(
            controller: _pageController,
            itemCount: _carouselImages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder:
                (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(_carouselImages[i], fit: BoxFit.cover),
                  ),
                ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_carouselImages.length, (i) {
            final active = _currentPage == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: active ? 10 : 6,
              height: active ? 10 : 6,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: lightGreen, width: 1),
                shape: BoxShape.circle,
              ),
              child:
                  active
                      ? Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: lightGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                      : null,
            );
          }),
        ),
      ],
    );
  }

  String formatAmount(double amount) => amount.toStringAsFixed(2);

  String formatDateTime(DateTime dt) =>
      DateFormat('yyyy/MM/dd HH:mm:ss').format(dt);

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ??
        {};
    final double amount =
        double.tryParse(args['amount']?.toString() ?? '0.0') ?? 0.0;
    final String recipientName = args['name'] ?? 'Unknown Recipient';
    final String phone = args['phone'] ?? '';
    final String note = args['note'] ?? '';

    final String formattedTime = formatDateTime(transactionTime);

    final double serviceFee = _calculateServiceFee(amount);
    const double vatRate = 0.15;
    final double vatAmount = serviceFee * vatRate;
    final double totalAmount = amount + serviceFee + vatAmount;

    // Prepare data for PDF and DB
    final transactionData = {
      'transactionNumber': transactionNumber,
      'receiptNumber': transactionNumber,
      'transactionTime': formattedTime,
      'amount': formatAmount(amount),
      'accountNumber': phone,
      'name': recipientName,
      'discountAmount': '0.00',
      'serviceFee': formatAmount(serviceFee),
      'vatAmount': formatAmount(vatAmount),
    };

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.download_outlined, color: lightGreen),
              label: const Text(
                'Download',
                style: TextStyle(color: lightGreen),
              ),
              onPressed: () async {
                final pdfPath = await editAndSaveConfirmationPdf(
                  transactionData,
                  context,
                );
                if (pdfPath.isNotEmpty) {
                  final record = TransactionRecord(
                    type: 'Transfer Money',
                    amount: amount,
                    currency: '(ETB)',
                    counterparty: recipientName,
                    timestamp: formattedTime,
                    pdfPath: pdfPath,
                    transactionNo: transactionNumber,
                    fee: serviceFee + vatAmount,
                  );
                  await DBHelper().insertTxn(record);
                }
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.share_outlined, color: lightGreen),
              label: const Text('Share', style: TextStyle(color: lightGreen)),
              onPressed: () {
                // TODO: implement share
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.check_circle, color: lightGreen, size: 50),
            const SizedBox(height: 8),
            const Text(
              'Successful',
              style: TextStyle(fontSize: 16, color: lightGreen),
            ),
            const SizedBox(height: 70),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '-${formatAmount(totalAmount)}',
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 5),
                const Padding(
                  padding: EdgeInsets.only(top: 13.0),
                  child: Text(
                    '(ETB)',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(thickness: 0.5, color: Colors.grey),
                  TransactionDetailRow(
                    label: 'Transaction Time:',
                    value: formattedTime,
                  ),
                  const TransactionDetailRow(
                    label: 'Transaction Type:',
                    value: 'Transfer Money',
                  ),
                  TransactionDetailRow(
                    label: 'Transaction To:',
                    value: recipientName,
                  ),
                  TransactionDetailRow(
                    label: 'Transaction Number:',
                    value: transactionNumber,
                  ),
                  if (note.isNotEmpty)
                    TransactionDetailRow(label: 'Note:', value: note),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Icon(Icons.qr_code, color: lightGreen),
                      SizedBox(width: 5),
                      Text('QR Code', style: TextStyle(color: lightGreen)),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: lightGreen,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildCarousel(),
            const SizedBox(height: 80),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ElevatedButton(
                onPressed:
                    () => Navigator.popUntil(
                      context,
                      ModalRoute.withName('/home'),
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightGreen,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11.0),
                  ),
                ),
                child: const Text(
                  'Finished',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const TransactionDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// lib/screens/bank_transfer_confirmation_screen.dart

// ignore_for_file: unused_import

import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:telebirr/models/transaction.dart';
import 'package:telebirr/screens/pdf_utils.dart';
import 'package:telebirr/services/db_helper.dart';

class BankTransferConfirmationScreen extends StatefulWidget {
  const BankTransferConfirmationScreen({super.key});

  @override
  BankTransferConfirmationScreenState createState() =>
      BankTransferConfirmationScreenState();
}

class BankTransferConfirmationScreenState
    extends State<BankTransferConfirmationScreen> {
  static const Color lightGreen = Color(0xFF8BC83D);

  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  Timer? _carouselTimer;

  // Generate a random transaction number for this session
  final String _transactionNumber = _generateTransactionNumber();

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

  final List<String> _carouselImages = [
    'assets/images/financial_services8.png',
    'assets/images/financial_services6.png',
    'assets/images/financial_services2.png',
    'assets/images/financial_services3.png',
    'assets/images/financial_services4.png',
  ];

  Widget _buildCarousel() {
    return SizedBox(
      height: 130,
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.95,
            child: Container(
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: PageView.builder(
                controller: _pageController,
                itemCount: _carouselImages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder:
                    (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.asset(
                          _carouselImages[i],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
              ),
            ),
          ),
          const SizedBox(height: 10),
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
                            decoration: const BoxDecoration(
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ??
        {};

    // Extract arguments or provide defaults
    final rawAmount = args['amount']?.toString() ?? '0.0';
    final bank = args['bank'] ?? 'Unknown Bank';
    final account = args['account'] ?? 'N/A';
    final rawTime = args['transactionTime'] ?? DateTime.now().toIso8601String();
    final toName = args['name'] ?? 'User';
    final txnNum = _transactionNumber;

    // Parse amounts
    final baseAmt = double.tryParse(rawAmount) ?? 0.0;
    final fmtBaseAmt = baseAmt.toStringAsFixed(2);

    // Determine fee
    double fee;
    if (baseAmt < 100) {
      fee = 1.0;
    } else if (baseAmt < 500) {
      fee = 3.0;
    } else if (baseAmt < 1500) {
      fee = 6.0;
    } else {
      fee = 9.0;
    }

    // Service & VAT
    final serviceFee = fee * 0.8;
    final vatAmt = fee * 0.2;
    final totalAmt = baseAmt + fee;

    final fmtService = serviceFee.toStringAsFixed(2);
    final fmtVat = vatAmt.toStringAsFixed(2);
    final fmtTotal = totalAmt.toStringAsFixed(2);

    // Format time
    String fmtTime;
    try {
      final dt = DateTime.parse(rawTime);
      fmtTime = DateFormat('yyyy/MM/dd HH:mm:ss').format(dt);
    } catch (_) {
      fmtTime = DateFormat('yyyy/MM/dd HH:mm:ss').format(DateTime.now());
    }

    // Build map for PDF and DB
    final transactionData = {
      'transactionNumber': txnNum,
      'receiptNumber': txnNum,
      'transactionTime': fmtTime,
      'amount': fmtBaseAmt,
      'accountNumber': account,
      'name': toName,
      'bankName': bank,
      'discountAmount': '0.00',
      'serviceFee': fmtService,
      'vatAmount': fmtVat,
    };

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // DOWNLOAD & SAVE RECORD
            TextButton.icon(
              icon: const Icon(Icons.download_outlined, color: lightGreen),
              label: const Text(
                'Download',
                style: TextStyle(color: lightGreen),
              ),
              onPressed: () async {
                final pdfPath = await editAndSaveBankTransferPdf(
                  transactionData,
                  context,
                );
                if (pdfPath.isNotEmpty) {
                  final record = TransactionRecord(
                    type: 'Transfer Money',
                    amount: double.parse(fmtBaseAmt),
                    currency: '(ETB)',
                    counterparty: toName,
                    timestamp: fmtTime,
                    pdfPath: pdfPath,
                    transactionNo: txnNum,
                    fee: fee,
                  );
                  await DBHelper().insertTxn(record);
                }
              },
            ),

            // SHARE (stub)
            TextButton.icon(
              icon: const Icon(Icons.share_outlined, color: lightGreen),
              label: const Text('Share', style: TextStyle(color: lightGreen)),
              onPressed: () {
                // TODO: implement share functionality
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: lightGreen, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Successful',
              style: TextStyle(fontSize: 16, color: lightGreen),
            ),
            const SizedBox(height: 50),

            // Amount display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('-$fmtTotal', style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 5),
                const Padding(
                  padding: EdgeInsets.only(top: 5.0),
                  child: Text(
                    '(ETB)',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),

            // Details
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(thickness: 0.5, color: Colors.grey),
                  _buildDetailRow('Transaction Number', txnNum),
                  _buildDetailRow('Transaction Time:', fmtTime),
                  _buildDetailRow('Transaction Type:', 'Transfer To Bank'),
                  _buildDetailRow('Transaction To:', toName),
                  _buildDetailRow('Bank Account Number:', account),
                  _buildDetailRow('Bank Name:', bank),
                  const SizedBox(height: 15),
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
            const SizedBox(height: 30),

            // Carousel
            _buildCarousel(),
            const SizedBox(height: 24),

            // FINISHED button
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11.0),
                  ),
                ),
                child: const Text(
                  'Finished',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

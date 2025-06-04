// lib/screens/merchant_confirmation_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';

class MerchantConfirmationScreen extends StatefulWidget {
  const MerchantConfirmationScreen({Key? key}) : super(key: key);

  @override
  MerchantConfirmationScreenState createState() =>
      MerchantConfirmationScreenState();
}

class MerchantConfirmationScreenState
    extends State<MerchantConfirmationScreen> {
  static const Color lightGreen = Color(0xFF8BC83D);

  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  Timer? _carouselTimer;

  late final DateTime _transactionTime;
  late final String _transactionNumber;

  @override
  void initState() {
    super.initState();
    _transactionTime = DateTime.now();
    _transactionNumber =
        'CCK${_transactionTime.millisecondsSinceEpoch.toString().substring(6)}';

    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_pageController.hasClients) {
        var next = _currentPage + 1;
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

  Widget _buildCarousel(BuildContext context) {
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

  String formatAmount(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$integerPart.${parts[1]}';
  }

  String formatDateTime(DateTime dt) =>
      '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String merchantId = args['merchantId'] ?? '';
    final double amount =
        double.tryParse(args['amount']?.toString() ?? '0') ?? 0.0;
    // ignore: unused_local_variable
    final String operatorId = args['operatorId'] ?? '';

    final formattedTime = formatDateTime(_transactionTime);
    final formattedAmount = formatAmount(amount);

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
              onPressed: () {
                // TODO: implement download functionality
              },
            ),
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
                Text('-$formattedAmount', style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 5),
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    '(ETB)',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Divider(thickness: 0.5, color: Colors.grey),
            const SizedBox(height: 5),
            TransactionDetailRow(
              label: 'Transaction Time',
              value: formattedTime,
            ),
            const SizedBox(height: 10),
            const TransactionDetailRow(
              label: 'Transaction Type',
              value: 'Buy Goods',
            ),
            const SizedBox(height: 10),
            TransactionDetailRow(label: 'Transaction To', value: merchantId),
            const SizedBox(height: 10),
            TransactionDetailRow(
              label: 'Transaction Number',
              value: _transactionNumber,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      // TODO: Give Tip
                    },
                    child: Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: lightGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Give Tip >',
                          style: TextStyle(
                            color: lightGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      // TODO: Show QR Code
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code, color: lightGreen),
                        const SizedBox(width: 5),
                        Text(
                          'QR Code >',
                          style: TextStyle(
                            color: lightGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildCarousel(context),
            const SizedBox(height: 66),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Bill Share
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: lightGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text(
                      'Bill Share',
                      style: TextStyle(color: lightGreen),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.popUntil(
                          context,
                          ModalRoute.withName('/home'),
                        ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightGreen,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text(
                      'Finished',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
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
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

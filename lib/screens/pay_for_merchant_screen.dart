import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PayForMerchantScreen extends StatefulWidget {
  const PayForMerchantScreen({super.key});

  @override
  PayForMerchantScreenState createState() => PayForMerchantScreenState();
}

class PayForMerchantScreenState extends State<PayForMerchantScreen> {
  final _merchantIdController = TextEditingController();
  final _operatorIdController = TextEditingController();
  final _amountController = TextEditingController();

  // PIN entry controllers and focus
  final _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  static const String _correctPin = '607392';

  // Carousel variables
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  final List<String> _carouselImages = [
    'assets/images/financial_services8.png',
    'assets/images/financial_services2.png',
    'assets/images/financial_services3.png',
    'assets/images/financial_services4.png',
    'assets/images/financial_services5.png',
  ];
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _carouselImages.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
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
    _merchantIdController.dispose();
    _operatorIdController.dispose();
    _amountController.dispose();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  // Show PIN dialog
  void _showPinDialog() {
    _pinController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: AlertDialog(
                  insetPadding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  title: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Enter PIN',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Offstage(
                        offstage: true,
                        child: TextField(
                          focusNode: _pinFocusNode,
                          controller: _pinController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            setState(() {});
                            if (value.length == 6) {
                              if (value == _correctPin) {
                                Navigator.of(context).pop();
                                _navigateToConfirmation();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Incorrect PIN'),
                                  ),
                                );
                                _pinController.clear();
                                setState(() {});
                                FocusScope.of(
                                  context,
                                ).requestFocus(_pinFocusNode);
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap:
                            () => FocusScope.of(
                              context,
                            ).requestFocus(_pinFocusNode),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (i) {
                            bool filled = _pinController.text.length > i;
                            return Padding(
                              padding: EdgeInsets.only(right: i < 5 ? 8 : 0),
                              child: Container(
                                width: 40,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  filled ? '•' : '',
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      _pinController.clear();
    });
  }

  // Navigate after PIN success
  void _navigateToConfirmation() {
    Navigator.pushNamed(
      context,
      '/loading',
      arguments: {
        'nextRoute': '/pay_merchant_confirmation',
        'transactionData': {
          'merchantId': _merchantIdController.text,
          'operatorId': _operatorIdController.text,
          'amount': _amountController.text,
        },
      },
    );
  }

  void _onNextPressed() {
    if (_merchantIdController.text.isEmpty ||
        _operatorIdController.text.isEmpty ||
        _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }
    _showPinDialog();
  }

  // Reusable carousel widget
  Widget _buildCarousel() {
    return Column(
      children: [
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: PageView.builder(
            controller: _pageController,
            itemCount: _carouselImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(_carouselImages[index], fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_carouselImages.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: _currentPage == index ? 12 : 8,
              height: _currentPage == index ? 12 : 8,
              decoration: BoxDecoration(
                color:
                    _currentPage == index
                        ? const Color(0xFF8BC83D)
                        : Colors.white,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay for Merchant - Details'),
        backgroundColor: Colors.grey[200],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carousel banner at the top
            _buildCarousel(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter Merchant Payment Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Merchant ID field with scanning icon for QR codes
                  TextField(
                    controller: _merchantIdController,
                    decoration: InputDecoration(
                      labelText: 'Merchant ID',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        onPressed: () {}, // TODO: Add QR scanning
                      ),
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Operator ID field
                  TextField(
                    controller: _operatorIdController,
                    decoration: InputDecoration(
                      labelText: 'Operator ID',
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Amount field
                  TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Set Amount (ETB)',
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Recent section
                  const Text(
                    'Recent',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _onNextPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8BC83D),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text('Next'),
        ),
      ),
    );
  }
}

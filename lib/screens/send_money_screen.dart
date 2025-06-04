import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/numeric_keypad.dart';
import '../database_helper.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  SendMoneyScreenState createState() => SendMoneyScreenState();
}

class SendMoneyScreenState extends State<SendMoneyScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+251');

  // Carousel variables
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentPage = 0;
  final List<String> _carouselImages = [
    'assets/images/financial_services8.png',
    'assets/images/financial_services6.png',
    'assets/images/financial_services2.png',
    'assets/images/financial_services3.png',
    'assets/images/financial_services4.png',
  ];
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % _carouselImages.length;
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
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _goToTransactionDetails() {
    if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => TransactionDetailsScreen(
                name: _nameController.text,
                phone: _phoneController.text,
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both name and phone number.'),
        ),
      );
    }
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: PageView.builder(
            controller: _pageController,
            itemCount: _carouselImages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder:
                (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.asset(
                      _carouselImages[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
        title: const Text('Send Money - Recipient'),
        backgroundColor: Colors.grey[200],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCarousel(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter Recipient Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: const Icon(
                        Icons.check_circle,
                        color: Color(0xFF8BC83D),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _goToTransactionDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8BC83D),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(color: Colors.white),
                    ),
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

class TransactionDetailsScreen extends StatefulWidget {
  final String name;
  final String phone;

  const TransactionDetailsScreen({
    super.key,
    required this.name,
    required this.phone,
  });

  @override
  TransactionDetailsScreenState createState() =>
      TransactionDetailsScreenState();
}

class TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // PIN controllers
  final _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  static const String _correctPin = '607392';

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  void _processTransaction() {
    _dbHelper.insertTransaction({
      'sender_id': 1,
      'name': widget.name,
      'phone': widget.phone,
      'amount': double.parse(_amountController.text),
      'type': 'Send Money',
    });
    Navigator.pushNamed(
      context,
      '/loading',
      arguments: {
        'nextRoute': '/confirmation',
        'transactionData': {
          'amount': _amountController.text,
          'name': widget.name,
          'phone': widget.phone,
          'note': _notesController.text,
        },
      },
    );
  }

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
                                _processTransaction();
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
    ).then((_) => _pinController.clear());
  }

  void _onOK() {
    if (_amountController.text.isNotEmpty) {
      _showPinDialog();
    }
  }

  void _onKeyPressed(String key) =>
      setState(() => _amountController.text += key);

  void _onBackspace() {
    if (_amountController.text.isNotEmpty) {
      setState(
        () =>
            _amountController.text = _amountController.text.substring(
              0,
              _amountController.text.length - 1,
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money - Amount'),
        backgroundColor: Colors.grey[200],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Main content scrolls
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.orange,
                        radius: 30,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.phone,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Amount'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.none,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('(ETB)', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Add notes (optional)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Numeric keypad docked at bottom
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: NumericKeypad(
              onKeyPressed: _onKeyPressed,
              onBackspace: _onBackspace,
              onOK: _onOK,
              transferButtonColor: const Color(0xFF8BC83D), // green OK
            ),
          ),
        ],
      ),
    );
  }
}

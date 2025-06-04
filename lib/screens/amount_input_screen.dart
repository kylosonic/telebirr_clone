import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountInputScreen extends StatefulWidget {
  const AmountInputScreen({super.key});

  @override
  AmountInputScreenState createState() => AmountInputScreenState();
}

class AmountInputScreenState extends State<AmountInputScreen> {
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  static const Color primaryPurple = Color(0xFF9B51E0);
  static const Color notesGreen = Color(0xFF27AE60);
  static const Color lightGreen = Color(0xFF8BC83D);
  static const String _correctPin = '607392';

  static const Map<String, Color> bankBannerColors = {
    'Abay Bank S.C.': Color(0xFFE53935),
    'Addis International Bank': Color(0xFF1E88E5),
    'Ahadu Bank': Color(0xFFD84315),
    'Amhara Bank': Color(0xFF00897B),
    'Awash International Bank': Color(0xFFFFA000),
    'Bank of Abyssinia': Color.fromARGB(255, 249, 158, 0),
    'Berhan International Bank': Color(0xFF8E24AA),
    'Bunna International Bank': Color(0xFF6A1B9A),
    'Commercial Bank of Ethiopia': primaryPurple,
    'Construction and Business Bank': Color(0xFF6D4C41),
    'Cooperative Bank of Oromia': Color(0xFF43A047),
    'Dashen Bank': Color(0xFF00ACC1),
    'Development Bank of Ethiopia': Color(0xFFC0CA33),
    'Enat Bank': Color(0xFFD81B60),
    'Global Bank Ethiopia': Color(0xFF29B6F6),
    'Hibret Bank': Color(0xFF757575),
    'Lion International Bank': Color(0xFF546E7A),
    'Nib International Bank': Color(0xFFFB8C00),
    'Oromia International Bank': Color(0xFF8BC34A),
    'United Bank (Ethiopia)': Color(0xFFD84315),
    'Wegagen Bank': Color(0xFFFFB300),
    'Zemen Bank': Color(0xFF5E35B1),
    'Siinqee Bank': Color(0xFFAFB42B),
    'Shabelle Bank': Color(0xFF00695C),
    'Tsehay Bank': Color(0xFF5D4037),
    'Tsedey Bank': Color(0xFF4A148C),
  };

  static const Map<String, String> bankLogos = {
    'Bank of Abyssinia': 'assets/images/BOA.png',
    'Commercial Bank of Ethiopia': 'assets/images/cbe.png',
    'Dashen Bank': 'assets/images/dashen.png',
    'Enat Bank': 'assets/images/enat.png',
    'Hibret Bank': 'assets/images/hibret.png',
    'Nib International Bank': 'assets/images/nib.png',
    'Oromia International Bank': 'assets/images/oromia.png',
    'United Bank (Ethiopia)': 'assets/images/united.png',
    'Wegagen Bank': 'assets/images/wegagen.png',
    'Zemen Bank': 'assets/images/zemen.png',
    'Abay Bank S.C.': 'assets/images/abay.png',
    'Addis International Bank': 'assets/images/addis.png',
    'Ahadu Bank': 'assets/images/ahadu.png',
    'Amhara Bank': 'assets/images/amhara.png',
    'Awash International Bank': 'assets/images/awash.png',
    'Berhan International Bank': 'assets/images/berhan.png',
    'Bunna International Bank': 'assets/images/bunna.png',
    'Cooperative Bank of Oromia': 'assets/images/coop.png',
    'Global Bank Ethiopia': 'assets/images/global.png',
    'Lion International Bank': 'assets/images/lion.png',
    'Siinqee Bank': 'assets/images/siinqee.png',
    'Tsehay Bank': 'assets/images/tsehay.png',
    'Tsedey Bank': 'assets/images/tsedey.png',
    'ZamZam Bank': 'assets/images/zamzam.png',
    'siket Bank': 'assets/images/siket.png',
    'sidama Bank': 'assets/images/sidama.png',
  };

  @override
  void dispose() {
    _amountController.dispose();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Color _getBannerColor(String bankName) {
    return bankBannerColors[bankName] ?? primaryPurple;
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
                                _navigateToLoading();
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

  void _navigateToLoading() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null && amount > 0) {
      final initialArgs =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ??
          {};

      Navigator.pushNamed(
        context,
        '/loading',
        arguments: {
          'nextRoute': '/bank_transfer_confirmation',
          'transactionData': {
            'amount': amount.toStringAsFixed(2),
            'bank': initialArgs['bank'],
            'account': initialArgs['account'],
            'transactionTime': DateTime.now().toIso8601String(),
            'name': initialArgs['name'],
          },
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid positive amount'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ??
        {};
    final bank = args['bank'] ?? 'Unknown Bank';
    final account = args['account'] ?? 'N/A';
    final name = args['name'] ?? 'Unknown Recipient';
    const currentBalance = '6215846.00';

    final Color bannerColor = _getBannerColor(bank);
    final String? logoAsset = bankLogos[bank];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Transfer to Bank'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              decoration: BoxDecoration(
                color: bannerColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Square avatar instead of circle
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      // borderRadius: BorderRadius.circular(4), // optional
                    ),
                    alignment: Alignment.center,
                    child:
                        logoAsset != null
                            ? Image.asset(
                              logoAsset,
                              width: 36,
                              height: 36,
                              fit: BoxFit.contain,
                            )
                            : Icon(
                              Icons.account_balance_wallet_outlined,
                              color: bannerColor,
                              size: 20,
                            ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "$bank ($account)",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            // Amount input
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 4),
                              hintText: '0',
                              hintStyle: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.start,
                            cursorColor: notesGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '(ETB)',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Divider(height: 20, thickness: 1),
                    Text(
                      'Balance: $currentBalance (ETB)',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
            InkWell(
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Add notes (optional)',
                  style: TextStyle(
                    color: notesGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const Spacer(),
            ElevatedButton(
              onPressed: _showPinDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: lightGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Confirm Transfer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

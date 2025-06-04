import 'dart:async';
import 'package:flutter/material.dart';
import '../database_helper.dart'; // Make sure this path is correct

class TransferToBankScreen extends StatefulWidget {
  const TransferToBankScreen({super.key});
  static const Color lightGreen = Color(0xFF8BC83D);

  @override
  TransferToBankScreenState createState() => TransferToBankScreenState();
}

class TransferToBankScreenState extends State<TransferToBankScreen> {
  final _accountController = TextEditingController();
  final _nameController = TextEditingController(); // Controller for name
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> bankAccounts = [];
  String? _selectedBank;

  // Comprehensive list of Ethiopian banks
  final List<String> _banks = [
    'Abay Bank S.C.',
    'Addis International Bank',
    'Ahadu Bank',
    'Amhara Bank',
    'Awash International Bank',
    'Bank of Abyssinia',
    'Berhan International Bank',
    'Bunna International Bank',
    'Commercial Bank of Ethiopia',
    'Cooperative Bank of Oromia',
    'Dashen Bank',
    'Enat Bank',
    'Global Bank Ethiopia',
    'Gadda Bank',
    'Goh Betoch Bank',
    'Hibret Bank',
    'Hijra Bank',
    'Lion International Bank',
    'Nib International Bank',
    'Oromia International Bank',
    'Rammis Bank',
    'Sidama Bank',
    'Siket Bank',
    'Siinqee Bank',
    'Tsehay Bank',
    'Tsedey Bank',
    'Wegagen Bank',
    'ZamZam Bank',
    'Zemen Bank',
  ];

  // --- Carousel variables ---
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
  // --- End Carousel Variables ---

  // --- Bank Icons Mapping (Placeholder - Replace with your actual assets) ---
  final Map<String, String> _bankIcons = {
    // Example:
    'Abay Bank S.C.': 'assets/images/abay.png',
    'Addis International Bank': 'assets/images/addis.png',
    'Ahadu Bank': 'assets/images/ahadu.png',
    'Amhara Bank': 'assets/images/amhara.png',
    'Awash International Bank': 'assets/images/awash.png',
    'Bank of Abyssinia': 'assets/images/BOA.png',
    'Berhan International Bank': 'assets/images/berhan.png',
    'Bunna International Bank': 'assets/images/bunna.png',
    'Commercial Bank of Ethiopia': 'assets/images/cbe.png',
    'Cooperative Bank of Oromia': 'assets/images/coop.png',
    'Dashen Bank': 'assets/images/dashen.png',
    'Enat Bank': 'assets/images/enat.png',
    'Global Bank Ethiopia': 'assets/images/global.png',
    'Gadda Bank': 'assets/images/gadda.png',
    'Goh Betoch Bank': 'assets/images/goh.png',
    'Hibret Bank': 'assets/images/hibret.png',
    'Hijra Bank': 'assets/images/hijra.png',
    'Lion International Bank': 'assets/images/lion.png',
    'Nib International Bank': 'assets/images/nib.png',
    'Oromia International Bank': 'assets/images/oromia.png',
    'Rammis Bank': 'assets/images/rammis.png',
    'Sidama Bank': 'assets/images/sidama.png',
    'Siket Bank': 'assets/images/siket.png',
    'Siinqee Bank': 'assets/images/siinqee.png',
    'Tsehay Bank': 'assets/images/tsehay.png',
    'Tsedey Bank': 'assets/images/tsedey.png',
    'Wegagen Bank': 'assets/images/wegagen.png',
    'ZamZam Bank': 'assets/images/zamzam.png',
    'Zemen Bank': 'assets/images/zemen.png',
  };
  // --- End Bank Icons Mapping ---

  @override
  void initState() {
    super.initState();
    _loadBankAccounts();
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
    _accountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadBankAccounts() async {
    final data = await _dbHelper.getBankAccounts();
    setState(() => bankAccounts = data);
  }

  Future<void> _handleNext() async {
    final accountNumber = _accountController.text;
    final name = _nameController.text;

    if (_selectedBank == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a bank')));
      return;
    }
    if (accountNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an account number')),
      );
      return;
    }
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the recipient\'s name')),
      );
      return;
    }
    Navigator.pushNamed(
      context,
      '/amount_input', // Ensure this route is defined in your main app
      arguments: {
        'bank': _selectedBank,
        'account': accountNumber,
        'name': name,
      },
    );
  }

  // --- Carousel widget ---
  Widget _buildCarousel() {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.95,
          child: Container(
            height: 110,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _carouselImages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder:
                  (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        _carouselImages[index],
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => const Center(
                              child: Icon(Icons.image_not_supported),
                            ),
                      ),
                    ),
                  ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_carouselImages.length, (index) {
            final isActive = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              width: isActive ? 10 : 6,
              height: isActive ? 10 : 6,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: TransferToBankScreen.lightGreen,
                  width: 1,
                ),
                shape: BoxShape.circle,
              ),
              child:
                  isActive
                      ? Center(
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: TransferToBankScreen.lightGreen,
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
  // --- End Carousel Widget ---

  // --- Function to show Bank Selection Grid ---
  void _showBankSelectionGrid(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows bottom sheet to take more height if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        // Wrap content in a container with max height to prevent full screen takeover
        // Adjust maxHeight factor as needed (e.g., 0.6 for 60% of screen height)
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7, // Limit height
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Bank',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  // Use Expanded inside the constrained container
                  child: GridView.builder(
                    shrinkWrap:
                        true, // Important for GridView inside Column/Expanded
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: _banks.length,
                    itemBuilder: (context, index) {
                      final bankName = _banks[index];
                      final iconAsset = _bankIcons[bankName];

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedBank = bankName;
                          });
                          Navigator.pop(context);
                        },
                        child: Card(
                          elevation: 2.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              iconAsset != null
                                  ? Image.asset(
                                    iconAsset,
                                    height: 40,
                                    width: 40,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.error_outline,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                  )
                                  : const Icon(
                                    Icons.account_balance,
                                    size: 40,
                                    color: TransferToBankScreen.lightGreen,
                                  ),
                              const SizedBox(height: 8),
                              Text(
                                bankName,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 10),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  // --- End Bank Selection Grid Function ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: true, // This is the default, usually works well with SingleChildScrollView
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transfer to Bank',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
      ),
      // Wrap the body's Column in SingleChildScrollView
      body: SingleChildScrollView(
        child: Column(
          // The main layout column
          children: [
            const SizedBox(height: 8), // Add some top padding if needed
            _buildCarousel(),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Bank Selection Button
                  InkWell(
                    onTap: () => _showBankSelectionGrid(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Bank',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            _selectedBank ?? 'Select Bank',
                            style: TextStyle(
                              color:
                                  _selectedBank == null
                                      ? Colors.grey[600]
                                      : Colors.black,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Recipient Name TextField
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Recipient Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization:
                        TextCapitalization.words, // Optional: Capitalize names
                  ),
                  const SizedBox(height: 16),
                  // Account Number TextField
                  TextField(
                    controller: _accountController,
                    decoration: InputDecoration(
                      labelText: 'Account No',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  // Next Button
                  ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor:
                          _accountController.text.isNotEmpty &&
                                  _nameController.text.isNotEmpty &&
                                  _selectedBank != null
                              ? TransferToBankScreen.lightGreen
                              : Colors.grey,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Next', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),

            // --- Recent Transactions Section ---
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                8,
              ), // Adjusted padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Clear recent functionality TBD'),
                        ),
                      );
                    },
                    tooltip: 'Clear Recent',
                  ),
                ],
              ),
            ),
            // ListView needs shrinkWrap and NeverScrollableScrollPhysics
            ListView.builder(
              shrinkWrap:
                  true, // Make ListView only occupy space needed by its children
              physics:
                  const NeverScrollableScrollPhysics(), // Disable ListView's own scrolling
              itemCount: bankAccounts.length,
              itemBuilder: (context, index) {
                final account = bankAccounts[index];
                final name =
                    account['name'] ??
                    'User ${account['BEKELE MOLLA HOTEL PLC']}';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  elevation: 1,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: TransferToBankScreen.lightGreen
                          .withOpacity(0.2),
                      child: const Icon(
                        Icons.account_balance,
                        color: TransferToBankScreen.lightGreen,
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${account['bank_name']} • ${account['account_number']}',
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/amount_input',
                        arguments: {
                          'bank': account['bank_name'],
                          'account': account['account_number'],
                          'name': name,
                        },
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16), // Add some padding at the very bottom
            // --- End Recent Transactions Section ---
          ],
        ),
      ),
    );
  }
}

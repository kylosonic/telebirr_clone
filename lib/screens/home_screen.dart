import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marquee/marquee.dart';
import 'pay_for_merchant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _showEndekise = false;
  bool _showReward = false;
  bool _showBalance = false;
  double balance = 6215846.00;

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
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF8BC83D),
        statusBarIconBrightness: Brightness.light,
      ),
    );
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= _carouselImages.length) nextPage = 0;
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
    super.dispose();
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
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemBuilder:
                (ctx, idx) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(_carouselImages[idx], fit: BoxFit.cover),
                  ),
                ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_carouselImages.length, (idx) {
            final isActive = idx == _currentPage;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 12 : 8,
              height: isActive ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? const Color(0xFF8BC83D) : Colors.white,
                border: Border.all(
                  color: isActive ? Colors.white : const Color(0xFF8BC83D),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildToggleBalance({
    required String title,
    required bool isVisible,
    required String value,
    required VoidCallback onPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: onPressed,
            ),
          ],
        ),
        Text(
          isVisible ? value : '****',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildGridItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 120,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 2,
              spreadRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF8BC83D), size: 30),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItemWithImage(
    String title,
    String asset,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 140,
        width: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 2,
              spreadRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(asset, height: 30, width: 30, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8BC83D),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                children: [
                  // Top Logos
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(2.5),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/ethio_telecom_logo.png',
                          height: 32.5,
                        ),
                        Image.asset(
                          'assets/images/telebirr_logo.png',
                          height: 30,
                        ),
                      ],
                    ),
                  ),

                  // Greeting & Balances
                  Container(
                    color: const Color(0xFF8BC83D),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting row...
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.person, color: Colors.white),
                                SizedBox(width: 10),
                                Text(
                                  'Selam, yonatan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 0,
                                  ),
                                  icon: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {},
                                ),
                                // No SizedBox
                                Transform.translate(
                                  // Adjust the -4.0 value to increase or decrease the overlap
                                  offset: const Offset(-10.0, 0.0),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 0,
                                        ),
                                        icon: const Icon(
                                          Icons.notifications_outlined,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        onPressed:
                                            () => Navigator.pushNamed(
                                              context,
                                              '/history',
                                            ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        // You might need to adjust 'right' due to the translate
                                        right:
                                            4, // Adjusted from 0 because the whole Stack moved left
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 1,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 1,
                                          ),
                                          child: const Text(
                                            '99+',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 8,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // You might need to adjust this SizedBox to compensate
                                // Or remove it if 'Engl' should also move left.
                                const SizedBox(width: 0), // Adjusted from 4
                                const Text(
                                  'Engl',
                                  style: TextStyle(color: Colors.white),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Balance
                        const SizedBox(height: 0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Balance (ETB)',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _showBalance
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.white,
                                      ),
                                      onPressed:
                                          () => setState(
                                            () => _showBalance = !_showBalance,
                                          ),
                                    ),
                                  ],
                                ),
                                Text(
                                  _showBalance ? '$balance' : '****',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Endekise & Reward
                        const SizedBox(height: 0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildToggleBalance(
                              title: 'Endekise (ETB)',
                              isVisible: _showEndekise,
                              value: '100.00',
                              onPressed:
                                  () => setState(
                                    () => _showEndekise = !_showEndekise,
                                  ),
                            ),
                            _buildToggleBalance(
                              title: 'Reward (ETB)',
                              isVisible: _showReward,
                              value: '50.00',
                              onPressed:
                                  () => setState(
                                    () => _showReward = !_showReward,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Marquee
                  Container(
                    height: 15,
                    color: Colors.orange,
                    child: Marquee(
                      text: 'ONE APP FOR ALL YOUR NEEDS!',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      blankSpace: 200.0,
                      velocity: 50.0,
                    ),
                  ),

                  // Grids & Carousel
                  Container(
                    color: const Color(0xFFF5F5F5),
                    child: Column(
                      children: [
                        // First Grid
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: GridView.count(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.7,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildGridItemWithImage(
                                'Send\nMoney',
                                'assets/images/send_money_logo.png',
                                () =>
                                    Navigator.pushNamed(context, '/send_money'),
                              ),
                              _buildGridItemWithImage(
                                'Cash In/Out',
                                'assets/images/cash_logo.png',
                                () {},
                              ),
                              Stack(
                                children: [
                                  _buildGridItem(
                                    'Airtime/\nBuy\nPackage',
                                    Icons.phone_android,
                                    () {},
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Up to +25%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // **Zemen GEBEYA tile with larger image**
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  height: 140,
                                  width: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 2,
                                        spreadRadius: 1,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/zemen_gebeya.png',
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(height: 10),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4.0,
                                        ),
                                        child: Text(
                                          'Zemen\nGEBEYA',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 4,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              _buildGridItemWithImage(
                                'Financial\nService\nwith\nDashen',
                                'assets/images/dashen.png',
                                () {},
                              ),
                              _buildGridItemWithImage(
                                'Financial\nService\nwith CBE',
                                'assets/images/cbe.png',
                                () {},
                              ),
                              _buildGridItemWithImage(
                                'Financial\nService\nwith\nSiinqee',
                                'assets/images/siinqee.png',
                                () {},
                              ),
                              _buildGridItem(
                                'Transfer to\nBank',
                                Icons.account_balance,
                                () => Navigator.pushNamed(
                                  context,
                                  '/transfer_to_bank',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),
                        _buildCarousel(),

                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            alignment: Alignment.centerRight,
                            child: const Text(
                              'Transaction Details >',
                              style: TextStyle(
                                color: Color(0xFF1E90FF),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Second Grid...
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GridView.count(
                            crossAxisCount: 4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _buildGridItemWithImage(
                                'Pay for\nMerchant',
                                'assets/images/merchant_logo.png',
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => const PayForMerchantScreen(),
                                  ),
                                ),
                              ),
                              _buildGridItem(
                                'Top-Up',
                                Icons.signal_cellular_alt,
                                () {},
                              ),
                              _buildGridItem(
                                'Utility Bills',
                                Icons.receipt_long,
                                () {},
                              ),
                              _buildGridItem(
                                'Loan Services',
                                Icons.monetization_on,
                                () {},
                              ),
                              _buildGridItem('Savings', Icons.savings, () {}),
                              _buildGridItem(
                                'Donate',
                                Icons.volunteer_activism,
                                () {},
                              ),
                              _buildGridItem(
                                'Transport',
                                Icons.directions_bus,
                                () {},
                              ),
                              _buildGridItem(
                                'Cinema Tickets',
                                Icons.movie,
                                () {},
                              ),
                              _buildGridItem(
                                'Event Booking',
                                Icons.event,
                                () {},
                              ),
                              _buildGridItem(
                                'Gaming',
                                Icons.sports_esports,
                                () {},
                              ),
                              _buildGridItem(
                                'Insurance',
                                Icons.security,
                                () {},
                              ),
                              _buildGridItem(
                                'More Services',
                                Icons.more_horiz,
                                () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scan QR Button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Scan QR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E90FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Nav Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF8BC83D),
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: const Color(0xFFF5F5F5),
        onTap: (index) {},
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payment'),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Apps'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Engage'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

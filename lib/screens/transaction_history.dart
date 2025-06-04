import 'package:flutter/material.dart';
import '../services/db_helper.dart';
import '../models/transaction.dart';
import 'package:open_file/open_file.dart'; // to open PDFs

class TransactionHistoryScreen extends StatefulWidget {
  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  late Future<List<TransactionRecord>> _txnsFuture;
  Set<int> viewedTransactions = Set<int>(); // Track viewed transactions by ID

  // NEW: control whether we show the notification page or the transaction list
  bool _showNotifications = true;

  @override
  void initState() {
    super.initState();
    _txnsFuture = DBHelper().fetchAll();
  }

  @override
  Widget build(BuildContext context) {
    if (_showNotifications) {
      return Scaffold(
        backgroundColor: Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: Color(0xFFF5F5F5),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Notification',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: ListView(
          children: [
            _buildNotificationTile(
              icon: Icons.settings_outlined, // Gear/settings icon
              iconColor: Colors.white, // White icon color
              iconBgColor: Color(0xFF2196F3), // Blue background
              title: 'System Information',
              onTap: () {
                // TODO: push to System Information screen
              },
            ),
            _buildNotificationTile(
              icon: Icons.mail_outline, // Mail/envelope icon
              iconColor: Colors.white, // White icon color
              iconBgColor: Color(0xFF4CAF50), // Green background
              title: 'Transaction Message',
              badge: '99+',
              onTap: () {
                setState(() {
                  _showNotifications = false;
                });
              },
            ),
            _buildNotificationTile(
              icon: Icons.percent, // Percentage icon
              iconColor: Colors.white, // White icon color
              iconBgColor: Color(0xFFFF9800), // Orange background
              title: 'Promotion News',
              onTap: () {
                // TODO: push to Promotion News screen
              },
            ),
          ],
        ),
      );
    }

    // **UNCHANGED**: your existing transaction history UI
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () {
            setState(() {
              _showNotifications = true;
            });
          },
        ),
        title: Text(
          'Transaction Message',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<List<TransactionRecord>>(
        future: _txnsFuture,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done)
            return Center(child: CircularProgressIndicator());
          final txns = snap.data ?? [];
          if (txns.isEmpty) return Center(child: Text('No transactions yet.'));

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: txns.length,
            itemBuilder: (ctx, i) {
              final t = txns[i];
              return GestureDetector(
                onTap: () async {
                  // Mark transaction as viewed
                  setState(() {
                    viewedTransactions.add(
                      t.id ?? i,
                    ); // Use transaction ID or index as fallback
                  });

                  // Navigate to detail screen
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => TransactionDetailScreen(transaction: t),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Blue circle with checkmark
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xFF1976D2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        // Transaction details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Transaction type and amount
                              Text(
                                t.type,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${t.amount > 0 ? '-' : ''}${t.amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 12),
                              // Transaction details
                              Text(
                                'Transaction Time:${t.timestamp}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Transaction To:${t.counterparty}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Red dot indicator (only show if not viewed)
                        viewedTransactions.contains(t.id ?? i)
                            ? SizedBox(width: 8) // Empty space when viewed
                            : Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
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
      ),
    );
  }

  // Updated helper to build each notification tile with separate icon and background colors
  Widget _buildNotificationTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? badge,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing:
          badge != null
              ? Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
              : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}

class TransactionDetailScreen extends StatelessWidget {
  final TransactionRecord transaction;

  const TransactionDetailScreen({Key? key, required this.transaction})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Transaction Detail',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align children to the left
            children: [
              _buildDetailItem(
                'Transaction Time',
                transaction.timestamp,
                isBlue: true,
              ),
              SizedBox(height: 8),
              _buildDetailItem(
                'Transaction No',
                transaction.transactionNo,
                isBlue: true,
              ),
              SizedBox(height: 8),
              _buildDetailItem(
                'Transaction Type',
                transaction.type,
                isBlue: true,
              ),
              SizedBox(height: 8),
              _buildDetailItem(
                'Transaction To',
                transaction.counterparty,
                isBlue: true,
              ),
              SizedBox(height: 8),
              _buildDetailItem(
                'Transaction Amount',
                '${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                isBlue: true,
              ),
              SizedBox(height: 8),
              _buildDetailItem('Transaction Status', 'Completed', isBlue: true),
              SizedBox(height: 8),
              _buildDetailItem(
                'Service Charge',
                '-${transaction.fee.toStringAsFixed(2)} ${transaction.currency}',
                isBlue: true,
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  OpenFile.open(transaction.pdfPath);
                },
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                          255,
                          255,
                          255,
                          255,
                        ).withOpacity(0.2), // Light green background
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        'assets/images/get.png',
                        width: 100,
                        height: 100,
                      ),
                    ),
                    SizedBox(height: 0),
                    Text(
                      'Get Receipt',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(
                          255,
                          0,
                          0,
                          0,
                        ), // Specific green shade
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isBlue = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color:
                isBlue ? const Color.fromARGB(255, 12, 115, 198) : Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Container(height: 1, color: Colors.grey[300]),
      ],
    );
  }
}

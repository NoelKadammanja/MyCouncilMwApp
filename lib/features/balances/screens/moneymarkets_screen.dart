import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_govt_mw/data/local/user_dao.dart';

class FixedDepositScreen extends StatefulWidget {
  const FixedDepositScreen({super.key});

  @override
  State<FixedDepositScreen> createState() => _FixedDepositScreenState();
}

class _FixedDepositScreenState extends State<FixedDepositScreen> {
  late Future<List<Map<String, dynamic>>> _itemsFuture;

  double totalMoneyMarkets = 0.0;
  String balanceAsAt = '';

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
  }

  Future<List<Map<String, dynamic>>> _loadItems() async {
    final dao = UserDao();
    final user = await dao.getUser();

    final clientId = user != null
        ? (user['client_id'] ?? user['clientId'] ?? user['clientID'])
              ?.toString()
        : null;

    /// Balance as at (same as homepage)
    final updatedAtRaw =
        user?['updated_at'] ?? user?['updatedAt'] ?? user?['updatedAt'];

    if (updatedAtRaw != null) {
      try {
        final dt = DateTime.parse(updatedAtRaw.toString());
        balanceAsAt = DateFormat('d MMMM yyyy').format(dt);
      } catch (_) {}
    }

    final items = await dao.getMoneyMarketList(clientId);

    /// Calculate total market value
    totalMoneyMarkets = items.fold<double>(0.0, (sum, item) {
      final v =
          double.tryParse(item['current_value']?.toString() ?? '0') ?? 0.0;
      return sum + v;
    });

    return items;
  }

  String _formatCurrency(dynamic v, {bool symbol = false}) {
    final d = (v is num)
        ? v.toDouble()
        : double.tryParse(v?.toString() ?? '0') ?? 0.0;

    return NumberFormat.currency(
      locale: 'en_US',
      symbol: symbol ? 'MK ' : '',
      decimalDigits: 2,
    ).format(d);
  }

  String _formatDate(dynamic v) {
    if (v == null) return '-';
    try {
      return DateFormat('d MMM yyyy').format(DateTime.parse(v.toString()));
    } catch (_) {
      return '-';
    }
  }

  Widget _totalMoneyMarketCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            "Total Money Market Investments",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            'MK ${_formatCurrency(totalMoneyMarkets)}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoneyMarketDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                item['type']?.toString() ??
                    item['instrument_type']?.toString() ??
                    'Money Market',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _detailCard([
                _detailRow(
                  'Cost',
                  _formatCurrency(item['invested_amount'], symbol: true),
                ),
                _detailRow(
                  'Interest Accrued',
                  _formatCurrency(item['accrued_interest'], symbol: true),
                ),
                _detailRow('Start Date', _formatDate(item['start_date'])),
              ]),
              const SizedBox(height: 16),
              _detailCard([
                _detailRow(
                  'Market Value',
                  _formatCurrency(item['current_value'], symbol: true),
                  highlight: true,
                ),
                _detailRow('Rate %', item['rate']?.toString() ?? '-'),
                _detailRow(
                  'Tenure',
                  item['tenure_days'] != null && item['tenure_days'] > 0
                      ? '${item['tenure_days']} days'
                      : '-',
                ),

                _detailRow('Maturity Date', _formatDate(item['maturity_date'])),
              ]),
            ],
          ),
        );
      },
    );
  }

  Widget _detailCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _detailRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: TextStyle(
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              fontSize: highlight ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Money Market Investments'),
        centerTitle: true,
        backgroundColor: const Color(0xFF153871),
        foregroundColor: Colors.white,
        elevation: 1,
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _itemsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snap.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// TOTAL CARD
                _totalMoneyMarketCard(),

                const SizedBox(height: 12),

                /// TABLE
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Asset Type',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Cost',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Market Value',
                              textAlign: TextAlign.right,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      ...items.map((item) {
                        return InkWell(
                          onTap: () => _showMoneyMarketDetails(item),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          item['type']?.toString() ??
                                              item['instrument_type']
                                                  ?.toString() ??
                                              '',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.info_outline,
                                        size: 14,
                                        color: Color.fromARGB(255, 252, 160, 0),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _formatCurrency(item['invested_amount']),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _formatCurrency(item['current_value']),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /// BALANCE AS AT
                Text(
                  balanceAsAt.isNotEmpty
                      ? 'Balance as at $balanceAsAt'
                      : 'Balance as at -',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

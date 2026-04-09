// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:local_govt_mw/data/local/user_dao.dart';
//
// class SharesBalanceScreen extends StatefulWidget {
//   const SharesBalanceScreen({super.key});
//
//   @override
//   State<SharesBalanceScreen> createState() => _SharesBalanceScreenState();
// }
//
// class _SharesBalanceScreenState extends State<SharesBalanceScreen> {
//   late Future<List<Map<String, dynamic>>> _sharesFuture;
//
//   double totalShares = 0.0;
//   String balanceAsAt = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _sharesFuture = _loadShares();
//   }
//
//   Future<List<Map<String, dynamic>>> _loadShares() async {
//     final dao = UserDao();
//     final user = await dao.getUser();
//
//     final clientId = user != null
//         ? (user['client_id'] ?? user['clientId'] ?? user['clientID'])
//               ?.toString()
//         : null;
//
//     final updatedAtRaw =
//         user?['updated_at'] ?? user?['updatedAt'] ?? user?['updatedAt'];
//
//     if (updatedAtRaw != null) {
//       try {
//         final dt = DateTime.parse(updatedAtRaw.toString());
//         balanceAsAt = DateFormat('d MMMM yyyy').format(dt);
//       } catch (_) {}
//     }
//
//     final items = await dao.getSharesList(clientId);
//
//     totalShares = items.fold<double>(0.0, (sum, item) {
//       final v =
//           double.tryParse(item['current_value']?.toString() ?? '0') ?? 0.0;
//       return sum + v;
//     });
//
//     return items;
//   }
//
//   /// Currency formatter (with optional MK symbol)
//   String _formatCurrency(
//     dynamic v, {
//     bool symbol = false,
//     int decimalDigits = 2,
//   }) {
//     final double value;
//
//     if (v == null || v.toString().isEmpty) {
//       value = 0.0;
//     } else if (v is num) {
//       value = v.toDouble();
//     } else {
//       value = double.tryParse(v.toString()) ?? 0.0;
//     }
//
//     return NumberFormat.currency(
//       locale: 'en_US',
//       symbol: symbol ? 'MK ' : '',
//       decimalDigits: decimalDigits,
//     ).format(value);
//   }
//
//   /// Shares formatter (commas, no decimals)
//   String _formatShares(dynamic v) {
//     final int value;
//
//     if (v == null || v.toString().isEmpty) {
//       value = 0;
//     } else if (v is num) {
//       value = v.toInt();
//     } else {
//       value = int.tryParse(v.toString()) ?? 0;
//     }
//
//     return NumberFormat.decimalPattern('en_US').format(value);
//   }
//
//   Widget _totalSharesCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF5A605A),
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 12,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           const Text(
//             "Total Equity (Shares) Portfolio",
//             style: TextStyle(color: Colors.white70, fontSize: 14),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             'MK ${_formatCurrency(totalShares)}',
//             textAlign: TextAlign.right,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 26,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showShareDetails(Map<String, dynamic> item) {
//     final gainLoss = double.tryParse(item['gain_loss']?.toString() ?? '0') ?? 0;
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//
//       builder: (_) {
//         return Padding(
//           padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.black26,
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 item['counter']?.toString() ?? '',
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               _detailCard([
//                 _detailRow(
//                   'Number of Shares',
//                   _formatShares(item['number_of_shares']),
//                 ),
//                 _detailRow(
//                   'Purchase Price',
//                   _formatCurrency(item['purchase_price'], symbol: true),
//                 ),
//                 _detailRow(
//                   'Purchase Cost',
//                   _formatCurrency(item['purchase_cost'], symbol: true),
//                 ),
//                 _detailRow(
//                   'Current Price',
//                   _formatCurrency(item['current_price'], symbol: true),
//                 ),
//               ]),
//
//               const SizedBox(height: 16),
//
//               _detailCard([
//                 _detailRow(
//                   'Market Value',
//                   _formatCurrency(item['current_value'], symbol: true),
//                   highlight: true,
//                 ),
//                 _detailRow(
//                   'Gain / Loss',
//                   _formatCurrency(gainLoss, symbol: true),
//                   valueColor: gainLoss >= 0 ? Colors.green : Colors.red,
//                 ),
//               ]),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _detailCard(List<Widget> children) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(children: children),
//     );
//   }
//
//   Widget _detailRow(
//     String label,
//     String value, {
//     bool highlight = false,
//     Color? valueColor,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.black54)),
//           Text(
//             value,
//             style: TextStyle(
//               fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
//               fontSize: highlight ? 16 : 14,
//               color: valueColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F7),
//       appBar: AppBar(
//         title: const Text('Equity (Shares) Portfolio'),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF153871),
//         foregroundColor: Colors.white,
//         elevation: 1,
//       ),
//
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _sharesFuture,
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           final items = snap.data ?? [];
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 _totalSharesCard(),
//                 const SizedBox(height: 12),
//
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.08),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: const [
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               'Counter',
//                               style: TextStyle(fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               'Volume',
//                               textAlign: TextAlign.center,
//                               style: TextStyle(fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               'Market Value',
//                               textAlign: TextAlign.right,
//                               style: TextStyle(fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Divider(height: 24),
//
//                       ...items.map((item) {
//                         return InkWell(
//                           onTap: () => _showShareDetails(item),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   flex: 3,
//                                   child: Row(
//                                     children: [
//                                       Flexible(
//                                         child: Text(
//                                           item['counter']?.toString() ?? '',
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 4),
//                                       const Icon(
//                                         Icons.info_outline,
//                                         size: 14,
//                                         color: Color.fromARGB(255, 252, 160, 0),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: Text(
//                                     _formatShares(item['number_of_shares']),
//                                     textAlign: TextAlign.start,
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: Text(
//                                     _formatCurrency(item['current_value']),
//                                     textAlign: TextAlign.right,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }),
//                     ],
//                   ),
//                 ),
//
//                 const SizedBox(height: 12),
//
//                 Text(
//                   balanceAsAt.isNotEmpty
//                       ? 'Balance as at $balanceAsAt'
//                       : 'Balance as at -',
//                   style: const TextStyle(fontSize: 13, color: Colors.black54),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

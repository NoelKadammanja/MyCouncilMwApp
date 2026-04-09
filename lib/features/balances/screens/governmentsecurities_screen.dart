// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:local_govt_mw/data/local/user_dao.dart';
//
// class GovtSecuritiesScreen extends StatefulWidget {
//   const GovtSecuritiesScreen({super.key});
//
//   @override
//   State<GovtSecuritiesScreen> createState() => _GovtSecuritiesScreenState();
// }
//
// class _GovtSecuritiesScreenState extends State<GovtSecuritiesScreen> {
//   late Future<List<Map<String, dynamic>>> _itemsFuture;
//
//   double totalGovernment = 0.0;
//   String balanceAsAt = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _itemsFuture = _loadItems();
//   }
//
//   Future<List<Map<String, dynamic>>> _loadItems() async {
//     final dao = UserDao();
//     final user = await dao.getUser();
//
//     final clientId = user != null
//         ? (user['client_id'] ?? user['clientId'] ?? user['clientID'])
//               ?.toString()
//         : null;
//
//     /// Balance as at (same logic as homepage)
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
//     final items = await dao.getGovernmentSecuritiesList(clientId);
//
//     /// Calculate total market value
//     totalGovernment = items.fold<double>(0.0, (sum, item) {
//       final v =
//           double.tryParse(item['current_value']?.toString() ?? '0') ?? 0.0;
//       return sum + v;
//     });
//
//     return items;
//   }
//
//   String _formatCurrency(dynamic v) {
//     final d = (v is num)
//         ? v.toDouble()
//         : double.tryParse(v?.toString() ?? '0') ?? 0.0;
//
//     return NumberFormat.currency(
//       locale: 'en_US',
//       symbol: '',
//       decimalDigits: 2,
//     ).format(d);
//   }
//
//   String _formatCurrencyWithSymbol(dynamic v) {
//     final d = (v is num)
//         ? v.toDouble()
//         : double.tryParse(v?.toString() ?? '0') ?? 0.0;
//
//     return NumberFormat.currency(
//       locale: 'en_US',
//       symbol: 'MK ',
//       decimalDigits: 2,
//     ).format(d);
//   }
//
//   String _formatDate(dynamic v) {
//     if (v == null) return '-';
//     try {
//       return DateFormat('d MMMM yyyy').format(DateTime.parse(v.toString()));
//     } catch (_) {
//       return '-';
//     }
//   }
//
//   Widget _totalGovernmentCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF29A8E0),
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
//             "Total Government Securities",
//             style: TextStyle(color: Colors.white70, fontSize: 14),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             'MK ${_formatCurrency(totalGovernment)}',
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
//   void _showGovtSecurityBottomSheet(
//     BuildContext context,
//     Map<String, dynamic> item,
//   ) {
//     final investmentType =
//         item['instrument_type']?.toString() ??
//         item['instrument']?.toString() ??
//         '-';
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) {
//         return Container(
//           padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   margin: const EdgeInsets.only(bottom: 16),
//                   decoration: BoxDecoration(
//                     color: Colors.black26,
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//
//               Text(
//                 investmentType,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               _sheetRow(
//                 'Purchase Date',
//                 _formatDate(item['start_date'] ?? item['purchase_date']),
//               ),
//               _sheetRow(
//                 'Purchase Cost',
//                 _formatCurrencyWithSymbol(item['invested_amount']),
//               ),
//               _sheetRow('Yield to Maturity', item['rate']?.toString() ?? '-'),
//               _sheetRow(
//                 'Coupon Rate',
//                 item['coupon_rate']?.toString() ??
//                     item['accrued_interest']?.toString() ??
//                     '-',
//               ),
//               _sheetRow(
//                 'Face Value',
//                 _formatCurrencyWithSymbol(
//                   item['current_value'] ?? item['face_value'],
//                 ),
//               ),
//               _sheetRow('Maturity Date', _formatDate(item['maturity_date'])),
//
//               const SizedBox(height: 12),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _sheetRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(color: Colors.black54)),
//           const SizedBox(height: 6),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
//         title: const Text('Government Securities'),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF153871),
//         foregroundColor: Colors.white,
//         elevation: 1,
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _itemsFuture,
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
//                 /// TOTAL CARD
//                 _totalGovernmentCard(),
//
//                 const SizedBox(height: 12),
//
//                 /// TABLE
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
//                             flex: 3,
//                             child: Text(
//                               'Asset Type',
//                               style: TextStyle(fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               'Cost',
//                               textAlign: TextAlign.right,
//                               style: TextStyle(fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                           Expanded(
//                             flex: 2,
//                             child: Text(
//                               'Face Value',
//                               textAlign: TextAlign.right,
//                               style: TextStyle(fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                         ],
//                       ),
//
//                       const Divider(height: 24),
//
//                       ...items.map((item) {
//                         final asset =
//                             item['instrument_type']?.toString() ??
//                             item['instrument']?.toString() ??
//                             '';
//
//                         return InkWell(
//                           onTap: () =>
//                               _showGovtSecurityBottomSheet(context, item),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   flex: 3,
//                                   child: Text(
//                                     asset,
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: Text(
//                                     _formatCurrency(item['invested_amount']),
//                                     textAlign: TextAlign.right,
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
//                 /// BALANCE AS AT
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

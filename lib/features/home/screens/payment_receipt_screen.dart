import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentReceiptScreen extends StatelessWidget {
  const PaymentReceiptScreen({
    super.key,
    required this.title,
    required this.amountText,
    required this.currency,
    required this.fromName,
    required this.fromRef,
    required this.toName,
    required this.toRef,
    required this.remarks,
    required this.paymentType,
    required this.referenceId,
    required this.dateTime,
  });

  final String title; // "Payment Successful"
  final String amountText; // "5000" or "MWK 5,000"
  final String currency; // "MWK"
  final String fromName; // Officer name
  final String fromRef; // Officer email / phone / ID
  final String toName; // Shop/Vendor/Market
  final String toRef; // Shop code / customer ref
  final String remarks; // "Market Fee Payment"
  final String paymentType; // "POS"
  final String referenceId; // receipt_no or backend reference
  final DateTime dateTime;

  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('d MMM yyyy');
    final timeFmt = DateFormat('hh:mm a');


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Receipt",
          style: TextStyle(color: kText, fontWeight: FontWeight.w900),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            children: [
              // Top success icon + title
              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  color: kPrimaryGreen.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 54, color: kPrimaryGreen),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: kPrimaryGreen,
                ),
              ),
              const SizedBox(height: 14),

              // Receipt card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _row(
                          label: "From",
                          value: _twoLines(fromName, fromRef),
                        ),
                        const SizedBox(height: 14),
                        _row(
                          label: "To",
                          value: _twoLines(toName, toRef),
                        ),
                        const SizedBox(height: 14),
                        _row(
                          label: "Amount",
                          value: Text(
                            "$currency $amountText",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: kText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _row(
                          label: "Remarks",
                          value: Text(
                            remarks,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: kText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _row(
                          label: "Date",
                          value: _twoLines(
                            dateFmt.format(dateTime),
                            timeFmt.format(dateTime),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _row(
                          label: "Payment Type",
                          value: Text(
                            paymentType,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: kText,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _row(
                          label: "Reference Id",
                          value: Text(
                            referenceId,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: kText,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: const Color(0xFFE5E7EB),
                        ),
                        const SizedBox(height: 12),

                        // Optional CTA buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  // optional: implement share later
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Share coming soon")),
                                  );
                                },
                                icon: const Icon(Icons.share, size: 18),
                                label: const Text("Share"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: kText,
                                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.done, size: 18),
                                label: const Text("Done"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kPrimaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row({required String label, required Widget value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: const TextStyle(
              color: kMuted,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(child: value),
      ],
    );
  }

  Widget _twoLines(String a, String b) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          a,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: kText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          b,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: kText,
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:local_govt_mw/features/onboarding/domain/model/slider_item_model.dart';

class SliderItemWidget extends StatelessWidget {
  final SliderItemModel model;

  const SliderItemWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Expanded(
          flex: 2,
          child: Image.asset(
            model.image,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 20),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: model.title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: model.highlightTitle,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Text(
            model.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

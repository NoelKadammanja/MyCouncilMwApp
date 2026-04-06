import 'slider_item_model.dart';
import 'package:local_govt_mw/utill/images.dart';

class OnboardingModel {
  static List<SliderItemModel> getSliderPageData() {
    return [
      SliderItemModel(
        image: Images.onBoarding1,
        title: 'Invest today for ',
        highlightTitle: 'tomorrow',
        subtitle:
            'View your portfolio, and track your account activities anytime, anywhere. Simple and secure.',
      ),
      // SliderItemModel(
      //   image: Images.onBoarding2,
      //   title: 'Secure your ',
      //   highlightTitle: 'future',
      //   subtitle:
      //       'Your investments are protected and monitored with industry-leading standards.',
      // ),
      // SliderItemModel(
      //   image: Images.onBoarding3,
      //   title: 'Grow with ',
      //   highlightTitle: 'confidence',
      //   subtitle:
      //       'Enjoy a seamless investing experience backed by trusted partners.',
      // ),
    ];
  }
}

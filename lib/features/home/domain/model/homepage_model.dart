import 'package:get/get.dart';
import 'package:local_govt_mw/features/home/domain/model/list_item_model.dart';
import 'package:local_govt_mw/features/home/domain/model/list_portfolio_item_model.dart';
import 'package:local_govt_mw/utill/images.dart';


class HomepageModel {
  RxList<ListportfolioItemModel> listportfolioItemList =
      RxList.filled(5, ListportfolioItemModel('', '', '', '', '', ''));

  RxList<ListItemModel> listItemList = RxList.filled(5, ListItemModel());

  static List<ListportfolioItemModel> getPortfolioData() {
    return [
      ListportfolioItemModel(ImageConstant.imgEllipse2832, "NICO", "Insurance",
          "\MK80,30", "1.80(+1.32%)", "up"),
      ListportfolioItemModel(ImageConstant.imgNikeIcon, "NBS", "Banking",
          "\MK111,05", "-2.85(0.32%)", "down"),
      ListportfolioItemModel(ImageConstant.imgEllipse2832, "ICON", "Property",
          "\MK80,30", "1.80(+1.32%)", "up"),
      ListportfolioItemModel(ImageConstant.imgNikeIcon, "AIRTEL", "Telecomunications",
          "\MK111,05", "-2.85(0.32%)", "down"),
      ListportfolioItemModel(ImageConstant.imgEllipse2832, "ILLOVO", "Manufacturing",
          "\MK80,30", "1.80(+1.32%)", "up"),
      ListportfolioItemModel(ImageConstant.imgNikeIcon, "BHL", "Property",
          "\MK111,05", "-2.85(0.32%)", "down"),
    ];
  }
}
//Listportfolio1ItemModel(this.icon,this.title,this.subtitle,this.rate,this.progress,this.progressType);

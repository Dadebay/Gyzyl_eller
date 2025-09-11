import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';

class AllSearchView extends StatelessWidget {
  const AllSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConstants.background,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: ColorConstants.kPrimaryColor2,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: SizedBox(
          child: TextField(
            autofocus: true,
            style: const TextStyle(
              fontSize: 15,
              color: ColorConstants.fonts,
            ),
            decoration: const InputDecoration(
              hintText: 'Adına göre gözlemek...',
              hintStyle: TextStyle(fontSize: 15, color: ColorConstants.fonts),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(child: SvgPicture.asset(IconConstants.emptysearch)),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

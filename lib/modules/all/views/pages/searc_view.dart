import 'package:flutter_svg/flutter_svg.dart';
import 'package:gyzyleller/modules/all/controllers/all_controller.dart';
import 'package:gyzyleller/modules/all/views/pages/job_card_services.dart';
import 'package:gyzyleller/modules/bottomnavbar/controllers/home_controller.dart';
import 'package:gyzyleller/shared/constants/icon_constants.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';

class AllSearchView extends StatefulWidget {
  const AllSearchView({super.key});

  @override
  State<AllSearchView> createState() => _AllSearchViewState();
}

class _AllSearchViewState extends State<AllSearchView> {
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  final AllController _allController = Get.find<AllController>();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeController = Get.find<HomeController>();
      homeController.disableBottomNavBar();
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _allController.status.value = 1;
      _allController.applyFilters(newSearch: query);
    });
  }

  @override
  void dispose() {
    final homeController = Get.find<HomeController>();
    homeController.enableBottomNavBar();
    _debounce?.cancel();
    _searchController.dispose();

    _allController.status.value = null;
    _allController.applyFilters(newSearch: "");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        backgroundColor: ColorConstants.background,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: ColorConstants.kPrimaryColor2,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          autofocus: true,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            fontSize: 15,
            color: ColorConstants.fonts,
          ),
          decoration: InputDecoration(
            hintText: 'search_hint'.tr,
            hintStyle:
                const TextStyle(fontSize: 15, color: ColorConstants.fonts),
            border: InputBorder.none,
            isDense: false,
            contentPadding: EdgeInsets.zero,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close,
                        size: 20, color: ColorConstants.fonts),
                    onPressed: () {
                      _debounce?.cancel();
                      _searchController.clear();
                      setState(() {});
                      _allController.status.value = null;
                      _allController.applyFilters(newSearch: "");
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (_allController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_searchController.text.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(IconConstants.emptysearch),
                const SizedBox(height: 50),
              ],
            ),
          );
        }

        if (_allController.jobs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(IconConstants.emptysearch),
                const SizedBox(height: 16),
                Text("no_tasks_found".tr,
                    style: const TextStyle(color: ColorConstants.fonts)),
                const SizedBox(height: 50),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: _allController.jobs.length,
          itemBuilder: (context, index) {
            return JobCard(
              job: _allController.jobs[index],
              isNew: false,
            );
          },
        );
      }),
    );
  }
}

import 'dart:async';
import 'package:gyzyleller/core/models/metadata_models.dart';
import 'package:gyzyleller/modules/filter_view/widgets/category_filter_page.dart';
import 'package:gyzyleller/modules/filter_view/widgets/etrap_filter_page.dart';
import 'package:gyzyleller/modules/filter_view/widgets/main_filter_page.dart';
import 'package:gyzyleller/modules/filter_view/widgets/price_filter_page.dart';
import 'package:gyzyleller/modules/filter_view/widgets/subcategory_filter_page.dart';
import 'package:gyzyleller/modules/filter_view/widgets/welayat_filter_page.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';

enum _FilterPage { main, category, subcategory, price, welayat, etrap }

class FilterBottomSheet extends StatefulWidget {
  final List<int>? initialCatIds;
  final List<int>? initialWelayatIds;
  final List<int>? initialEtrapIds;
  final List<DateTime>? initialDates;
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final String? initialSearch;
  final bool requestedInput;
  final bool processingInput;
  final Function(Map<String, dynamic>) onApply;

  const FilterBottomSheet({
    super.key,
    this.initialCatIds,
    this.initialWelayatIds,
    this.initialEtrapIds,
    this.initialDates,
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialSearch,
    this.requestedInput = false,
    this.processingInput = false,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  _FilterPage _currentPage = _FilterPage.main;

  final List<int> _selectedCatIds = [];
  final List<int> _selectedWelayatIds = [];
  final List<int> _selectedEtrapIds = [];
  DateTime? _startDate;
  DateTime? _endDate;
  RangeValues _priceRange = const RangeValues(0, 10000);

  CategoryModel? _activeCategory;
  LocationModel? _activeWelayat;

  int _resultCount = 0;
  bool _isCountLoading = false;
  Timer? _countDebounce;

  final MyJobsService _jobsService = MyJobsService();
  List<LocationModel> _locations = [];
  List<CategoryModel> _categories = [];
  bool _isCategoriesLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialCatIds != null) {
      _selectedCatIds.addAll(widget.initialCatIds!);
    }
    if (widget.initialWelayatIds != null) {
      _selectedWelayatIds.addAll(widget.initialWelayatIds!);
    }
    if (widget.initialEtrapIds != null) {
      _selectedEtrapIds.addAll(widget.initialEtrapIds!);
    }
    if (widget.initialDates != null && widget.initialDates!.isNotEmpty) {
      _startDate = widget.initialDates!.first;
      if (widget.initialDates!.length > 1) _endDate = widget.initialDates!.last;
    }
    _priceRange = RangeValues(
      widget.initialMinPrice ?? 0,
      widget.initialMaxPrice ?? 10000,
    );
    _fetchCount();
    _fetchLocations();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isCategoriesLoading = true);
    try {
      final cats = await _jobsService.getCategories();
      setState(() {
        _categories = cats;
        _isCategoriesLoading = false;
      });
    } catch (e) {
      setState(() => _isCategoriesLoading = false);
    }
  }

  Future<void> _fetchLocations() async {
    try {
      final locations = await _jobsService.getLocations();
      setState(() {
        _locations = locations;
      });
    } catch (e) {}
  }

  void _scheduleFetchCount() {
    _countDebounce?.cancel();
    _countDebounce = Timer(const Duration(milliseconds: 400), _fetchCount);
  }

  Future<void> _fetchCount() async {
    if (!mounted) return;
    setState(() => _isCountLoading = true);
    try {
      final response = await _jobsService.getMyJobs(
        limit: 1,
        catIds: _selectedCatIds,
        welayatIds: _selectedWelayatIds,
        etrapIds: _selectedEtrapIds,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        dates: _startDate != null
            ? [_startDate!, if (_endDate != null) _endDate!]
            : null,
        search: widget.initialSearch,
        requestedInput: widget.requestedInput,
        processingInput: widget.processingInput,
        requiresToken: widget.requestedInput || widget.processingInput,
      );
      if (!mounted) return;
      setState(() {
        _resultCount = response.data.count;
        _isCountLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCountLoading = false);
    }
  }

  void _showCustomYearPicker() {
    DateTime? tempStart = _startDate;
    DateTime? tempEnd = _endDate;
    DateTime focusedDay = _startDate ?? DateTime.now();
    bool isPickerVisible = false;
    int selectedYearForPicker = focusedDay.year;
    final yearScrollController = ScrollController(
        initialScrollOffset: (selectedYearForPicker - 2000) * 48.0);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildPicker() {
              final months = [
                'month_1'.tr,
                'month_2'.tr,
                'month_3'.tr,
                'month_4'.tr,
                'month_5'.tr,
                'month_6'.tr,
                'month_7'.tr,
                'month_8'.tr,
                'month_9'.tr,
                'month_10'.tr,
                'month_11'.tr,
                'month_12'.tr
              ];

              return Container(
                height: 300,
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: yearScrollController,
                        itemCount: 102,
                        itemExtent: 48,
                        itemBuilder: (context, index) {
                          final year = 2000 + index;
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                selectedYearForPicker = year;
                              });
                            },
                            child: Center(
                              child: Text(
                                year.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: year == selectedYearForPicker
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: year == selectedYearForPicker
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: 12,
                        itemExtent: 48,
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                focusedDay =
                                    DateTime(selectedYearForPicker, month);
                                isPickerVisible = false;
                              });
                            },
                            child: Center(
                              child: Text(
                                months[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: month == focusedDay.month &&
                                          selectedYearForPicker ==
                                              focusedDay.year
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: month == focusedDay.month &&
                                          selectedYearForPicker ==
                                              focusedDay.year
                                      ? Colors.red
                                      : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Dialog(
                insetPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorConstants.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          TableCalendar(
                            firstDay: DateTime(2000),
                            lastDay: DateTime(2101),
                            focusedDay: focusedDay,
                            rangeStartDay: tempStart,
                            rangeEndDay: tempEnd,
                            rangeSelectionMode: RangeSelectionMode.enforced,
                            calendarFormat: CalendarFormat.month,
                            availableCalendarFormats: const {
                              CalendarFormat.month: 'Month',
                            },
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextFormatter: (date, locale) {
                                final months = [
                                  'month_1'.tr,
                                  'month_2'.tr,
                                  'month_3'.tr,
                                  'month_4'.tr,
                                  'month_5'.tr,
                                  'month_6'.tr,
                                  'month_7'.tr,
                                  'month_8'.tr,
                                  'month_9'.tr,
                                  'month_10'.tr,
                                  'month_11'.tr,
                                  'month_12'.tr
                                ];
                                return '${months[date.month - 1]} ${date.year}';
                              },
                              titleTextStyle: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              leftChevronIcon: const Icon(
                                Icons.chevron_left,
                                color: Colors.black87,
                              ),
                              rightChevronIcon: const Icon(
                                Icons.chevron_right,
                                color: Colors.black87,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                            ),
                            onHeaderTapped: (date) {
                              setDialogState(() {
                                isPickerVisible = !isPickerVisible;
                                selectedYearForPicker = date.year;
                              });
                            },
                            daysOfWeekStyle: DaysOfWeekStyle(
                              weekdayStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                              weekendStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                                fontSize: 13,
                              ),
                              dowTextFormatter: (date, locale) {
                                final days = [
                                  'sunday_short'.tr,
                                  'monday_short'.tr,
                                  'tuesday_short'.tr,
                                  'wednesday_short'.tr,
                                  'thursday_short'.tr,
                                  'friday_short'.tr,
                                  'saturday_short'.tr
                                ];
                                return days[date.weekday % 7];
                              },
                            ),
                            calendarStyle: CalendarStyle(
                              rangeStartDecoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              rangeEndDecoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              withinRangeTextStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              // ignore: deprecated_member_use
                              rangeHighlightColor: Colors.red.withOpacity(0.3),
                              todayDecoration: BoxDecoration(
                                border: Border.all(
                                  color: ColorConstants.kPrimaryColor2,
                                  width: 1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              todayTextStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                              defaultTextStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              weekendTextStyle: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              outsideTextStyle: TextStyle(
                                color: Colors.grey.shade400,
                              ),
                            ),
                            onRangeSelected: (start, end, focused) {
                              setDialogState(() {
                                tempStart = start;
                                tempEnd = end ?? start;
                                focusedDay = focused;
                              });
                            },
                            onPageChanged: (focused) {
                              setDialogState(() {
                                focusedDay = focused;
                              });
                            },
                          ),
                          if (isPickerVisible) buildPicker(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "cancel".tr,
                              style: const TextStyle(
                                color: ColorConstants.kPrimaryColor2,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _startDate = tempStart;
                                _endDate = tempEnd;
                              });
                              _scheduleFetchCount();
                              Navigator.pop(context);
                            },
                            child: Text(
                              "OK".tr,
                              style: const TextStyle(
                                color: ColorConstants.kPrimaryColor2,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _goToPricePage() => setState(() => _currentPage = _FilterPage.price);

  void _goToCategoryPage() {
    setState(() => _currentPage = _FilterPage.category);
    if (_categories.isEmpty && !_isCategoriesLoading) {
      _fetchCategories();
    }
  }

  void _goToSubcategoryPage(CategoryModel category) {
    setState(() {
      _currentPage = _FilterPage.subcategory;
      _activeCategory = category;
    });
  }

  void _goToLocationPage() =>
      setState(() => _currentPage = _FilterPage.welayat);

  void _goToEtrapPage(LocationModel welayat) {
    setState(() {
      _currentPage = _FilterPage.etrap;
      _activeWelayat = welayat;
    });
  }

  void _selectAllActiveSubcategories() {
    final category = _activeCategory;
    if (category == null) return;
    setState(() {
      for (final subcategory in category.subcategories) {
        if (!_selectedCatIds.contains(subcategory.id)) {
          _selectedCatIds.add(subcategory.id);
        }
      }
    });
    _scheduleFetchCount();
  }

  void _clearActiveSubcategories() {
    final category = _activeCategory;
    if (category == null) return;
    final activeIds = category.subcategories.map((item) => item.id).toSet();
    setState(() {
      _selectedCatIds.removeWhere(activeIds.contains);
    });
    _scheduleFetchCount();
  }

  void _selectAllActiveEtraps() {
    final welayat = _activeWelayat;
    if (welayat == null) return;
    setState(() {
      for (final etrap in welayat.etraps) {
        if (!_selectedEtrapIds.contains(etrap.id)) {
          _selectedEtrapIds.add(etrap.id);
        }
      }
    });
    _scheduleFetchCount();
  }

  void _clearActiveEtraps() {
    final welayat = _activeWelayat;
    if (welayat == null) return;
    final activeIds = welayat.etraps.map((item) => item.id).toSet();
    setState(() {
      _selectedEtrapIds.removeWhere(activeIds.contains);
    });
    _scheduleFetchCount();
  }

  void _goBack() {
    if (_currentPage == _FilterPage.subcategory) {
      setState(() => _currentPage = _FilterPage.category);
    } else if (_currentPage == _FilterPage.etrap) {
      setState(() => _currentPage = _FilterPage.welayat);
    } else {
      setState(() => _currentPage = _FilterPage.main);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.only(top: 12),
      height: height * 0.78,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Column(
        children: [
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 10),
          _buildHeader(),
          const SizedBox(height: 10),
          Expanded(child: _buildContent()),
          _buildBottomButtons(width),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String title;
    bool showBackButton = _currentPage != _FilterPage.main;

    switch (_currentPage) {
      case _FilterPage.main:
        title = "Filter".tr;
        break;
      case _FilterPage.category:
        title = "category".tr;
        break;
      case _FilterPage.subcategory:
        title = _activeCategory?.name ?? "subcategory".tr;
        break;
      case _FilterPage.price:
        title = "price".tr;
        break;
      case _FilterPage.welayat:
        title = "location".tr;
        break;
      case _FilterPage.etrap:
        title = _activeWelayat?.name ?? "etrap".tr;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: showBackButton
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: _goBack,
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowLeft01,
                        size: 24,
                        color: Colors.black,
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(
              width: 40,
              child: !showBackButton
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        size: 24,
                        color: Colors.black,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    String selectedYearText = '';
    if (_startDate != null && _endDate != null) {
      selectedYearText = isSameDay(_startDate, _endDate)
          ? _startDate!.year.toString()
          : " 20${_startDate!.year % 100} - 20${_endDate!.year % 100}";
    } else if (_startDate != null) {
      selectedYearText = _startDate!.year.toString();
    }

    switch (_currentPage) {
      case _FilterPage.main:
        return MainFilterPage(
          onCategoryTap: _goToCategoryPage,
          categoryValue: _getCategoryValueText(),
          onLocationTap: _goToLocationPage,
          locationValue: _getLocationValueText(),
          onPriceTap: _goToPricePage,
          priceValue:
              "${_priceRange.start.toInt()} TMT – ${_priceRange.end.toInt()} TMT",
          onYearTap: _showCustomYearPicker,
          selectedYear: selectedYearText,
        );
      case _FilterPage.category:
        if (_isCategoriesLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.grey[200],
            ),
          );
        }
        return CategoryFilterPage(
          categories: _categories,
          selectedCatIds: _selectedCatIds,
          onCategorySelected: _goToSubcategoryPage,
          onClear: () {
            setState(() => _selectedCatIds.clear());
            _scheduleFetchCount();
          },
        );
      case _FilterPage.subcategory:
        if (_isCategoriesLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.grey[200],
            ),
          );
        }
        if (_activeCategory == null) {
          return const SizedBox.shrink();
        }
        return SubcategoryFilterPage(
          category: _activeCategory!,
          selectedCatIds: _selectedCatIds,
          onSubcategoryChanged: (id) {
            setState(() {
              if (_selectedCatIds.contains(id)) {
                _selectedCatIds.remove(id);
              } else {
                _selectedCatIds.add(id);
              }
            });
            _scheduleFetchCount();
          },
          onSelectAll: _selectAllActiveSubcategories,
          onClear: _clearActiveSubcategories,
        );
      case _FilterPage.price:
        return PriceFilterPage(
          priceRange: _priceRange,
          minPrice: 0,
          maxPrice: 10000,
          onPriceChanged: (values) {
            setState(() => _priceRange = values);
            _scheduleFetchCount();
          },
          onClear: () {
            setState(() => _priceRange = const RangeValues(0, 10000));
            _scheduleFetchCount();
          },
          onApply: _goBack,
        );
      case _FilterPage.welayat:
        return WelayatFilterPage(
          locations: _locations,
          selectedWelayatIds: _selectedWelayatIds,
          selectedEtrapIds: _selectedEtrapIds,
          onWelayatSelected: _goToEtrapPage,
          onWelayatCheckChanged: (id) {
            setState(() {
              if (_selectedWelayatIds.contains(id)) {
                _selectedWelayatIds.remove(id);
              } else {
                _selectedWelayatIds.add(id);
              }
            });
            _scheduleFetchCount();
          },
          onClear: () {
            setState(() {
              _selectedWelayatIds.clear();
              _selectedEtrapIds.clear();
            });
            _scheduleFetchCount();
          },
          onApply: _goBack,
        );
      case _FilterPage.etrap:
        return EtrapFilterPage(
          welayat: _activeWelayat!,
          selectedEtrapIds: _selectedEtrapIds,
          onEtrapChanged: (id) {
            setState(() {
              if (_selectedEtrapIds.contains(id)) {
                _selectedEtrapIds.remove(id);
              } else {
                _selectedEtrapIds.add(id);
              }
            });
            _scheduleFetchCount();
          },
          onSelectAll: _selectAllActiveEtraps,
          onClear: _clearActiveEtraps,
          onApply: _goBack,
        );
    }
  }

  String _getLocationValueText() {
    if (_selectedEtrapIds.isNotEmpty) {
      return "${_selectedEtrapIds.length} ${"etrap_selected".tr}";
    }
    if (_selectedWelayatIds.isNotEmpty) {
      return "${_selectedWelayatIds.length} ${"welayat_selected".tr}";
    }
    return "all".tr;
  }

  String _getCategoryValueText() {
    if (_selectedCatIds.isNotEmpty) {
      return "${_selectedCatIds.length} ${"category_selected".tr}";
    }
    return "all".tr;
  }

  Widget _buildBottomButtons(double width) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          if (_currentPage == _FilterPage.main)
            SizedBox(
              width: width,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: ColorConstants.background,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _selectedCatIds.clear();
                    _selectedWelayatIds.clear();
                    _selectedEtrapIds.clear();
                    _priceRange = const RangeValues(0, 10000);
                    _startDate = null;
                    _endDate = null;
                  });
                  _scheduleFetchCount();
                  widget.onApply({
                    'catIds': <int>[],
                    'welayatIds': <int>[],
                    'etrapIds': <int>[],
                    'minPrice': null,
                    'maxPrice': null,
                    'dates': null,
                  });
                },
                child: Text(
                  "clear_all".tr,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: width,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: ColorConstants.kPrimaryColor2,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (_currentPage != _FilterPage.main) {
                  _goBack();
                } else {
                  widget.onApply({
                    'catIds': _selectedCatIds,
                    'welayatIds': _selectedWelayatIds,
                    'etrapIds': _selectedEtrapIds,
                    'minPrice': _priceRange.start,
                    'maxPrice': _priceRange.end,
                    'dates': _startDate != null
                        ? [_startDate!, if (_endDate != null) _endDate!]
                        : null,
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(
                (_currentPage != _FilterPage.main)
                    ? "${"saylamak".tr} (${_isCountLoading ? "..." : _resultCount})"
                    : "jobs_found".trParams({
                        "count":
                            _isCountLoading ? "..." : _resultCount.toString()
                      }),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

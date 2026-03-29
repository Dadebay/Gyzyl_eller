import 'package:gyzyleller/core/models/metadata_models.dart';
import 'package:gyzyleller/modules/filter_view/widgets/category_filter_page.dart';
import 'package:gyzyleller/modules/filter_view/widgets/etrap_filter_page.dart';
import 'package:gyzyleller/modules/filter_view/widgets/main_filter_page.dart';
import 'package:gyzyleller/modules/filter_view/widgets/price_filter_page.dart';
import 'package:gyzyleller/modules/filter_view/widgets/subcategory_filter_page.dart';
import 'package:gyzyleller/modules/filter_view/widgets/welayat_filter_page.dart';
import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';

// Enum to manage the current page view inside the bottom sheet
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
  // State variables
  _FilterPage _currentPage = _FilterPage.main;

  // Selection state
  final List<int> _selectedCatIds = [];
  final List<int> _selectedWelayatIds = [];
  final List<int> _selectedEtrapIds = [];
  DateTime? _startDate;
  DateTime? _endDate;
  RangeValues _priceRange = const RangeValues(0, 10000);

  // Current view context
  CategoryModel? _activeCategory;
  LocationModel? _activeWelayat;

  int _resultCount = 0;
  bool _isCountLoading = false;

  final MyJobsService _jobsService = MyJobsService();
  List<LocationModel> _locations = [];
  bool _isLocationsLoading = false;
  List<CategoryModel> _categories = [];

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
    try {
      final cats = await _jobsService.getCategories();
      setState(() {
        _categories = cats;
      });
    } catch (e) {}
  }

  Future<void> _fetchLocations() async {
    setState(() => _isLocationsLoading = true);
    try {
      final locations = await _jobsService.getLocations();
      setState(() {
        _locations = locations;
        _isLocationsLoading = false;
      });
    } catch (e) {
      setState(() => _isLocationsLoading = false);
    }
  }

  Future<void> _fetchCount() async {
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
      setState(() {
        _resultCount = response.data.count;
        _isCountLoading = false;
      });
    } catch (e) {
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

  void _goToPricePage() {
    setState(() {
      _currentPage = _FilterPage.price;
    });
  }

  void _goToCategoryPage() {
    setState(() {
      _currentPage = _FilterPage.category;
    });
  }

  void _goToSubcategoryPage(CategoryModel category) {
    setState(() {
      _currentPage = _FilterPage.subcategory;
      _activeCategory = category;
    });
  }

  void _goToLocationPage() {
    setState(() {
      _currentPage = _FilterPage.welayat;
    });
  }

  void _goToEtrapPage(LocationModel welayat) {
    setState(() {
      _currentPage = _FilterPage.etrap;
      _activeWelayat = welayat;
    });
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
            /// BACK BUTTON
            SizedBox(
              width: 40,
              child: showBackButton
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: _goBack,
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                        color: Colors.black,
                      ),
                    )
                  : null,
            ),

            /// TITLE
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

            /// CLOSE BUTTON
            SizedBox(
              width: 40,
              child: !showBackButton
                  ? IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
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
    String selectedYearText;
    if (_startDate != null && _endDate != null) {
      if (isSameDay(_startDate, _endDate)) {
        selectedYearText = _startDate!.year.toString();
      } else {
        selectedYearText =
            " 20${_startDate!.year % 100} - 20${_endDate!.year % 100}";
      }
    } else if (_startDate != null) {
      selectedYearText = _startDate!.year.toString();
    } else {
      selectedYearText = '';
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
        return CategoryFilterPage(
          categories: _categories,
          selectedCatIds: _selectedCatIds,
          onCategorySelected: _goToSubcategoryPage,
        );
      case _FilterPage.subcategory:
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
            _fetchCount();
          },
        );
      case _FilterPage.price:
        return PriceFilterPage(
          priceRange: _priceRange,
          minPrice: 0,
          maxPrice: 10000,
          onPriceChanged: (values) {
            setState(() {
              _priceRange = values;
            });
            _fetchCount();
          },
          onClear: () {
            setState(() {
              _priceRange = const RangeValues(0, 10000);
            });
            _fetchCount();
          },
        );
      case _FilterPage.welayat:
        if (_isLocationsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_locations.isEmpty) {
          return Center(child: Text('no_data_found'.tr));
        }
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
            _fetchCount();
          },
          onClear: () {
            setState(() {
              _selectedWelayatIds.clear();
              _selectedEtrapIds.clear();
            });
            _fetchCount();
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
            _fetchCount();
          },
        );
    }
  }

  String _getLocationValueText() {
    if (_selectedEtrapIds.isNotEmpty) {
      if (_selectedEtrapIds.length == 1) {
        for (var l in _locations) {
          for (var e in l.etraps) {
            if (e.id == _selectedEtrapIds.first) return e.name;
          }
        }
      }
      return "${_selectedEtrapIds.length} ${"etrap_selected".tr}";
    }
    if (_selectedWelayatIds.isNotEmpty) {
      if (_selectedWelayatIds.length == 1) {
        for (var l in _locations) {
          if (l.id == _selectedWelayatIds.first) return l.name;
        }
      }
      return "${_selectedWelayatIds.length} ${"welayat_selected".tr}";
    }
    return "all".tr;
  }

  String _getCategoryValueText() {
    if (_selectedCatIds.isNotEmpty) {
      if (_selectedCatIds.length == 1) {
        final id = _selectedCatIds.first;
        for (var c in _categories) {
          if (c.id == id) return c.name;
          for (var s in c.subcategories) {
            if (s.id == id) return s.name;
          }
        }
      }
      return "${_selectedCatIds.length} ${"category_selected".tr}";
    }
    return "all".tr;
  }

  Widget _buildBottomButtons(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (_currentPage == _FilterPage.main)
            SizedBox(
              width: width,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: ColorConstants.kPrimaryColor,
                  foregroundColor: Colors.white,
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
                  _fetchCount();
                  widget.onApply({
                    'catIds': <int>[],
                    'welayatIds': <int>[],
                    'etrapIds': <int>[],
                    'minPrice': null,
                    'maxPrice': null,
                    'dates': <DateTime>[],
                  });
                },
                child: Text(
                  "clear_all".tr,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (_currentPage == _FilterPage.main) const SizedBox(height: 12),
          SizedBox(
            width: width,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: ColorConstants.kPrimaryColor2,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isCountLoading
                  ? null
                  : () {
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
                    },
              child: _isCountLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white))
                  : Text(
                      "jobs_found".trParams({"count": _resultCount.toString()}),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

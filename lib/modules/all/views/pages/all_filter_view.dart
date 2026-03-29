import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';
import 'package:gyzyleller/core/models/my_tasks_status.dart';
import 'package:gyzyleller/core/services/my_jobs_service.dart';

class AllFilterView extends StatefulWidget {
  final int? initialStatus;
  final int resultCount;
  final Function(int?) onApply;

  const AllFilterView({
    super.key,
    required this.initialStatus,
    required this.resultCount,
    required this.onApply,
  });

  @override
  State<AllFilterView> createState() => _AllFilterViewState();
}

class _AllFilterViewState extends State<AllFilterView> {
  late int? _selectedStatus;
  late int _currentCount;
  bool _isCountLoading = false;
  final MyJobsService _service = MyJobsService();

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _currentCount = widget.resultCount;
  }

  Future<void> _fetchNewCount(int? status) async {
    setState(() {
      _isCountLoading = true;
    });

    try {
      final response = await _service.getMyJobs(
        page: 0,
        limit: 1,
        status: status,
      );
      if (mounted) {
        setState(() {
          _currentCount = response.data.count;
          _isCountLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCountLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ColorConstants.kPrimaryColor2),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Filter'.tr,
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedStatus = null;
              });
              _fetchNewCount(null);
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildRadioList(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildRadioList() {
    const options = MyTasksStatus.values;
    return Container(
      color: Colors.white,
      child: Column(
        children: List.generate(options.length, (index) {
          final status = options[index];
          final isSelected = _selectedStatus == status.apiValue;
          return InkWell(
            onTap: () {
              if (_selectedStatus != status.apiValue) {
                setState(() {
                  _selectedStatus = status.apiValue;
                });
                _fetchNewCount(status.apiValue);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      status.displayName,
                      style: TextStyle(
                        color: isSelected ? ColorConstants.kPrimaryColor2 : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? ColorConstants.kPrimaryColor2 : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorConstants.kPrimaryColor2,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ElevatedButton(
        onPressed: () {
          widget.onApply(_selectedStatus);
          Get.back();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.kPrimaryColor2,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _isCountLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                "${"Result".tr} ($_currentCount)",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

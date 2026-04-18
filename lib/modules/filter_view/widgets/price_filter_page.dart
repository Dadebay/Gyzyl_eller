import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class PriceFilterPage extends StatefulWidget {
  final RangeValues priceRange;
  final double minPrice;
  final double maxPrice;
  final ValueChanged<RangeValues> onPriceChanged;
  final VoidCallback onClear;
  final VoidCallback onApply;

  static const double kLimit = 1000000;
  static const double kSliderLimit = 10000;

  const PriceFilterPage({
    super.key,
    required this.priceRange,
    this.minPrice = 0,
    this.maxPrice = kLimit,
    required this.onPriceChanged,
    required this.onClear,
    required this.onApply,
  });

  @override
  State<PriceFilterPage> createState() => _PriceFilterPageState();
}

class _PriceFilterPageState extends State<PriceFilterPage> {
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  final FocusNode _startFocus = FocusNode();
  final FocusNode _endFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _startController = TextEditingController(
      text: (widget.priceRange.start == 0) ? '' : widget.priceRange.start.toInt().toString(),
    );
    // end field starts empty when at max (not yet selected by user)
    _endController = TextEditingController(
      text: (widget.priceRange.end == widget.maxPrice) ? '' : widget.priceRange.end.toInt().toString(),
    );
  }

  @override
  void didUpdateWidget(PriceFilterPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.priceRange != widget.priceRange) {
      if (!_startFocus.hasFocus) {
        final s = (widget.priceRange.start == 0) ? '' : widget.priceRange.start.toInt().toString();
        if (_startController.text != s) _startController.text = s;
      }
      if (!_endFocus.hasFocus) {
        // if cleared back to max, show empty; otherwise show value
        final e = (widget.priceRange.end == widget.maxPrice) ? '' : widget.priceRange.end.toInt().toString();
        if (_endController.text != e) _endController.text = e;
      }
    }
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _startFocus.dispose();
    _endFocus.dispose();
    super.dispose();
  }

  void _onStartChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    final clamped = parsed.clamp(widget.minPrice, widget.priceRange.end);
    widget.onPriceChanged(RangeValues(clamped, widget.priceRange.end));
  }

  void _onStartSubmitted(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) {
      _startController.text = widget.priceRange.start.toInt().toString();
      return;
    }
    final clamped = parsed.clamp(widget.minPrice, widget.priceRange.end);
    widget.onPriceChanged(RangeValues(clamped, widget.priceRange.end));
  }

  void _onEndChanged(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) return;
    final clamped = parsed.clamp(widget.priceRange.start, widget.maxPrice);
    widget.onPriceChanged(RangeValues(widget.priceRange.start, clamped));
  }

  void _onEndSubmitted(String value) {
    final parsed = double.tryParse(value);
    if (parsed == null) {
      _endController.text = widget.priceRange.end == widget.maxPrice ? '' : widget.priceRange.end.toInt().toString();
      return;
    }
    final clamped = parsed.clamp(widget.priceRange.start, widget.maxPrice);
    widget.onPriceChanged(RangeValues(widget.priceRange.start, clamped));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "price".tr,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              GestureDetector(
                onTap: widget.onClear,
                child: Text(
                  "clear_all".tr,
                  style: const TextStyle(
                    color: ColorConstants.kPrimaryColor2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _priceBox(
                label: "from".tr,
                controller: _startController,
                focusNode: _startFocus,
                onChanged: _onStartChanged,
                onSubmitted: _onStartSubmitted,
              ),
              const SizedBox(width: 12),
              _priceBox(
                label: "to".tr,
                controller: _endController,
                focusNode: _endFocus,
                onChanged: _onEndChanged,
                onSubmitted: _onEndSubmitted,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: RangeSlider(
            values: RangeValues(
              widget.priceRange.start.clamp(widget.minPrice, PriceFilterPage.kSliderLimit),
              widget.priceRange.end.clamp(widget.minPrice, PriceFilterPage.kSliderLimit),
            ),
            min: widget.minPrice,
            max: PriceFilterPage.kSliderLimit,
            divisions: 100,
            activeColor: ColorConstants.kPrimaryColor2,
            inactiveColor: ColorConstants.background,
            labels: RangeLabels(
              "${widget.priceRange.start.toInt()}",
              "${widget.priceRange.end.toInt()}",
            ),
            onChanged: widget.onPriceChanged,
          ),
        ),
      ],
    );
  }

  Widget _priceBox({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onSubmitted,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: ColorConstants.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.done,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.only(top: 5),
                  ),
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  onTapOutside: (_) {
                    if (focusNode.hasFocus) {
                      onSubmitted(controller.text);
                      focusNode.unfocus();
                    }
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 10),
                child: Text(
                  'TMT',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

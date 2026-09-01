import 'package:flutter/material.dart';
import 'package:gyzyleller/core/theme/custom_color_scheme.dart';

class BioTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String> onChanged;
  final String? errorText;

  const BioTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.maxLength,
    required this.onChanged,
    this.errorText,
  });

  @override
  State<BioTextField> createState() => _BioTextFieldState();
}

class _BioTextFieldState extends State<BioTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() => setState(() {}));
    widget.controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasContent =
        _focusNode.hasFocus || widget.controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: ColorConstants.whiteColor,
            borderRadius: BorderRadius.circular(10),
            border: (widget.errorText != null && widget.errorText!.isNotEmpty)
                ? Border.all(color: Colors.red, width: 1)
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            onChanged: widget.onChanged,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              counterText: '',
              labelText: hasContent ? widget.hintText : null,
              hintText: hasContent ? null : widget.hintText,
              floatingLabelBehavior: FloatingLabelBehavior.always,
              alignLabelWithHint: true,
              labelStyle: const TextStyle(color: ColorConstants.secondary),
              hintStyle: const TextStyle(color: ColorConstants.secondary),
              contentPadding: hasContent
                  ? const EdgeInsets.symmetric(horizontal: 15, vertical: 10)
                  : const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: (widget.errorText != null && widget.errorText!.isNotEmpty)
                    ? Text(
                        widget.errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      )
                    : const SizedBox.shrink(),
              ),
              if (widget.maxLength != null)
                Text(
                  '${widget.controller.text.length}/${widget.maxLength}',
                  style: const TextStyle(
                    color: ColorConstants.secondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

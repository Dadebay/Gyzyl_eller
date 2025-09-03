import 'package:gyzyleller/shared/extensions/packages.dart';
import 'package:kartal/kartal.dart';

class CustomTextField extends StatefulWidget {
  final String labelName;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode requestfocusNode;
  final IconData? prefixIcon;
  final int? maxLine;
  final bool? enabled;
  final bool isPassword;

  const CustomTextField({
    required this.labelName,
    required this.controller,
    required this.focusNode,
    required this.requestfocusNode,
    this.maxLine,
    this.prefixIcon,
    this.enabled,
    this.isPassword = false,
    Key? key,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(top: 25),
      child: TextFormField(
        style: context.general.textTheme.bodyLarge!.copyWith(
          color: widget.enabled == false
              ? ColorConstants.greyColor
              : isDarkMode
                  ? context.whiteColor
                  : ColorConstants.blackColor,
          fontWeight: FontWeight.w600,
        ),
        enabled: widget.enabled ?? true,
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscureText : false,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'textfield_error'.tr;
          }
          return null;
        },
        onEditingComplete: () {
          widget.requestfocusNode.requestFocus();
        },
        keyboardType: TextInputType.text,
        maxLines: widget.maxLine ?? 1,
        focusNode: widget.focusNode,
        textInputAction: TextInputAction.done,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          prefixIconConstraints: BoxConstraints(minWidth: widget.prefixIcon == null ? 20 : 10, minHeight: 0),
          prefixIcon: widget.prefixIcon == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Icon(
                    widget.prefixIcon,
                    color: ColorConstants.greyColor,
                    size: WidgetSizes.size128.value,
                  ),
                ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: ColorConstants.greyColor,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          labelText: widget.labelName.tr,
          labelStyle: context.general.textTheme.bodyLarge!.copyWith(
            color: ColorConstants.greyColor,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelAlignment: FloatingLabelAlignment.start,
          contentPadding: const EdgeInsets.only(left: 10, top: 18, bottom: 18, right: 10),
          isDense: true,
          alignLabelWithHint: true,
          border: _buildOutlineInputBorder(borderColor: ColorConstants.blackColor),
          enabledBorder: _buildOutlineInputBorder(borderColor: context.greyColor.withOpacity(.2)),
          focusedBorder: _buildOutlineInputBorder(borderColor: isDarkMode ? context.whiteColor.withOpacity(.4) : context.blackColor),
          focusedErrorBorder: _buildOutlineInputBorder(borderColor: ColorConstants.redColor),
          errorBorder: _buildOutlineInputBorder(borderColor: ColorConstants.redColor),
        ),
      ),
    );
  }

  OutlineInputBorder _buildOutlineInputBorder({Color? borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: borderColor ?? Colors.grey, width: 2),
    );
  }
}

class PhoneNumberTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode requestfocusNode;
  const PhoneNumberTextField({
    required this.controller,
    required this.focusNode,
    required this.requestfocusNode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: TextFormField(
        style: context.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w400, fontSize: 16),
        controller: controller,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'errorEmpty'.tr;
          }
          if (value.length != 8) {
            return 'errorPhoneCount'.tr;
          }
          return null;
        },
        onEditingComplete: () {
          requestfocusNode.requestFocus();
        },
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(8),
          FilteringTextInputFormatter.digitsOnly,
        ],
        maxLines: 1,
        focusNode: focusNode,
        textInputAction: TextInputAction.next,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.call, color: context.greyColor, size: 20),
                SizedBox(width: 5),
                Text(
                  '+993 ',
                  style: context.textTheme.bodyLarge!.copyWith(color: context.greyColor, fontSize: 16),
                ),
              ],
            ),
          ),
          hintText: 'xxxxxxxx',
          hintStyle: TextStyle(color: context.greyColor),
          prefixIconConstraints: BoxConstraints(minWidth: 80),
          contentPadding: const EdgeInsets.only(left: 20, top: 14, bottom: 12, right: 10),
          isDense: true,
          border: _buildOutlineInputBorder(borderColor: ColorConstants.kPrimaryColor.withOpacity(.2)),
          enabledBorder: _buildOutlineInputBorder(borderColor: context.greyColor.withOpacity(.5)),
          focusedBorder: _buildOutlineInputBorder(borderColor: isDarkMode ? context.whiteColor : context.blackColor),
          focusedErrorBorder: _buildOutlineInputBorder(borderColor: Colors.red),
          errorBorder: _buildOutlineInputBorder(borderColor: Colors.red),
        ),
      ),
    );
  }

  OutlineInputBorder _buildOutlineInputBorder({Color? borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: borderColor ?? Colors.grey, width: 1),
    );
  }
}

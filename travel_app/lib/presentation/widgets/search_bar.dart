import 'package:flutter/material.dart';

const kPrimaryBlue = Color(0xFF154BCB);
const kSecondaryOrange = Color(0xFFFF8500);
const kCardBgColor = Color(0xFFF1F5FE);
const kBorderColor = Color(0xFFD8E0F2);
const kLightGrey = Color(0xFFE8E8E8);
const kTextGrey = Color(0xFF757575);

class SearchBarWidget extends StatefulWidget {
  final Function(String)? onSearchChanged;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;

  const SearchBarWidget({
    super.key,
    this.onSearchChanged,
    this.hintText,
    this.controller,
    this.initialValue,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _isUsingExternalController = false;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      _controller = widget.controller!;
      _isUsingExternalController = true;
    } else {
      _controller = TextEditingController(text: widget.initialValue ?? '');
      _isUsingExternalController = false;
    }

    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);

    if (!_isUsingExternalController) {
      _controller.dispose();
    }

    super.dispose();
  }

  void _onTextChanged() {
    if (widget.onSearchChanged != null) {
      widget.onSearchChanged!(_controller.text);
    }

    setState(() {});
  }

  void _clearSearch() {
    _controller.clear();
    if (widget.onSearchChanged != null) {
      widget.onSearchChanged!('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Cari destinasi atau lokasi...',
          hintStyle: TextStyle(
            color: kTextGrey,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: kPrimaryBlue,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: kTextGrey,
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: kPrimaryBlue,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: kCardBgColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black87,
        ),
      ),
    );
  }
}

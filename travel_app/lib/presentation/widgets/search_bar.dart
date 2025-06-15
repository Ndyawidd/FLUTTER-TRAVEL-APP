import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String)? onSearchChanged;
  final String? hintText;

  const SearchBarWidget({
    super.key,
    this.onSearchChanged,
    this.hintText,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onChanged: (value) {
              if (widget.onSearchChanged != null) {
                widget.onSearchChanged!(value);
              }
              setState(() {}); // untuk update tombol clear
            },
            decoration: InputDecoration(
              hintText: widget.hintText ?? "Search",
              hintStyle: const TextStyle(color: Color(0xFF1F509A)),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF1F509A),
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Color(0xFF1F509A),
                        size: 20,
                      ),
                      onPressed: () {
                        _controller.clear();
                        if (widget.onSearchChanged != null) {
                          widget.onSearchChanged!('');
                        }
                        setState(() {}); // update tampilan
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF1F509A),
                  width: 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFFE38E49),
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF1F509A),
                  width: 2.0,
                ),
              ),
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

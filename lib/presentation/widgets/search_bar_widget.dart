import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final bool isAiEnabled;
  final Function(String) onSearch;
  final VoidCallback onAiToggle;
  final bool isLoading;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.isAiEnabled,
    required this.onSearch,
    required this.onAiToggle,
    this.isLoading = false,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: widget.isAiEnabled
                    ? 'ค้นหาสินค้าด้วย AI...'
                    : 'ค้นหาสินค้า...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                suffix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // AI Toggle Icon
                    GestureDetector(
                      onTap: widget.onAiToggle,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.isAiEnabled
                              ? Colors.blue.shade100
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.psychology,
                          color: widget.isAiEnabled ? Colors.blue : Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Search Icon
                    IconButton(
                      icon: widget.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search, color: Colors.blue),
                      onPressed: widget.isLoading
                          ? null
                          : () => widget.onSearch(widget.controller.text),
                    ),
                  ],
                ),
              ),
              onSubmitted: widget.isLoading ? null : widget.onSearch,
            ),
          ),
        ],
      ),
    );
  }
}

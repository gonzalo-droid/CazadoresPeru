import 'package:flutter/material.dart';

import '../../../domain/entities/search_filters.dart';

class SortOptionsBar extends StatelessWidget {
  const SortOptionsBar({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final SearchFilters current;
  final void Function(SearchFilters) onChanged;

  static const _options = [
    _SortOption(label: 'Más reciente', sortBy: 'id', direction: 'desc'),
    _SortOption(
      label: 'Mayor recompensa',
      sortBy: 'montoRecompensa',
      direction: 'desc',
    ),
    _SortOption(label: 'Por región', sortBy: 'departamento', direction: 'asc'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final opt = _options[i];
          final isSelected =
              current.sortBy == opt.sortBy && current.direction == opt.direction;
          return FilterChip(
            label: Text(opt.label),
            selected: isSelected,
            onSelected: (_) {
              onChanged(
                current.copyWith(
                  sortBy: opt.sortBy,
                  direction: opt.direction,
                  page: 1,
                ),
              );
            },
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          );
        },
      ),
    );
  }
}

class _SortOption {
  const _SortOption({
    required this.label,
    required this.sortBy,
    required this.direction,
  });

  final String label;
  final String sortBy;
  final String direction;
}

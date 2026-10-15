import 'package:flutter/material.dart';

enum FilterPeriod {
  all,
  today,
  week,
  month,
}

class EmployeeFiltersWidget extends StatelessWidget {
  final FilterPeriod selectedFilter;
  final ValueChanged<FilterPeriod> onFilterChanged;
  final String? sortBy;
  final ValueChanged<String?>? onSortChanged;

  const EmployeeFiltersWidget({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.sortBy,
    this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                context,
                'All',
                FilterPeriod.all,
                Icons.all_inclusive,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                'Today',
                FilterPeriod.today,
                Icons.today,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                'Week',
                FilterPeriod.week,
                Icons.calendar_view_week,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                context,
                'Month',
                FilterPeriod.month,
                Icons.calendar_month,
              ),
            ],
          ),
        ),
        if (onSortChanged != null) ...[
          const SizedBox(height: 12),
          // Sort Options
          Row(
            children: [
              const Text(
                'Sort by:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<String>(
                  value: sortBy ?? 'recent',
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'recent', child: Text('Most Recent')),
                    DropdownMenuItem(value: 'critical', child: Text('Most Critical')),
                    DropdownMenuItem(value: 'name', child: Text('Name (A-Z)')),
                    DropdownMenuItem(value: 'date', child: Text('Registration Date')),
                  ],
                  onChanged: onSortChanged,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    FilterPeriod period,
    IconData icon,
  ) {
    final isSelected = selectedFilter == period;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onFilterChanged(period);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
}



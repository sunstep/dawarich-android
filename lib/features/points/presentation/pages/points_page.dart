import 'package:dawarich/core/di/dependency_injection.dart';
import 'package:dawarich/core/theme/app_gradients.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/core/shell/drawer/drawer.dart';
import 'package:dawarich/shared/widgets/custom_appbar.dart';
import 'package:dawarich/features/points/presentation/models/points_page_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class PointsPage extends StatelessWidget {

  const PointsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<PointsPageViewModel>()..initialize(),
      builder: (ctx, child) => Consumer<PointsPageViewModel>(builder: (ctx, vm, child) {
        return Container(
          decoration: BoxDecoration(gradient: Theme.of(context).pageBackground),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: CustomAppbar(
              title: 'Points',
              titleFontSize: 32,
              backgroundColor: Colors.transparent,
            ),
            drawer: CustomDrawer(),
            body: SafeArea(child: _PointsBody()),
          ),
        );
      },
      )
    );
  }
}

class _PointsBody extends StatelessWidget {
  const _PointsBody();

  Future<void> _pickStart(BuildContext ctx) async {
    final vm = ctx.read<PointsPageViewModel>();
    final picked = await showDatePicker(
      context: ctx,
      initialDate: vm.startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      vm.setStartDate(picked);
      // vm.searchPressed(); // Auto refresh: takes too long to load now.
    }
  }

  Future<void> _pickEnd(BuildContext ctx) async {
    final vm = ctx.read<PointsPageViewModel>();
    final picked = await showDatePicker(
      context: ctx,
      initialDate: vm.endDate,
      firstDate: vm.startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final endOfDay =
          DateTime(picked.year, picked.month, picked.day, 23, 59, 59, 999, 999);
      vm.setEndDate(endOfDay);
      // vm.searchPressed(); // Auto refresh: takes too long to load now.
    }
  }

  Future<void> _confirmDeletion(BuildContext c, PointsPageViewModel vm) async {

    final confirmed = await showDialog<bool>(
      context: c,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text(
          "Are you sure you want to delete the selected point(s)? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await vm.deleteSelection();
        await vm.searchPressed();

        if (c.mounted) {
          ScaffoldMessenger.of(c).showSnackBar(
            const SnackBar(content: Text("Points deleted.")),
          );
        }
      } catch (e) {
        if (c.mounted) {
          ScaffoldMessenger.of(c).showSnackBar(
            SnackBar(content: Text("Failed to delete points: $e")),
          );
        }
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PointsPageViewModel>();


    // 3) Otherwise, real content:
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ————— filters toggle row —————
          Row(
            children: [
              IconButton(
                icon: Icon(
                  vm.displayFilters ? Icons.expand_less : Icons.expand_more,
                ),
                onPressed: vm.toggleDisplayFilters,
              ),
              Text(
                'Filters',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                onPressed: vm.searchPressed,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),

          // ————— the filter card itself (only if showFilters=true) —————
          if (vm.displayFilters) ...[
            const SizedBox(height: 8),
            _FilterCard(
              onPickStart: () => _pickStart(context),
              onPickEnd: () => _pickEnd(context),
            ),
            const SizedBox(height: 16),
          ],

          // ————— results list or skeleton —————
          Expanded(
            child: Builder(
              builder: (_) {
                if (vm.isLoading) {
                  return const PointsPageSkeleton();
                } else if (vm.pagePoints.isEmpty) {
                  return const _EmptyPointsState();
                } else {
                  return _PointsList();
                }
              },
            ),
          ),

          // ————— footer —————

          if (vm.pagePoints.isNotEmpty) ...[
            const SizedBox(height: 16),
            _FooterBar(
              hasSelection: vm.hasSelectedItems(),
              onSelectAll: vm.toggleSelectAll,
              onDelete: () => _confirmDeletion(context, vm),
              onRefresh: vm.searchPressed,
              onFirst: vm.navigateFirst,
              onBack: vm.navigateBack,
              onNext: vm.navigateNext,
              onLast: vm.navigateLast,
              currentPage: vm.currentPage,
              totalPages: vm.totalPages,
              sortByNew: vm.sortByNew,
              toggleSort: vm.toggleSort,
            ),
          ]
        ],
      ),
    );
  }
}

/// Renders the full “filter→list→footer” skeleton with shimmer.
class PointsPageSkeleton extends StatelessWidget {
  const PointsPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade400;
    final highlightColor = isDark ? Colors.grey.shade600 : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ➤ filter skeleton
            Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: Container(height: 48, color: baseColor)),
                    const SizedBox(width: 12),
                    Expanded(child: Container(height: 48, color: baseColor)),
                    const SizedBox(width: 12),
                    Container(width: 96, height: 48, color: baseColor),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ➤ list skeleton
            Expanded(
              child: ListView.separated(
                itemCount: 9,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, __) => Row(
                  children: [
                    const SizedBox(
                        width: 40,
                        child: Checkbox(value: false, onChanged: null)),
                    const SizedBox(width: 12),
                    Expanded(child: Container(height: 16, color: baseColor)),
                    const SizedBox(width: 12),
                    Container(width: 80, height: 16, color: baseColor),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ➤ footer skeleton
            Row(
              children: [
                Container(width: 120, height: 32, color: baseColor),
                const SizedBox(width: 8),
                Container(width: 80, height: 32, color: baseColor),
                const Spacer(),
                Container(width: 100, height: 32, color: baseColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card around the two date “chips” + search button.
/// • Chips will flex to share available space.
/// • If there’s absolutely no room, they’ll wrap onto a new line.
class _FilterCard extends StatelessWidget {
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  const _FilterCard({
    required this.onPickStart,
    required this.onPickEnd,
  });

  @override
  Widget build(BuildContext c) {
    final PointsPageViewModel vm = c.watch<PointsPageViewModel>();

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: LayoutBuilder(builder: (ctx, constraints) {
          final isNarrow = constraints.maxWidth < 500;

          if (isNarrow) {
            // NARROW: stack everything vertically
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DateChip(
                  label: 'Start',
                  value: vm.formattedStart,
                  onTap: onPickStart,
                ),
                const SizedBox(height: 16),
                _DateChip(
                  label: 'End',
                  value: vm.formattedEnd,
                  onTap: onPickEnd,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: vm.showUnprocessed,
                  onChanged: vm.toggleShowUnprocessed,
                  title: const Text('Show unprocessed'),
                ),
                ElevatedButton(
                  onPressed: vm.searchPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Search'),
                ),
              ],
            );
          } else {
            // WIDE: two chips side-by-side + button
            return Row(
              children: [
                Expanded(
                  child: _DateChip(
                    label: 'Start',
                    value: vm.formattedStart,
                    onTap: onPickStart,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _DateChip(
                    label: 'End',
                    value: vm.formattedEnd,
                    onTap: onPickEnd,
                  ),
                ),
                const SizedBox(width: 16),
                SwitchListTile(
                  value: vm.showUnprocessed,
                  onChanged: vm.toggleShowUnprocessed,
                  title: const Text('Show unprocessed'),
                ),
                ElevatedButton(
                  onPressed: vm.searchPressed,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Search'),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}

/// A little “pill” that shows a calendar icon, a label, and the formatted date.
/// Tappable to invoke your date picker.
class _DateChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext c) {
    final cs = Theme.of(c).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 20, color: cs.onSurface),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(c)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSurface.withValues(alpha: 0.7)),
                ),
                Text(
                  value,
                  style: Theme.of(c)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The real list of points, styled as ListTiles in cards
class _PointsList extends StatelessWidget {
  @override
  Widget build(BuildContext c) {
    final vm = c.watch<PointsPageViewModel>();

    if (vm.pagePoints.isEmpty) {
      return const _EmptyPointsState();
    }

    final fmt = DateFormat('dd MMM yyyy, HH:mm:ss');
    return ListView.separated(
      itemCount: vm.pagePoints.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, idx) {
        final p = vm.pagePoints[idx];
        final selected = vm.selectedItems.contains(p.id.toString());
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: CheckboxListTile(
            value: selected,
            onChanged: (v) => vm.toggleSelection(idx, v),
            title: Text(fmt.format(
                DateTime.fromMillisecondsSinceEpoch(p.timestamp! * 1000))),
            subtitle: Text(
                '${p.geodata?.geometry?.coordinates?[0].toString()}, ${p.geodata?.geometry?.coordinates?[1].toString()}'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );
      },
    );
  }
}

class _EmptyPointsState extends StatelessWidget {
  const _EmptyPointsState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 64, color: cs.onBackground.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            'No points found',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try picking a different date.',
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onBackground.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Footer: either deletion buttons (when items selected) or pagination + sort toggle
class _FooterBar extends StatelessWidget {
  final bool hasSelection;
  final VoidCallback
      onSelectAll,
      onDelete,
      onRefresh,
      onFirst,
      onBack,
      onNext,
      onLast,
      toggleSort;
  final int currentPage, totalPages;
  final bool sortByNew;

  const _FooterBar({
    required this.hasSelection,
    required this.onSelectAll,
    required this.onDelete,
    required this.onRefresh,
    required this.onFirst,
    required this.onBack,
    required this.onNext,
    required this.onLast,
    required this.toggleSort,
    required this.currentPage,
    required this.totalPages,
    required this.sortByNew,
  });

  @override
  Widget build(BuildContext c) {
    final textStyle = Theme.of(c).textTheme.bodyMedium;

    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: hasSelection
            ? Row(
          children: [
            ElevatedButton(
              onPressed: onDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete', style: textStyle),
            ),
          ],
        )
            : Row(
          children: [
            const Spacer(),
            IconButton(onPressed: onFirst, icon: const Icon(Icons.first_page)),
            IconButton(onPressed: onBack, icon: const Icon(Icons.navigate_before)),
            Text('$currentPage/$totalPages', style: textStyle),
            IconButton(onPressed: onNext, icon: const Icon(Icons.navigate_next)),
            IconButton(onPressed: onLast, icon: const Icon(Icons.last_page)),
            TextButton(
              onPressed: toggleSort,
              child: Text(sortByNew ? 'Newest' : 'Oldest', style: textStyle),
            ),
          ],
        ),
      ),
    );
  }
}

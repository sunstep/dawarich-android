import 'package:flutter/material.dart';

class BatchExplorerAppbar extends StatelessWidget
    implements PreferredSizeWidget {
  const BatchExplorerAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "Batch Explorer",
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

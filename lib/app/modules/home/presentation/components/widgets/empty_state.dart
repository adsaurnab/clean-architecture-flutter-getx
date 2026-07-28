import 'package:flutter/material.dart';

import '../../../../../core/constants/gap_constants.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          gapH12,
          Text(
            'No products yet',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

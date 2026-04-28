import 'package:flutter/material.dart';

import '../../core/constants/package_status.dart';

class StatusBadge extends StatelessWidget {
  final PackageStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = _resolveStyle();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(icon, size: 12, color: color),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _resolveStyle() {
    return switch (status) {
      PackageStatus.transit =>
        (Colors.blue, Icons.inbox_rounded),
      PackageStatus.inBox =>
        (Colors.indigo, Icons.inventory_2_rounded),
      PackageStatus.inTransit =>
        (Colors.orange, Icons.local_shipping_rounded),
      PackageStatus.arrived =>
        (Colors.teal, Icons.location_on_rounded),
    };
  }
}

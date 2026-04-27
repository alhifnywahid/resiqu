enum PackageStatus {
  received('diterima', 'Diterima'),
  inBox('dalam_box', 'Dalam Box'),
  inTransit('dalam_perjalanan', 'Dalam Perjalanan'),
  arrived('tiba_di_tujuan', 'Tiba di Tujuan'),
  completed('selesai', 'Selesai'),
  issue('kendala', 'Kendala');

  const PackageStatus(this.value, this.label);

  final String value;
  final String label;

  static PackageStatus fromValue(String value) {
    return PackageStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () {
        // Backward compat: map old values
        switch (value) {
          case 'diterima_di_transit':
            return PackageStatus.received;
          case 'dalam_perjalanan':
            return PackageStatus.inTransit;
          case 'tiba_di_tujuan':
            return PackageStatus.arrived;
          default:
            return PackageStatus.received;
        }
      },
    );
  }
}

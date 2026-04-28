enum BatchStatus {
  collecting('collecting', 'Terbuka'),
  dispatched('dispatched', 'Dikirim'),
  arrived('arrived', 'Tiba di Tujuan');

  const BatchStatus(this.value, this.label);

  final String value;
  final String label;

  static BatchStatus fromValue(String value) {
    return BatchStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () {
        // Backward compat
        if (value == 'open') return BatchStatus.collecting;
        return BatchStatus.collecting;
      },
    );
  }
}

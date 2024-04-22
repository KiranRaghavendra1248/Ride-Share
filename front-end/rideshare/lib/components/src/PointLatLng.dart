class PointLatLng {

  /// Creates a geographical location specified in degrees [latitude] and
  /// [longitude].
  ///
  const PointLatLng(double latitude, double longitude)
      : this.latitude = latitude,
        this.longitude = longitude;

  /// The latitude in degrees.
  final double latitude;

  /// The longitude in degrees
  final double longitude;

  @override
  String toString() {
    return "$latitude,$longitude";
  }
}
class TrackingState {
  final bool isTracking;
  final double? currentLat;
  final double? currentLng;
  final double? savedLat;
  final double? savedLng;
  final String statusMessage;
  final bool hasPermission;
  final String permissionMessage;

  final bool isLocationServiceEnabled;

  TrackingState({
    this.isTracking = false,
    this.currentLat,
    this.currentLng,
    this.savedLat,
    this.savedLng,
    this.statusMessage = 'Initialized',
    this.hasPermission = false,
    this.permissionMessage = 'Not Requested',
    this.isLocationServiceEnabled = true,
  });

  // Helper to clone the state with updated fields
  TrackingState copyWith({
    bool? isTracking,
    double? currentLat,
    double? currentLng,
    double? savedLat,
    double? savedLng,
    String? statusMessage,
    bool? hasPermission,
    String? permissionMessage,
    bool? isLocationServiceEnabled,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      savedLat: savedLat ?? this.savedLat,
      savedLng: savedLng ?? this.savedLng,
      statusMessage: statusMessage ?? this.statusMessage,
      hasPermission: hasPermission ?? this.hasPermission,
      permissionMessage: permissionMessage ?? this.permissionMessage,
      isLocationServiceEnabled: isLocationServiceEnabled ?? this.isLocationServiceEnabled,
    );
  }
}
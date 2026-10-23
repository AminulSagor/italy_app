enum CourseDeviceAccessState { checking, authorized, blocked, error }

class CourseDeviceAccessResult {
  const CourseDeviceAccessResult({
    required this.authorized,
    required this.deviceKeyId,
    required this.requestedDeviceLabel,
    this.currentDeviceLabel,
    this.requestStatus,
  });

  final bool authorized;
  final String deviceKeyId;
  final String requestedDeviceLabel;
  final String? currentDeviceLabel;
  final String? requestStatus;

  bool get isPending => requestStatus == 'pending';
}

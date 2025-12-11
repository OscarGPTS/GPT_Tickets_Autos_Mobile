class TicketRequest {
  final String destination;
  final String? client;
  final DateTime requestedDate;
  final String requestedTimeStart;
  final String? requestedTimeEnd;
  final String purpose;
  final bool requiresReturn;
  final String? vehicleType;

  TicketRequest({
    required this.destination,
    this.client,
    required this.requestedDate,
    required this.requestedTimeStart,
    this.requestedTimeEnd,
    required this.purpose,
    this.requiresReturn = false,
    this.vehicleType,
  });

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'client': client,
      'requested_date': requestedDate.toIso8601String().split('T')[0],
      'requested_time_start': requestedTimeStart,
      'requested_time_end': requestedTimeEnd,
      'purpose': purpose,
      'requires_return': requiresReturn,
      'vehicle_type': vehicleType,
    };
  }
}

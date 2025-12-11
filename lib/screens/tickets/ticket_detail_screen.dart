import 'package:flutter/material.dart';
import 'checkout_screen_new.dart';

class TicketDetailScreen extends StatelessWidget {
  final String folio;
  final String destination;
  final String date;
  final String timeStart;
  final String? timeEnd;
  final String vehicle;
  final String status;

  const TicketDetailScreen({
    super.key,
    required this.folio,
    required this.destination,
    required this.date,
    required this.timeStart,
    this.timeEnd,
    required this.vehicle,
    required this.status,
  });

  Color _statusColor(BuildContext context) {
    switch (status.toLowerCase()) {
      case 'pendiente':
        return Colors.orange;
      case 'completado':
      case 'pagado':
        return Colors.green;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket $folio'),
        backgroundColor: scheme.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Folio $folio',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Chip(
                          label: Text(status),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: _statusColor(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _infoRow(Icons.location_on, 'Destino', destination),
                    _infoRow(Icons.calendar_today, 'Fecha', date),
                    _infoRow(Icons.schedule, 'Hora salida', timeStart),
                    if (timeEnd != null && timeEnd!.isNotEmpty)
                      _infoRow(Icons.schedule_outlined, 'Hora regreso', timeEnd!),
                    _infoRow(Icons.directions_car, 'Vehículo', vehicle),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Acciones',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CheckoutScreenNew(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.checklist_rtl),
                      label: const Text('Realizar checkout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

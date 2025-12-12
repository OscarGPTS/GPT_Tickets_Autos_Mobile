import 'package:flutter/material.dart';
import 'checkout_screen_new.dart';
import '../../models/ticket_model.dart';

class TicketDetailScreen extends StatelessWidget {
  final TicketModel ticket;

  // Constructor legacy para mantener compatibilidad
  const TicketDetailScreen({
    super.key,
    required this.ticket,
    String? folio,
    String? destination,
    String? date,
    String? timeStart,
    String? timeEnd,
    String? vehicle,
    String? status,
  });

  String get folio => ticket.folio;
  String get destination => ticket.destination ?? 'Sin destino';
  String get date => ticket.requestedDate?.toString().split(' ')[0] ?? '';
  String get timeStart => ticket.requestedTimeStart ?? '';
  String? get timeEnd => ticket.requestedTimeEnd;
  String get vehicle => ticket.vehicleName;
  String get status => ticket.status;

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
                            builder: (context) => CheckoutScreenNew(ticket: ticket),
                          ),
                        );
                      },
                      icon: const Icon(Icons.checklist_rtl),
                      label: Text(
                        ticket.hasCheckout ? 'Ver checkout' : 'Realizar checkout'
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: Colors.white,
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

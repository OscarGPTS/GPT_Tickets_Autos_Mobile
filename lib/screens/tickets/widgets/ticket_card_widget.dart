import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/ticket_model.dart';
import '../ticket_detail_screen.dart';

class TicketCardWidget extends StatelessWidget {
  final TicketModel ticket;
  
  const TicketCardWidget({
    super.key,
    required this.ticket,
  });

  Map<String, dynamic> _getCurrentStatus(TicketModel ticket) {
    if (ticket.hasCheckout && ticket.hasCheckin) {
      return {
        'label': 'Completado',
        'icon': Icons.check_circle,
        'color': Colors.green,
      };
    } else if (ticket.hasCheckout) {
      return {
        'label': 'Check Out',
        'icon': Icons.exit_to_app,
        'color': Colors.orange,
      };
    } else {
      return {
        'label': 'Check In',
        'icon': Icons.check_circle_outline,
        'color': Colors.blue,
      };
    }
  }

  Widget _buildStatusChip(TicketModel ticket, BuildContext context) {
    final status = _getCurrentStatus(ticket);
    final color = status['color'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status['icon'] as IconData, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            status['label'] as String,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TicketDetailScreen(ticket: ticket),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ticket.folio,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(ticket, context),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                ticket.destination ?? 'Sin destino especificado',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ticket.vehicleName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ticket.requestedDate != null &&
                                ticket.requestedTimeStart != null
                            ? ' el ${DateFormat('dd-MM-yyyy').format(ticket.requestedDate!)} '
                                'a las ${ticket.requestedTimeStart}'
                            : ticket.requestedDate != null
                                ? ' el ${DateFormat('dd-MM-yyyy').format(ticket.requestedDate!)}'
                                : 'Fecha no disponible',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),

                  if (ticket.purpose != null && ticket.purpose!.isNotEmpty)
                    Expanded(
                      child: Text(
                        ticket.purpose!,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}

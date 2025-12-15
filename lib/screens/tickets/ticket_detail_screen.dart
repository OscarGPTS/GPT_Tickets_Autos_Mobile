import 'package:flutter/material.dart';
import 'checkout_screen_new.dart';
import 'checkin_screen.dart';
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
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Barra de progreso de steps
                    _buildProgressSteps(scheme),
                    const SizedBox(height: 16),
                    const Divider(),
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
                    if (!ticket.hasCheckout)
                      // No tiene checkout: botón para realizar checkout
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CheckoutScreenNew(ticket: ticket),
                            ),
                          );
                        },
                        icon: const Icon(Icons.exit_to_app),
                        label: const Text('Realizar Check Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    if (ticket.hasCheckout && !ticket.hasCheckin)
                      // Tiene checkout pero no checkin: botón principal para checkin
                      Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckinScreen(ticket: ticket),
                                ),
                              );
                            },
                            icon: const Icon(Icons.login),
                            label: const Text('Realizar Check In'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: scheme.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutScreenNew(ticket: ticket),
                                ),
                              );
                            },
                            icon: const Icon(Icons.visibility),
                            label: const Text('Ver Check Out'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: scheme.primary,
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ],
                      ),
                    if (ticket.hasCheckout && ticket.hasCheckin)
                      // Tiene ambos: botones para ver ambos
                      Column(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckoutScreenNew(ticket: ticket),
                                ),
                              );
                            },
                            icon: const Icon(Icons.exit_to_app),
                            label: const Text('Ver Check Out'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: scheme.primary,
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CheckinScreen(ticket: ticket),
                                ),
                              );
                            },
                            icon: const Icon(Icons.login),
                            label: const Text('Ver Check In'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: scheme.primary,
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ],
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

  int _getCurrentStep() {
    // 0 = Aprobado (llegó aquí)
    // 1 = Check out realizado
    // 2 = Check in realizado
    // 3 = Completado
    
    if (ticket.hasCheckout && ticket.hasCheckin) {
      return 3; // Tiene ambos, completado
    } else if (ticket.hasCheckout) {
      return 1; // Solo tiene checkout
    } else {
      return 0; // Aprobado, sin checkout
    }
  }

  Widget _buildProgressSteps(ColorScheme scheme) {
    final currentStep = _getCurrentStep();
    final steps = [
      {'label': 'Aprobado', 'icon': Icons.check_circle_outline},
      {'label': 'Check Out', 'icon': Icons.exit_to_app},
      {'label': 'Check In', 'icon': Icons.login},
      {'label': 'Completado', 'icon': Icons.check_circle},
    ];

    return Row(
      children: [
        for (int index = 0; index < steps.length; index++) ...[
          // Círculo del paso
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index <= currentStep
                        ? scheme.primary
                        : Colors.grey.shade300,
                    border: Border.all(
                      color: index == currentStep
                          ? scheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    steps[index]['icon'] as IconData,
                    color: index <= currentStep ? Colors.white : Colors.grey.shade600,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[index]['label'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: index == currentStep ? FontWeight.bold : FontWeight.normal,
                    color: index <= currentStep
                        ? scheme.primary
                        : Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Línea conectora (solo entre pasos, no después del último)
          if (index < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 30),
                color: index < currentStep
                    ? scheme.primary
                    : Colors.grey.shade300,
              ),
            ),
        ],
      ],
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

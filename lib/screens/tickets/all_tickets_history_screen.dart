import 'package:flutter/material.dart';
import '../../services/user_tickets_service.dart';
import '../../services/storage_service.dart';
import '../../models/ticket_model.dart';
import 'widgets/ticket_card_widget.dart';

class AllTicketsHistoryScreen extends StatefulWidget {
  const AllTicketsHistoryScreen({super.key});

  @override
  State<AllTicketsHistoryScreen> createState() => _AllTicketsHistoryScreenState();
}

class _AllTicketsHistoryScreenState extends State<AllTicketsHistoryScreen> {
  final UserTicketsService _ticketsService = UserTicketsService();
  final StorageService _storageService = StorageService();
  
  List<TicketModel> _tickets = [];
  PaginationInfo? _pagination;
  int _currentPage = 1;
  bool _isLoading = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final email = await _storageService.getUserEmail();
    setState(() {
      _userEmail = email;
    });
    if (email != null) {
      _loadTickets();
    }
  }

  Future<void> _loadTickets() async {
    if (_userEmail == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await _ticketsService.getMyTickets(
        email: _userEmail!,
        page: _currentPage,
      );

      setState(() {
        _tickets = response.tickets;
        _pagination = response.pagination;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar tickets: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _loadNextPage() {
    if (_pagination?.hasMorePages ?? false) {
      setState(() => _currentPage++);
      _loadTickets();
    }
  }

  void _loadPreviousPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
      _loadTickets();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Tickets'),
        backgroundColor: scheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tickets.isEmpty
              ? RefreshIndicator(
                  onRefresh: _loadTickets,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 200,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 80,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay tickets en el historial',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Desliza hacia abajo para recargar',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Información de paginación
                    if (_pagination != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: scheme.primaryContainer.withOpacity(0.3),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 16,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Mostrando ${_pagination!.from ?? 0} - ${_pagination!.to ?? 0} de ${_pagination!.total} tickets',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Lista de tickets
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () {
                          setState(() => _currentPage = 1);
                          return _loadTickets();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _tickets.length,
                          itemBuilder: (context, index) {
                            final ticket = _tickets[index];
                            return TicketCardWidget(ticket: ticket);
                          },
                        ),
                      ),
                    ),
                    // Controles de paginación
                    if (_pagination != null && _pagination!.lastPage > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Botón anterior
                              OutlinedButton.icon(
                                onPressed: _currentPage > 1 ? _loadPreviousPage : null,
                                icon: const Icon(Icons.chevron_left, size: 20),
                                label: const Text('Anterior'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                              // Indicador de página
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Página $_currentPage de ${_pagination!.lastPage}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: scheme.primary,
                                  ),
                                ),
                              ),
                              // Botón siguiente
                              ElevatedButton.icon(
                                onPressed: _pagination!.hasMorePages
                                    ? _loadNextPage
                                    : null,
                                icon: const Icon(Icons.chevron_right, size: 20),
                                label: const Text('Siguiente'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: scheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

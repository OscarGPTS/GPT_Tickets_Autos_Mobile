import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/user_appbar_widget.dart';
import '../../widgets/feature_card_widget.dart';
import '../../widgets/app_footer_widget.dart';
import '../auth/login_screen.dart';
import '../vehicles/vehicles_screen.dart';
import '../tickets/tickets_screen.dart';
import '../debug/logs_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String? _userEmail;
  String? _photoUrl;
  String? _userName;
  bool _isLoading = true;
  bool _isSyncing = false;
  int _pendingTicketsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _syncWithBackend(); // Sincronizar con API en segundo plano
  }

  Future<void> _loadUserInfo() async {
    try {
      final user = await _authService.getUser();

      setState(() {
        _userEmail = user?.email ?? 'Usuario';
        _photoUrl = user?.photoUrl;
        _userName = user?.displayName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userEmail = 'Usuario';
        _photoUrl = null;
        _isLoading = false;
      });
    }
  }

  /// Actualizar contador de tickets desde storage local
  Future<void> _updateTicketCount() async {
    try {
      final tickets = await _authService.getTickets();
      if (mounted) {
        setState(() {
          _pendingTicketsCount = tickets.length;
        });
      }
    } catch (e) {
      // Error al obtener tickets, mantener contador actual
    }
  }

  /// Sincronizar con el backend para obtener tickets del despachador
  Future<void> _syncWithBackend() async {
    setState(() => _isSyncing = true);

    try {
      final result = await _authService.syncWithBackend();

      if (mounted) {
        if (result.success) {
          // Actualizar contador de tickets
          setState(() {
            _pendingTicketsCount = result.tickets?.length ?? 0;
          });

          // Sincronización exitosa
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ ${_pendingTicketsCount} ticket${_pendingTicketsCount != 1 ? 's' : ''} pendiente${_pendingTicketsCount != 1 ? 's' : ''}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          // Error en la sincronización (pero no es crítico)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No se pudieron cargar los tickets: ${result.message}'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
              action: SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: _syncWithBackend,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: _syncWithBackend,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        elevation: 0,
        backgroundColor: scheme.primary,
        leadingWidth: 280,
        actions: [
          UserAppBarWidget(
            userName: _userName,
            userEmail: _userEmail,
            photoUrl: _photoUrl,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Contenido principal
                          Padding(
                            padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Opciones disponibles',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        FeatureCardWidget(
                          icon: Icons.car_rental,
                          title: 'Mis Vehículos',
                          description: 'Gestiona tus vehículos registrados',
                          color: scheme.primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VehiclesScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        FeatureCardWidget(
                          icon: Icons.description,
                          title: 'Tickets',
                          description: 'Ver y gestionar tickets',
                          color: scheme.secondary,
                          badgeCount: _pendingTicketsCount,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TicketsScreen(),
                              ),
                            );
                            // Actualizar contador cuando regrese
                            _updateTicketCount();
                          },
                        ),
                        const SizedBox(height: 16),

                        // Opción de logs (debug)
                        FeatureCardWidget(
                          icon: Icons.bug_report,
                          title: 'Logs del Sistema',
                          description: 'Ver errores y logs de la aplicación',
                          color: Colors.purple,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LogsScreen(),
                              ),
                            );
                          },
                        ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      
                      // Spacer para empujar el footer al final
                      const Spacer(),
                      
                      // Footer
                      const AppFooterWidget(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

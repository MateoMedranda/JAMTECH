import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../chatbot_view.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/mi_caja_tab.dart';
import 'tabs/cobrar_tab.dart';
import 'tabs/menu_tab.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _fabController;
  late Animation<double> _fabScaleAnim;
  
  Offset? _fabPosition;

  final List<Widget> _bottomTabs = [
    const _InicioView(),
    const MiCajaTab(),
    const MenuTab(),
  ];

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_rounded, iconOutlined: Icons.home_outlined, label: 'Inicio'),
    _NavItem(icon: Icons.point_of_sale_rounded, iconOutlined: Icons.point_of_sale_outlined, label: 'Mi Caja'),
    _NavItem(icon: Icons.menu_rounded, iconOutlined: Icons.menu_outlined, label: 'Menú'),
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fabScaleAnim = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  String _getHeaderTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Mi Caja';
      case 2:
        return 'Menú';
      default:
        return 'JAMTECH';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    final nombre = user?.nombre.split(' ').first ?? 'Usuario';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(nombre, user),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final bodyWidth = constraints.maxWidth;
            final bodyHeight = constraints.maxHeight;
            const fabSize = 88.0;
            const margin = 16.0;

            final maxX = (bodyWidth - fabSize).clamp(0.0, double.infinity);
            final maxY = (bodyHeight - fabSize - margin).clamp(0.0, double.infinity);

            // Inicializar posición solo una vez, en la esquina inferior derecha
            if (_fabPosition == null) {
              _fabPosition = Offset(maxX - margin, maxY);
            } else {
              // Re-ajustar si la pantalla cambia de tamaño
              _fabPosition = Offset(
                _fabPosition!.dx.clamp(0.0, maxX),
                _fabPosition!.dy.clamp(0.0, maxY),
              );
            }

            return Stack(
              children: [
                IndexedStack(
                  index: _currentIndex,
                  children: _bottomTabs,
                ),
                Positioned(
                  left: _fabPosition!.dx,
                  top: _fabPosition!.dy,
                  child: _buildChatbotFab(context, maxX: maxX, maxY: maxY),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String nombre, dynamic user) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _currentIndex == 0
            ? Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hola! $nombre',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              )
            : Text(
                _getHeaderTitle(),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
      ),
      actions: [
        if (_currentIndex == 0) ...[
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.textPrimary, size: 24),
            onPressed: () {},
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 26),
                onPressed: () {},
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.headset_mic_outlined, color: AppColors.textPrimary, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ]
      ],
      bottom: _currentIndex == 0
          ? PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.divider, width: 1.5),
                  ),
                ),
                child: TabBar(
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Cobrar'),
                    Tab(text: 'Gestionar'),
                  ],
                ),
              ),
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 0.5,
                color: AppColors.divider,
              ),
            ),
    );
  }

  Widget _buildChatbotFab(BuildContext context, {required double maxX, required double maxY}) {
    return ScaleTransition(
      scale: _fabScaleAnim,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, child) {
          return Transform.scale(scale: _pulseAnim.value, child: child);
        },
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _fabPosition = Offset(
                (_fabPosition!.dx + details.delta.dx).clamp(0.0, maxX),
                (_fabPosition!.dy + details.delta.dy).clamp(0.0, maxY),
              );
            });
          },
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const ChatbotView(),
                transitionsBuilder: (_, anim, __, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 1),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: anim,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Container(
            width: 88,
            height: 88,
            child: Stack(
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/Lupita_Logo_burbuja.png',
                    width: 88,
                    height: 88,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4ADE80),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'IA',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _currentIndex == index;

              return GestureDetector(
                onTap: () => setState(() => _currentIndex = index),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? item.icon : item.iconOutlined,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      size: 26,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _InicioView extends StatelessWidget {
  const _InicioView();

  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: [
        CobrarTab(),
        DashboardTab(),
      ],
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData iconOutlined;
  final String label;

  _NavItem({
    required this.icon,
    required this.iconOutlined,
    required this.label,
  });
}

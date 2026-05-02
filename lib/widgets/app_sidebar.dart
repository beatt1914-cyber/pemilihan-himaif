import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/data_service.dart';
import 'himaif_logo.dart';
import 'candidate_photo.dart';

enum SidebarItem {
  beranda,
  kandidat,
  voting,
  riwayat,
  profil,
  // admin
  dashboard,
  kelolaKandidat,
  kelolaPemilih,
  hasilVoting,
  pengaturan,
}

/// Responsive scaffold: sidebar inline on wide, drawer on narrow
class ResponsiveScaffold extends StatelessWidget {
  final SidebarItem activeItem;
  final Function(SidebarItem) onItemTap;
  final Widget body;
  final bool isAdmin;
  final String title;
  final List<Widget>? actions;

  const ResponsiveScaffold({
    super.key,
    required this.activeItem,
    required this.onItemTap,
    required this.body,
    required this.title,
    this.isAdmin = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        final sidebar = _SidebarContent(
          activeItem: activeItem,
          onItemTap: onItemTap,
          isAdmin: isAdmin,
        );
        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(width: 220, child: sidebar),
                Expanded(child: body),
              ],
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              title: Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              actions: actions,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            ),
            drawer: Drawer(child: sidebar),
            body: body,
          );
        }
      },
    );
  }
}

class _SidebarContent extends StatelessWidget {
  final SidebarItem activeItem;
  final Function(SidebarItem) onItemTap;
  final bool isAdmin;

  const _SidebarContent({
    required this.activeItem,
    required this.onItemTap,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final ds = DataService();
    return Container(
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: const HimaifLogo(size: 56, showText: true, darkBg: true),
          ),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: isAdmin ? _buildAdminItems(context) : _buildUserItems(context),
            ),
          ),
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.primaryBlue,
                  backgroundImage: ds.currentUser?.profileImagePath != null
                      ? getImageProvider(ds.currentUser!.profileImagePath!)
                      : null,
                  child: ds.currentUser?.profileImagePath == null
                      ? Text(
                          (ds.currentUser?.name ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ds.currentUser?.name ?? 'User',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isAdmin ? 'Administrator' : 'Mahasiswa',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6), fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUserItems(BuildContext context) => [
        _tile(context, Icons.dashboard_rounded, 'Beranda', SidebarItem.beranda),
        _tile(context, Icons.people_rounded, 'Kandidat', SidebarItem.kandidat),
        _tile(context, Icons.how_to_vote_rounded, 'Voting', SidebarItem.voting),
        _tile(context, Icons.history_rounded, 'Riwayat', SidebarItem.riwayat),
        _tile(context, Icons.person_rounded, 'Profil', SidebarItem.profil),
        const SizedBox(height: 8),
        const Divider(color: Colors.white12),
        _logoutTile(context),
      ];

  List<Widget> _buildAdminItems(BuildContext context) => [
        _tile(context, Icons.dashboard_rounded, 'Dashboard', SidebarItem.dashboard),
        _tile(context, Icons.people_rounded, 'Kandidat', SidebarItem.kandidat),
        _tile(context, Icons.how_to_vote_rounded, 'Pemilih', SidebarItem.kelolaPemilih),
        _tile(context, Icons.bar_chart_rounded, 'Hasil Voting', SidebarItem.hasilVoting),
        const Divider(color: Colors.white12),
        _label('MANAJEMEN'),
        _tile(context, Icons.manage_accounts_rounded, 'Kelola Kandidat', SidebarItem.kelolaKandidat),
        _tile(context, Icons.settings_rounded, 'Pengaturan', SidebarItem.pengaturan),
        const SizedBox(height: 8),
        const Divider(color: Colors.white12),
        _logoutTile(context),
      ];

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
        child: Text(text,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w600)),
      );

  Widget _tile(BuildContext context, IconData icon, String label, SidebarItem item) {
    final isActive = activeItem == item;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.sidebarActive : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon,
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
            size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          // Close drawer if it's open (narrow screen mode)
          final scaffold = Scaffold.maybeOf(context);
          if (scaffold != null && scaffold.isDrawerOpen) {
            scaffold.closeDrawer();
          }
          onItemTap(item);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _logoutTile(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: ListTile(
          dense: true,
          leading: Icon(Icons.logout_rounded, color: Colors.red.shade300, size: 20),
          title: Text('Logout',
              style: TextStyle(color: Colors.red.shade300, fontSize: 13)),
          onTap: () {
            DataService().logout();
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (_) => false);
          },
        ),
      );
}

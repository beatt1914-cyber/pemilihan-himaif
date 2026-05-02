import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/user/dashboard_screen.dart';
import 'screens/user/candidates_list_screen.dart';
import 'screens/user/candidate_detail_screen.dart';
import 'screens/user/voting_confirm_screen.dart';
import 'screens/user/voting_success_screen.dart';
import 'screens/user/profile_screen.dart';
import 'screens/user/history_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/manage_candidates_screen.dart';
import 'screens/admin/manage_voters_screen.dart';
import 'screens/admin/add_candidate_screen.dart';
import 'screens/admin/voting_results_screen.dart';
import 'screens/admin/admin_settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  runApp(const HimaifApp());
}

class HimaifApp extends StatelessWidget {
  const HimaifApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Pemilihan Kandidat HIMAIF',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.light().textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                const BorderSide(color: Color(0xFF1565C0), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        // User routes
        '/user/dashboard': (_) => const UserDashboardScreen(),
        '/user/candidates': (_) => const CandidatesListScreen(),
        '/user/candidate-detail': (_) => const CandidateDetailScreen(),
        '/user/voting-confirm': (_) => const VotingConfirmScreen(),
        '/user/voting-success': (_) => const VotingSuccessScreen(),
        '/user/profile': (_) => const ProfileScreen(),
        '/user/history': (_) => const HistoryScreen(),
        // Admin routes
        '/admin/dashboard': (_) => const AdminDashboardScreen(),
        '/admin/candidates': (context) => const ManageCandidatesScreen(),
        '/admin/add-candidate': (context) => const AddCandidateScreen(),
        '/admin/voters': (context) => const ManageVotersScreen(),
        '/admin/settings': (context) => const AdminSettingsScreen(),
        '/admin/results': (_) => const VotingResultsScreen(),
      },
    );
  }
}

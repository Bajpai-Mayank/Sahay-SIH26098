import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/models/user_role.dart';
import '../../../shared/widgets/app_buttons.dart';
import '../../../shared/widgets/app_card.dart';

/// User Authentication Screen with quick demo-role switches for testing and audits.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'participant@example.org');
  final _passwordController = TextEditingController(text: 'Password123');
  bool _obscurePassword = true;
  UserRole _selectedRole = UserRole.victim;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // Set persona user
      ref.read(currentUserProvider.notifier).setUser(UserModel(
        id: 'user-${_selectedRole.name}-01',
        email: _emailController.text.trim(),
        fullName: _selectedRole == UserRole.victim
            ? 'Demo Participant'
            : _selectedRole == UserRole.counsellor
                ? 'Pooja Sharma (Counsellor)'
                : 'Rajesh Verma (District Lead)',
        role: _selectedRole,
        activeCaseId: 'CASE-1042',
      ));

      if (_selectedRole == UserRole.counsellor) {
        context.go('/counsellor');
      } else if (_selectedRole == UserRole.districtAdmin) {
        context.go('/district');
      } else {
        context.go('/victim');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.s24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.s32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.s12),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.spa_rounded,
                            size: 36,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Text(
                        'Welcome to SAHAY-AI',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s4),
                      Text(
                        'Sign in to access your secure support portal',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.s24),

                      // Demo Role Switcher
                      Text(
                        'Explore As:',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.s8),
                      SegmentedButton<UserRole>(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.primarySoft;
                            }
                            return Colors.transparent;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.selected)) {
                              return AppColors.primaryDark;
                            }
                            return AppColors.textSecondary;
                          }),
                        ),
                        segments: const [
                          ButtonSegment(
                            value: UserRole.victim,
                            label: Text('Participant'),
                            icon: Icon(Icons.person_outline, size: 16),
                          ),
                          ButtonSegment(
                            value: UserRole.counsellor,
                            label: Text('Counsellor'),
                            icon: Icon(Icons.support_agent_outlined, size: 16),
                          ),
                          ButtonSegment(
                            value: UserRole.districtAdmin,
                            label: Text('District'),
                            icon: Icon(Icons.analytics_outlined, size: 16),
                          ),
                        ],
                        selected: {_selectedRole},
                        onSelectionChanged: (set) {
                          setState(() {
                            _selectedRole = set.first;
                            if (_selectedRole == UserRole.victim) {
                              _emailController.text = 'participant@example.org';
                            } else if (_selectedRole == UserRole.counsellor) {
                              _emailController.text = 'counsellor@example.org';
                            } else {
                              _emailController.text = 'district.lead@example.gov';
                            }
                          });
                        },
                      ),

                      const SizedBox(height: AppSpacing.s20),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                        ),
                        validator: FormValidators.email,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: FormValidators.requiredField,
                      ),
                      const SizedBox(height: AppSpacing.s24),
                      AppButton(
                        label: 'Sign In',
                        onPressed: _handleLogin,
                      ),
                      const SizedBox(height: AppSpacing.s16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "New to SAHAY-AI? ",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          InkWell(
                            onTap: () => context.push('/register'),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

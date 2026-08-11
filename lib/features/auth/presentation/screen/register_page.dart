import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_travel_10/core/constants/app_colors.dart';
import 'package:flutter_travel_10/core/constants/app_routes.dart';
import 'package:flutter_travel_10/core/constants/app_sizes.dart';
import 'package:flutter_travel_10/core/constants/app_strings.dart';
import 'package:flutter_travel_10/core/di/auth_locator.dart';
import 'package:flutter_travel_10/core/theme/text_styles.dart';
import 'package:flutter_travel_10/core/utils/validators.dart';

import 'package:flutter_travel_10/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_travel_10/features/auth/presentation/cubit/auth_state.dart';

import 'package:flutter_travel_10/features/auth/presentation/widget/auth_button.dart';
import 'package:flutter_travel_10/features/auth/presentation/widget/auth_footer.dart';
import 'package:flutter_travel_10/features/auth/presentation/widget/auth_header.dart';
import 'package:flutter_travel_10/features/auth/presentation/widget/auth_logo.dart';
import 'package:flutter_travel_10/features/auth/presentation/widget/auth_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  String _selectedRole = 'rider';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  void _register(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthCubit>().register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _selectedRole,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Something went wrong')),
            );
          }

          if (state.status == AuthStatus.authenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;

          return Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const AuthLogo(),

                        const SizedBox(height: AppSizes.paddingXLarge),

                        const AuthHeader(
                          title: "Create Account",
                          subtitle: "Create your account to continue",
                        ),

                        const SizedBox(height: AppSizes.paddingXLarge),

                        AuthTextField(
                          controller: _nameController,
                          hintText: "Full Name",
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Name is required";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: AppSizes.paddingMedium),

                        AuthTextField(
                          controller: _phoneController,
                          hintText: "Phone Number",
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Phone is required";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: AppSizes.paddingMedium),

                        AuthTextField(
                          controller: _emailController,
                          hintText: AppStrings.email,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),

                        const SizedBox(height: AppSizes.paddingMedium),

                        AuthTextField(
                          controller: _passwordController,
                          hintText: AppStrings.password,
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          isPassword: true,
                          validator: Validators.validatePassword,
                          onTogglePassword: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),

                        const SizedBox(height: AppSizes.paddingXLarge),

                        _RoleSelector(
                          selectedRole: _selectedRole,
                          onChanged: (role) {
                            setState(() {
                              _selectedRole = role;
                            });
                          },
                        ),

                        const SizedBox(height: AppSizes.paddingXLarge),

                        AuthButton(
                          title: AppStrings.register,
                          loading: isLoading,
                          onPressed: () => _register(context),
                        ),

                        const SizedBox(height: AppSizes.paddingLarge),

                        AuthFooter(
                          title: "Already have an account? ",
                          actionText: AppStrings.login,
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

//======================================================
// Role Selector
//======================================================

class _RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const _RoleSelector({required this.selectedRole, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleOption(
            title: AppStrings.iAmRider,
            icon: Icons.person,
            isSelected: selectedRole == 'rider',
            onTap: () => onChanged('rider'),
          ),
        ),

        const SizedBox(width: AppSizes.paddingMedium),

        Expanded(
          child: _RoleOption(
            title: AppStrings.iAmDriver,
            icon: Icons.local_taxi,
            isSelected: selectedRole == 'driver',
            onTap: () => onChanged('driver'),
          ),
        ),
      ],
    );
  }
}

//======================================================
// Role Option
//======================================================

class _RoleOption extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey.shade600,
            ),

            const SizedBox(height: AppSizes.paddingXSmall),

            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

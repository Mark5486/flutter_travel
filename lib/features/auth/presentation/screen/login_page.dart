import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_travel_10/core/constants/app_routes.dart';
import 'package:flutter_travel_10/core/constants/app_sizes.dart';
import 'package:flutter_travel_10/core/constants/app_strings.dart';
import 'package:flutter_travel_10/core/di/core_locator.dart';
import 'package:flutter_travel_10/core/utils/validators.dart';

import 'package:flutter_travel_10/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_travel_10/features/auth/presentation/cubit/auth_state.dart';

import 'package:flutter_travel_10/features/auth/presentation/widget/auth_button.dart';
import 'package:flutter_travel_10/features/auth/presentation/widget/auth_footer.dart';
import 'package:flutter_travel_10/features/auth/presentation/widget/auth_header.dart';
import 'package:flutter_travel_10/features/auth/presentation/widget/auth_logo.dart';
import 'package:flutter_travel_10/features/auth/presentation/widget/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
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
                          title: AppStrings.welcomeBack,
                          subtitle: AppStrings.loginSubtitle,
                        ),

                        const SizedBox(height: AppSizes.paddingXLarge),

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

                        AuthButton(
                          title: AppStrings.login,
                          loading: isLoading,
                          onPressed: () => _login(context),
                        ),

                        const SizedBox(height: AppSizes.paddingLarge),

                        AuthFooter(
                          title: AppStrings.dontHaveAccount,
                          actionText: AppStrings.registerNow,
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.register,
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

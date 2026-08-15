import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widget/auth_button.dart';
import '../widget/auth_footer.dart';
import '../widget/auth_header.dart';
import '../widget/auth_logo.dart';
import '../widget/auth_text_field.dart';

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
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    context.read<AuthCubit>().login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message ?? AppStrings.somethingWentWrong),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
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
                        subtitle: AppStrings.loginToContinue,
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
                        onPressed: isLoading ? () {} : () => _login(context),
                      ),
                      const SizedBox(height: AppSizes.paddingLarge),
                      AuthFooter(
                        title: AppStrings.dontHaveAccount,
                        actionText: AppStrings.register,
                        onPressed:
                            isLoading
                                ? () {}
                                : () {
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
    );
  }
}

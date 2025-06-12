import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mega_share/core/extensions/context_extensions.dart';
import 'package:mega_share/shared/widgets/common/custom_button.dart';

class ErrorPage extends StatelessWidget {
  final String? error;
  final VoidCallback? onRetry;

  const ErrorPage({super.key, this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: context.colorScheme.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 60,
                  color: context.colorScheme.error,
                ),
              ),

              const SizedBox(height: 32),

              // Error Title
              Text(
                'Oops! Something went wrong',
                style: context.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Error Message
              Text(
                error ?? 'An unexpected error occurred. Please try again.',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Action Buttons
              Column(
                children: [
                  CustomButton(
                    text: 'Try Again',
                    onPressed: onRetry ?? () => context.go('/home'),
                    variant: ButtonVariant.primary,
                    icon: Icons.refresh,
                  ),

                  const SizedBox(height: 16),

                  CustomButton(
                    text: 'Go Home',
                    onPressed: () => context.go('/home'),
                    variant: ButtonVariant.outline,
                    icon: Icons.home,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

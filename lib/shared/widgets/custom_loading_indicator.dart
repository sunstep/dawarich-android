import 'package:flutter/material.dart';

class TextLoadingIndicator extends StatelessWidget {
  final String? message;

  const TextLoadingIndicator({this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Colors.cyan,
            strokeWidth: 3.0,
          ),
          const SizedBox(height: 16),
          if (message != null)
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}

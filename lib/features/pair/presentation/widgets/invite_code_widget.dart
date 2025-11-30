import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InviteCodeWidget extends StatelessWidget {
  final String inviteCode;
  final VoidCallback? onCopy;

  const InviteCodeWidget({
    super.key,
    required this.inviteCode,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(51),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Инвайт-код для партнера',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          SelectableText(
            inviteCode,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  color: Theme.of(context).colorScheme.primary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: inviteCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Инвайт-код скопирован'),
                  duration: Duration(seconds: 2),
                ),
              );
              onCopy?.call();
            },
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Скопировать код'),
          ),
        ],
      ),
    );
  }
}

class InviteCodeInputWidget extends StatefulWidget {
  final ValueChanged<String> onCodeSubmitted;
  final bool isLoading;

  const InviteCodeInputWidget({
    super.key,
    required this.onCodeSubmitted,
    this.isLoading = false,
  });

  @override
  State<InviteCodeInputWidget> createState() => _InviteCodeInputWidgetState();
}

class _InviteCodeInputWidgetState extends State<InviteCodeInputWidget> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitCode() {
    if (_formKey.currentState!.validate()) {
      widget.onCodeSubmitted(_controller.text.trim().toUpperCase());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _controller,
            enabled: !widget.isLoading,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
            decoration: InputDecoration(
              labelText: 'Инвайт-код',
              hintText: 'ABC123',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              prefixIcon: const Icon(Icons.vpn_key_rounded),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите инвайт-код';
              }
              if (value.length != 6) {
                return 'Код должен содержать 6 символов';
              }
              return null;
            },
            onFieldSubmitted: (_) => _submitCode(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: widget.isLoading ? null : _submitCode,
            child: widget.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Присоединиться'),
          ),
        ],
      ),
    );
  }
}

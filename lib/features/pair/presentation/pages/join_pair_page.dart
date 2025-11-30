import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secretpairapp/core/di/service_locator.dart' as di;
import 'package:secretpairapp/features/pair/presentation/bloc/pair_bloc.dart';
import 'package:secretpairapp/features/pair/presentation/bloc/pair_event.dart';
import 'package:secretpairapp/features/pair/presentation/bloc/pair_state.dart';
import 'package:secretpairapp/features/pair/presentation/widgets/invite_code_widget.dart';
import 'package:secretpairapp/app/routes.dart';

class JoinPairPage extends StatelessWidget {
  const JoinPairPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<PairBloc>(),
      child: const _JoinPairView(),
    );
  }
}

class _JoinPairView extends StatelessWidget {
  const _JoinPairView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Присоединиться к паре'),
        centerTitle: true,
      ),
      body: BlocConsumer<PairBloc, PairState>(
        listener: (context, state) {
          if (state is PairError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is PairJoined) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Успешно присоединились к паре!'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
            
            // Переходим в чат после успешного присоединения
            Navigator.of(context).pushReplacementNamed(AppRoutes.chat);
          }
        },
        builder: (context, state) {
          final isLoading = state is PairLoading;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login_rounded,
                    size: 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Введите инвайт-код',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Введите 6-значный код, полученный от вашего партнера',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  InviteCodeInputWidget(
                    onCodeSubmitted: (code) => _joinPair(context, code),
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.of(context)
                                .pushReplacementNamed(AppRoutes.createPair);
                          },
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text('Создать свою пару'),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withAlpha(51),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Код должен быть предоставлен создателем пары',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _joinPair(BuildContext context, String inviteCode) {
    // TODO: Получить userId из AuthBloc или Firebase Auth
    const userId = 'temp_partner_id';

    context.read<PairBloc>().add(
          JoinPairEvent(
            inviteCode: inviteCode,
            userId: userId,
            displayName: 'Partner',
          ),
        );
  }
}

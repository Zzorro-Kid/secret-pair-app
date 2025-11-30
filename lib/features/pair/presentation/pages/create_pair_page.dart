import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:secretpairapp/core/di/service_locator.dart' as di;
import 'package:secretpairapp/features/pair/presentation/bloc/pair_bloc.dart';
import 'package:secretpairapp/features/pair/presentation/bloc/pair_event.dart';
import 'package:secretpairapp/features/pair/presentation/bloc/pair_state.dart';
import 'package:secretpairapp/features/pair/presentation/widgets/invite_code_widget.dart';
import 'package:secretpairapp/app/routes.dart';

class CreatePairPage extends StatelessWidget {
  const CreatePairPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<PairBloc>(),
      child: const _CreatePairView(),
    );
  }
}

class _CreatePairView extends StatefulWidget {
  const _CreatePairView();

  @override
  State<_CreatePairView> createState() => _CreatePairViewState();
}

class _CreatePairViewState extends State<_CreatePairView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создать пару'), centerTitle: true),
      body: BlocConsumer<PairBloc, PairState>(
        listener: (context, state) {
          if (state is PairError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          } else if (state is PairCreated) {
            setState(() {});

            // Если пара уже полная (партнер присоединился), переходим в чат
            if (state.pair.isComplete) {
              Navigator.of(context).pushReplacementNamed(AppRoutes.chat);
            }
          }
        },
        builder: (context, state) {
          if (state is PairLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PairCreated) {
            return _buildCreatedView(context, state);
          }

          return _buildInitialView(context);
        },
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_rounded,
              size: 120,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            Text(
              'Создайте секретную пару',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Вы станете создателем пары и получите инвайт-код для вашего партнера',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            FilledButton.icon(
              onPressed: () => _createPair(context),
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Создать пару'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(AppRoutes.joinPair);
              },
              icon: const Icon(Icons.login_rounded),
              label: const Text('У меня есть код'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatedView(BuildContext context, PairCreated state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Пара создана!',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Отправьте этот код вашему партнеру',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            InviteCodeWidget(inviteCode: state.pair.inviteCode),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withAlpha(128),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ожидаем подключения партнера...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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
  }

  void _createPair(BuildContext context) {
    // TODO: Получить userId из AuthBloc или Firebase Auth
    const userId = 'temp_user_id';

    context.read<PairBloc>().add(
      const CreatePairEvent(userId: userId, displayName: 'User'),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/features/teacher-admin/presentation/providers/user_list_provider.dart';

class UsersListScreen extends ConsumerWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      body: usersState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error al cargar: $err')),
        data: (users) => RefreshIndicator(
          onRefresh: () => ref.read(userListProvider.notifier).fetchUsers(),
          child: ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text('${user.firstName} ${user.lastName}'),
                subtitle: Text(user.email),
                trailing: Switch(
                  value: user.isActive,
                  onChanged: (val) {
                    ref.read(userListProvider.notifier).updateUserStatus(user.id, val);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
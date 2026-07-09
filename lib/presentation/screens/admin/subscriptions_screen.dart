import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jumpup_app/data/repository/teacher_admin/teacher_repository.dart';
import 'package:jumpup_app/domain/model/admin_subscription_model.dart';
import 'package:url_launcher/url_launcher.dart';

final subscriptionsProvider = FutureProvider<List<Subscription>>((ref) {
  return TeacherRepository().fetchSubscriptions();
});

class SubscriptionsScreen extends ConsumerWidget {
  const SubscriptionsScreen({super.key});

  Future<void> _handlePayment(int id, BuildContext context) async {
    try {
      final url = await TeacherRepository().initiateCheckout(id);
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subAsync = ref.watch(subscriptionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Planes Premium')),
      body: subAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (plans) => ListView.builder(
          itemCount: plans.length,
          itemBuilder: (ctx, i) {
            final p = plans[i];
            return Card(
              margin: const EdgeInsets.all(10),
              child: ListTile(
                title: Text(p.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    'Beneficios: ${p.features}\nDuración: ${p.durationDays} días'),
                trailing: ElevatedButton(
                  onPressed: () => _handlePayment(p.id, context),
                  child: Text('\$${p.price}'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

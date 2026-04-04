import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import 'profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final notificationsOn = ref.watch(notificationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: ListView(
        children: [
          // Theme section
          _SectionHeader(label: 'Apariencia'),
          RadioListTile<ThemeMode>(
            title: const Text('Seguir sistema'),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (v) =>
                ref.read(themeModeNotifierProvider.notifier).setTheme(v!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Claro'),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (v) =>
                ref.read(themeModeNotifierProvider.notifier).setTheme(v!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Oscuro'),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (v) =>
                ref.read(themeModeNotifierProvider.notifier).setTheme(v!),
          ),

          const Divider(),

          // Notifications
          _SectionHeader(label: 'Notificaciones'),
          SwitchListTile(
            title: const Text('Notificaciones de actualizaciones'),
            subtitle: const Text('Alerta cuando un favorito es capturado'),
            value: notificationsOn,
            onChanged: (_) =>
                ref.read(notificationsNotifierProvider.notifier).toggle(),
          ),

          const Divider(),

          // About
          _SectionHeader(label: 'Acerca del Programa'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca del Programa de Recompensas'),
            onTap: () async {
              final uri = Uri.parse(AppConstants.recompensasUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.local_police_outlined),
            title: const Text('Policía Nacional del Perú'),
            onTap: () async {
              final uri = Uri.parse(AppConstants.pnpUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_outlined),
            title: const Text('Ministerio del Interior'),
            onTap: () async {
              final uri = Uri.parse(AppConstants.mininterUrl);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),

          const Divider(),

          // Legal
          _SectionHeader(label: 'Legal'),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Términos y Condiciones'),
            onTap: () async {
              final uri = Uri.parse('${AppConstants.recompensasUrl}/terminos');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.inAppWebView);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Política de Privacidad'),
            onTap: () async {
              final uri = Uri.parse('${AppConstants.recompensasUrl}/privacidad');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.inAppWebView);
              }
            },
          ),

          const Divider(),

          // Feedback
          _SectionHeader(label: 'Soporte'),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('Sugerencias y Feedback'),
            onTap: () async {
              final uri = Uri.parse(
                'mailto:app@recompensas.pe?subject=Feedback+Cazadores+Perú',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),

          // App version
          _AppVersionTile(),
          const Gap(32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _AppVersionTile extends StatelessWidget {
  _AppVersionTile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snap) {
        final version = snap.data?.version ?? '---';
        final build = snap.data?.buildNumber ?? '';
        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Versión de la app'),
          trailing: Text(
            '$version ($build)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }
}

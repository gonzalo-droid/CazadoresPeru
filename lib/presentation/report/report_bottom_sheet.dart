import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/criminal_summary.dart';
import '../../core/utils/formatters.dart';

class ReportBottomSheet extends StatefulWidget {
  const ReportBottomSheet({
    super.key,
    required this.criminal,
  });

  final CriminalSummary criminal;

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final fullName = Formatters.formatFullName(
      apellidoPaterno: widget.criminal.apellidoPaterno,
      apellidoMaterno: widget.criminal.apellidoMaterno,
      nombres: widget.criminal.nombres,
    );

    // Redirect to official channel (no backend)
    final body = Uri.encodeComponent(
      'Avistamiento de: $fullName\n'
      'ID: ${widget.criminal.hashRequisitoriado}\n\n'
      'Descripción:\n${_descController.text}',
    );

    final uri = Uri.parse(
      'mailto:denuncias@mininter.gob.pe'
      '?subject=Reporte+avistamiento&body=$body',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Fallback: call 1818
      final phoneUri = Uri.parse(AppConstants.reportPhoneUri);
      if (await canLaunchUrl(phoneUri)) await launchUrl(phoneUri);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, ctrl) {
          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Reportar Avistamiento',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const Divider(height: 20),

              // Disclaimer
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withOpacity(0.4),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppColors.warning, size: 20),
                    Gap(8),
                    Expanded(
                      child: Text(
                        'DISCLAIMER: Este reporte es orientativo. '
                        'Las autoridades son las únicas responsables '
                        'de la detención. NO te enfrentes directamente.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),

              Expanded(
                child: ListView(
                  controller: ctrl,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Descripción del avistamiento',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const Gap(8),
                          TextFormField(
                            controller: _descController,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText:
                                  'Describe qué viste, dónde y cuándo...',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const Gap(24),

                    // Primary CTA
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.send),
                        label: const Text('Enviar a autoridades'),
                      ),
                    ),
                    const Gap(12),

                    // Phone CTA
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(AppConstants.reportPhoneUri);
                          if (await canLaunchUrl(uri)) await launchUrl(uri);
                        },
                        icon: const Icon(
                          Icons.phone,
                          color: AppColors.rewardGreen,
                        ),
                        label: const Text(
                          'Llamar al 1818 ahora',
                          style: TextStyle(color: AppColors.rewardGreen),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.rewardGreen),
                        ),
                      ),
                    ),
                    const Gap(32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

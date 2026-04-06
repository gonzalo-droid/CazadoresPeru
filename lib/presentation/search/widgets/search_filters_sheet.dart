import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../domain/entities/delito.dart';
import '../../../domain/entities/search_filters.dart';
import '../../../domain/entities/ubigeo.dart';
import '../../../domain/usecases/get_ubigeo_usecase.dart';

class SearchFiltersSheet extends ConsumerStatefulWidget {
  const SearchFiltersSheet({
    super.key,
    required this.current,
    required this.onApply,
  });

  final SearchFilters current;
  final void Function(SearchFilters) onApply;

  @override
  ConsumerState<SearchFiltersSheet> createState() => _SearchFiltersSheetState();
}

class _SearchFiltersSheetState extends ConsumerState<SearchFiltersSheet> {
  late SearchFilters _draft;
  List<Departamento> _departamentos = [];
  List<Provincia> _provincias = [];
  List<Delito> _delitos = [];

  @override
  void initState() {
    super.initState();
    _draft = widget.current;
    _loadUbigeo();
  }

  Future<void> _loadUbigeo() async {
    final useCase = ref.read(getUbigeoUseCaseProvider);
    final deps = await useCase.getDepartamentos();
    final dels = await useCase.getDelitos();
    if (mounted) {
      setState(() {
        _departamentos = deps;
        _delitos = dels;
      });
    }
    if (_draft.idDepartamento != null) {
      _loadProvincias(_draft.idDepartamento!);
    }
  }

  Future<void> _loadProvincias(String depCodigo) async {
    final useCase = ref.read(getUbigeoUseCaseProvider);
    final provs = await useCase.getProvincias(depCodigo);
    if (mounted) {
      setState(() {
        _provincias = provs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Filtros', style: theme.textTheme.headlineSmall),
                  TextButton(
                    onPressed: () => setState(() {
                      _draft = const SearchFilters();
                      _provincias = [];
                    }),
                    child: const Text('Limpiar todo'),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Filters
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // Departamento
                  Text('Departamento', style: theme.textTheme.titleSmall),
                  const Gap(8),
                  DropdownButtonFormField<String?>(
                    value: _draft.idDepartamento,
                    hint: const Text('Todos los departamentos'),
                    decoration: const InputDecoration(),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todos'),
                      ),
                      ..._departamentos.map(
                        (d) => DropdownMenuItem(
                          value: d.codigo,
                          child: Text(d.descripcion),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(
                          idDepartamento: value,
                          idProvincia: null,
                        );
                        _provincias = [];
                      });
                      if (value != null) _loadProvincias(value);
                    },
                  ),

                  const Gap(16),

                  // Provincia
                  if (_provincias.isNotEmpty) ...[
                    Text('Provincia', style: theme.textTheme.titleSmall),
                    const Gap(8),
                    DropdownButtonFormField<String?>(
                      value: _draft.idProvincia,
                      hint: const Text('Todas las provincias'),
                      decoration: const InputDecoration(),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Todas'),
                        ),
                        ..._provincias.map(
                          (p) => DropdownMenuItem(
                            value: p.codigo,
                            child: Text(p.descripcion),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _draft = _draft.copyWith(idProvincia: value);
                        });
                      },
                    ),
                    const Gap(16),
                  ],

                  // Delito
                  Text('Tipo de delito', style: theme.textTheme.titleSmall),
                  const Gap(8),
                  DropdownButtonFormField<String?>(
                    value: _draft.idDelito,
                    hint: const Text('Todos los delitos'),
                    decoration: const InputDecoration(),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todos'),
                      ),
                      ..._delitos.map(
                        (d) => DropdownMenuItem(
                          value: d.idDelito.toString(),
                          child: Text(d.descripcion),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _draft = _draft.copyWith(idDelito: value);
                      });
                    },
                  ),

                  const Gap(16),

                  // Sexo
                  Text('Sexo', style: theme.textTheme.titleSmall),
                  const Gap(8),
                  SegmentedButton<String?>(
                    segments: const [
                      ButtonSegment(value: null, label: Text('Todos',style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700))),
                      ButtonSegment(
                        value: 'MASCULINO',
                        label: Text('Masculino',style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        icon: Icon(Icons.male),
                      ),
                      ButtonSegment(
                        value: 'FEMENINO',
                        label: Text('Femenino',style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        icon: Icon(Icons.female),
                      ),
                    ],
                    selected: {_draft.sexo},
                    onSelectionChanged: (s) {
                      setState(() {
                        _draft = _draft.copyWith(sexo: s.first);
                      });
                    },
                  ),

                  const Gap(32),
                ],
              ),
            ),

            // Apply button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onApply(_draft);
                    },
                    child: const Text('Aplicar filtros'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

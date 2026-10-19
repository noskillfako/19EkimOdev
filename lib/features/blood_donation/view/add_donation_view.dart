import 'package:flutter/material.dart';
import '../controllers/blood_donation_controller.dart';
import '../widgets/blood_type_selector.dart';

class AddDonationView extends StatefulWidget {
  const AddDonationView({super.key, required this.controller});

  final BloodDonationController controller;

  @override
  State<AddDonationView> createState() => _AddDonationViewState();
}

class _AddDonationViewState extends State<AddDonationView> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  bool _hasRecentTattoo = false;
  bool _hasBlockingDisease = false;

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submitDonation() {
    final result = widget.controller.addDonation(
      rawAge: _ageController.text,
      rawWeight: _weightController.text,
      hasRecentTattoo: _hasRecentTattoo,
      hasBlockingDisease: _hasBlockingDisease,
    );

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(result.message ?? 'Bağış başarıyla eklendi.'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF00C853),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _showReasonsDialog(result.reasons);
    }
  }

  void _showReasonsDialog(List<String> reasons) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Color(0xFFFF1744), size: 36),
        title: const Text(
          'Bağış Eklenemedi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aşağıdaki sebeplerden dolayı bağış kabul edilemedi:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...reasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(
                        color: Color(0xFFFF1744),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        reason,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 28,
                height: 28,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Bağış Ekle'),
          ],
        ),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: widget.controller.themeMode,
            builder: (context, mode, _) {
              final isDark = mode == ThemeMode.dark;
              return IconButton(
                tooltip: isDark ? 'Açık Mod' : 'Karanlık Mod',
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode_outlined,
                  color: isDark ? const Color(0xFFFFD600) : null,
                ),
                onPressed: widget.controller.toggleTheme,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Kan Grubu Seçin',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<String?>(
                      valueListenable: widget.controller.selectedType,
                      builder: (context, selectedType, _) {
                        return BloodTypeSelector(
                          bloodTypes: BloodDonationController.bloodTypes,
                          selectedType: selectedType,
                          onTypeSelected: widget.controller.selectType,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Kişisel Bilgiler',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Yaş',
                              hintText: 'Örn. 25',
                              helperText: '18 - 65 yaş',
                              prefixIcon: Icon(Icons.cake_outlined, color: colorScheme.primary),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Kilo (kg)',
                              hintText: 'Örn. 70',
                              helperText: '50 - 150 kg',
                              prefixIcon: Icon(Icons.monitor_weight_outlined, color: colorScheme.primary),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Uygunluk Durumu',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          CheckboxListTile(
                            value: _hasRecentTattoo,
                            activeColor: colorScheme.primary,
                            onChanged: (val) {
                              setState(() => _hasRecentTattoo = val ?? false);
                            },
                            title: const Text(
                              'Son 12 ayda dövme yaptırdım',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          const Divider(height: 1),
                          CheckboxListTile(
                            value: _hasBlockingDisease,
                            activeColor: colorScheme.primary,
                            onChanged: (val) {
                              setState(() => _hasBlockingDisease = val ?? false);
                            },
                            title: const Text(
                              'Kan bağışına engel bir hastalığım var',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _submitDonation,
                      icon: const Icon(Icons.add_task),
                      label: const Text(
                        'Bağış Ekle',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 3,
                        shadowColor: colorScheme.primary.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Altta sabit uyarı: "Eğitim amaçlı uygulamadır, gerçek karar Kızılay doktorundadır."
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                border: Border(
                  top: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Eğitim amaçlı uygulamadır, gerçek karar Kızılay doktorundadır.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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
}

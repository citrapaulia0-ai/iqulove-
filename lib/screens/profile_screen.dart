import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/ourdays_state.dart';
import '../widgets/ourdays_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _dateReminders = true;
  bool _weeklyRecap = false;
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _dateReminders = preferences.getBool('date_reminders') ?? true;
        _weeklyRecap = preferences.getBool('weekly_recap') ?? false;
        _settingsLoaded = true;
      });
    } on Exception catch (error) {
      if (mounted) {
        setState(() => _settingsLoaded = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load preferences: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<OurDaysState>(
    builder: (context, state, _) => Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.brown,
        title: const Text('Our little space'),
      ),
      body: ResponsivePage(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(23),
              decoration: BoxDecoration(
                color: AppColors.softPink,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.pink,
                      size: 33,
                    ),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    '${state.partnerOne} & ${state.partnerTwo}',
                    style: const TextStyle(
                      color: AppColors.brown,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Our Little Story',
                    style: TextStyle(
                      color: AppColors.latte,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${state.relationshipDays} days of little moments',
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 17),
                  OutlinedButton.icon(
                    onPressed: () => _editNames(context, state),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit our names'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.brown,
                      side: const BorderSide(color: AppColors.latte),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeading('Our story'),
            const SizedBox(height: 10),
            SoftCard(
              onTap: () => _editAnniversary(context, state),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.softPink,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.event_available_outlined,
                      color: AppColors.brown,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Our day',
                          style: TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatDate(
                            DateTime.parse(state.relationshipStartDate),
                            includeYear: true,
                          ),
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.edit_outlined,
                    color: AppColors.latte,
                    size: 19,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeading('Little settings'),
            const SizedBox(height: 10),
            SoftCard(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Column(
                children: [
                  SwitchListTile(
                    value: _dateReminders,
                    activeTrackColor: AppColors.latte,
                    title: const Text(
                      'Date reminders',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'A gentle nudge before your plans',
                      style: TextStyle(fontFamily: 'Arial', fontSize: 12),
                    ),
                    onChanged: _settingsLoaded
                        ? (value) => _updateSetting(
                            'date_reminders',
                            value,
                            () => setState(() => _dateReminders = value),
                          )
                        : null,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    value: _weeklyRecap,
                    activeTrackColor: AppColors.latte,
                    title: const Text(
                      'Weekly little recap',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Look back at your shared moments',
                      style: TextStyle(fontFamily: 'Arial', fontSize: 12),
                    ),
                    onChanged: _settingsLoaded
                        ? (value) => _updateSetting(
                            'weekly_recap',
                            value,
                            () => setState(() => _weeklyRecap = value),
                          )
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'OURDAYS  ·  PLAN TOGETHER, KEEP EVERY MEMORY',
                style: TextStyle(
                  fontFamily: 'Arial',
                  color: AppColors.latte,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _editNames(BuildContext context, OurDaysState state) async {
    final first = TextEditingController(text: state.partnerOne);
    final second = TextEditingController(text: state.partnerTwo);
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Your names'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: first,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'First name'),
                validator: _requiredName,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: second,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Second name'),
                validator: _requiredName,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.brown),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(dialogContext, (
                first.text.trim(),
                second.text.trim(),
              ));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    first.dispose();
    second.dispose();
    if (result == null) return;
    await state.updatePartners(result.$1, result.$2);
    if (context.mounted) showStateError(context, state.saveError);
  }

  String? _requiredName(String? value) =>
      value == null || value.trim().isEmpty ? 'Please add a name.' : null;

  Future<void> _editAnniversary(
    BuildContext context,
    OurDaysState state,
  ) async {
    final current = DateTime.parse(state.relationshipStartDate);
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date == null) return;
    await state.updateRelationshipStart(date);
    if (context.mounted) showStateError(context, state.saveError);
  }

  Future<void> _updateSetting(
    String key,
    bool value,
    VoidCallback update,
  ) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setBool(key, value);
      if (!saved) throw Exception('The preference was not saved.');
      if (mounted) update();
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save setting: $error')),
        );
      }
    }
  }
}

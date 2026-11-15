import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/ourdays_models.dart';
import '../state/ourdays_state.dart';
import '../widgets/ourdays_widgets.dart';

class DatePlannerScreen extends StatefulWidget {
  const DatePlannerScreen({this.initialDate, this.event, super.key});

  final DateTime? initialDate;
  final CoupleEvent? event;

  @override
  State<DatePlannerScreen> createState() => _DatePlannerScreenState();
}

class _DatePlannerScreenState extends State<DatePlannerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _budget;
  late final TextEditingController _activity;
  late final TextEditingController _checklist;
  late final TextEditingController _story;
  late DateTime _date;
  late TimeOfDay _time;
  late String _category;
  bool _saving = false;

  static const _categories = [
    'Date',
    'Adventure Date',
    'Celebration',
    'Trip',
    'Plan',
  ];

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _title = TextEditingController(text: event?.title ?? '');
    _location = TextEditingController(text: event?.location ?? '');
    _budget = TextEditingController(
      text: event == null || event.budget == 0 ? '' : '${event.budget}',
    );
    _activity = TextEditingController(text: event?.activity ?? '');
    _checklist = TextEditingController(text: event?.checklist.join('\n') ?? '');
    _story = TextEditingController(text: event?.story ?? '');
    _date = event?.date ?? widget.initialDate ?? DateTime.now();
    _time = event == null
        ? const TimeOfDay(hour: 18, minute: 0)
        : TimeOfDay.fromDateTime(event.date);
    _category = event?.category ?? 'Date';
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _budget.dispose();
    _activity.dispose();
    _checklist.dispose();
    _story.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: AppColors.cream,
      title: Text(widget.event == null ? 'Plan a date' : 'Edit plan'),
      foregroundColor: AppColors.brown,
    ),
    body: ResponsivePage(
      maxWidth: 620,
      child: Form(
        key: _formKey,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 32),
        children: [
          const Text(
            'Make a little plan',
            style: TextStyle(
              fontSize: 27,
              color: AppColors.brown,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'The best days start with something to look forward to.',
            style: TextStyle(fontFamily: 'Arial', color: AppColors.muted),
          ),
          const SizedBox(height: 17),
          const _CouplePlanBadge(),
          const SizedBox(height: 24),
          _FieldLabel('What are we doing?'),
          TextFormField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'e.g. Dinner under the stars'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Give your plan a name.'
                : null,
          ),
          const SizedBox(height: 17),
          _FieldLabel('A little something'),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(),
            items: _categories
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) => setState(() => _category = value ?? 'Date'),
          ),
          if (_category == 'Adventure Date') ...[
            const SizedBox(height: 17),
            const _BarelangIllustration(),
          ],
          const SizedBox(height: 17),
          _FieldLabel('When'),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined, size: 17),
                  label: Text(
                    formatDate(_date, includeYear: true),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                  ),
                  style: _outlineStyle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTime,
                  icon: const Icon(Icons.schedule_rounded, size: 18),
                  label: Text(_time.format(context)),
                  style: _outlineStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          _FieldLabel('Where to?'),
          TextFormField(
            controller: _location,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Add a place or keep it a surprise',
              prefixIcon: Icon(Icons.place_outlined, color: AppColors.latte),
            ),
          ),
          const SizedBox(height: 17),
          _FieldLabel('What will you do?'),
          TextFormField(
            controller: _activity,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Describe the activity you will share…',
            ),
          ),
          const SizedBox(height: 17),
          _FieldLabel('Budget (IDR)'),
          TextFormField(
            controller: _budget,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'e.g. 250000',
              prefixText: 'Rp  ',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final amount = int.tryParse(value);
              return amount == null || amount < 0
                  ? 'Enter a valid budget amount.'
                  : null;
            },
          ),
          const SizedBox(height: 17),
          _FieldLabel('Little things to prepare'),
          TextFormField(
            controller: _checklist,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'One item per line\nBook a table\nBring the camera',
            ),
          ),
          const SizedBox(height: 17),
          _FieldLabel('Description'),
          TextFormField(
            controller: _story,
            minLines: 2,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'A story, a reminder, or a little detail…',
            ),
          ),
          const SizedBox(height: 25),
          FilledButton(
            onPressed: _saving ? null : _save,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            child: Text(_saving ? 'Saving…' : 'Save our plan'),
          ),
        ],
        ),
      ),
    ),
  );

  ButtonStyle get _outlineStyle => OutlinedButton.styleFrom(
    foregroundColor: AppColors.brown,
    side: const BorderSide(color: AppColors.line),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
  );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: _datePickerTheme,
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: _datePickerTheme,
    );
    if (picked != null) setState(() => _time = picked);
  }

  Widget _datePickerTheme(BuildContext context, Widget? child) => Theme(
    data: Theme.of(context).copyWith(
      colorScheme: Theme.of(context).colorScheme.copyWith(
        primary: AppColors.brown,
        surface: Colors.white,
      ),
    ),
    child: child!,
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final previous = widget.event;
    final date = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final items = _checklist.text
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    final event = CoupleEvent(
      id: previous?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: _title.text.trim(),
      category: _category,
      date: date,
      location: _location.text.trim(),
      budget: int.tryParse(_budget.text.trim()) ?? 0,
      activity: _activity.text.trim(),
      story: _story.text.trim(),
      checklist: items,
      completedChecklist: previous == null
          ? []
          : previous.completedChecklist.where((index) => index < items.length).toList(),
      photos: previous?.photos ?? [],
      status: previous?.status ?? 'Planned',
    );
    final state = context.read<OurDaysState>();
    if (previous == null) {
      await state.addEvent(event);
    } else {
      await state.updateEvent(event);
    }
    if (!mounted) return;
    setState(() => _saving = false);
    showStateError(context, state.saveError);
    Navigator.of(context).pop();
  }
}

class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context) => Consumer<OurDaysState>(
    builder: (context, state, _) {
      CoupleEvent? event;
      for (final item in state.events) {
        if (item.id == eventId) event = item;
      }
      if (event == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('This plan is no longer available.')),
        );
      }
      final current = event;
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.cream,
          foregroundColor: AppColors.brown,
          title: const Text('Our little plan'),
          actions: [
            IconButton(
              tooltip: 'Edit plan',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DatePlannerScreen(event: current),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Delete plan',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _confirmDelete(context, state),
            ),
          ],
        ),
        body: ResponsivePage(
          child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 10, 22, 32),
          children: [
            if (current.category == 'Adventure Date') ...[
              const _BarelangIllustration(),
              const SizedBox(height: 17),
            ],
            SoftCard(
              color: AppColors.softPink,
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          current.category.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            color: AppColors.brown,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                      ActionChip(
                        avatar: Icon(
                          current.status == 'Completed'
                              ? Icons.check_circle_outline_rounded
                              : Icons.schedule_rounded,
                          size: 16,
                        ),
                        label: Text(current.status),
                        onPressed: () async {
                          await state.updateEvent(
                            current.copyWith(
                              status: current.status == 'Completed'
                                  ? 'Planned'
                                  : 'Completed',
                            ),
                          );
                          if (context.mounted) {
                            showStateError(context, state.saveError);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    current.title,
                    style: const TextStyle(
                      color: AppColors.brown,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _InfoLine(
                    icon: Icons.calendar_today_outlined,
                    text:
                        '${formatDate(current.date, includeYear: true)}  ·  ${formatTime(current.date)}',
                  ),
                  const SizedBox(height: 11),
                  _InfoLine(
                    icon: Icons.place_outlined,
                    text: current.location.isEmpty
                        ? 'Location to be decided'
                        : current.location,
                  ),
                  const SizedBox(height: 11),
                  _InfoLine(
                    icon: Icons.favorite_border_rounded,
                    text: '${state.partnerOne} & ${state.partnerTwo}',
                  ),
                  if (current.budget > 0) ...[
                    const SizedBox(height: 11),
                    _InfoLine(
                      icon: Icons.account_balance_wallet_outlined,
                      text: formatRupiah(current.budget),
                    ),
                  ],
                ],
              ),
            ),
            if (current.activity.isNotEmpty) ...[
              const SizedBox(height: 24),
              const SectionHeading('Our adventure'),
              const SizedBox(height: 9),
              SoftCard(
                child: Text(
                  current.activity,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    height: 1.55,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
            if (current.story.isNotEmpty) ...[
              const SizedBox(height: 24),
              const SectionHeading('A note for this day'),
              const SizedBox(height: 9),
              SoftCard(
                child: Text(
                  current.story,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    height: 1.55,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
            if (current.checklist.isNotEmpty) ...[
              const SizedBox(height: 24),
              SectionHeading(
                'Getting ready',
                trailing: Text(
                  '${current.completedChecklist.length}/${current.checklist.length}',
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    color: AppColors.muted,
                  ),
                ),
              ),
              const SizedBox(height: 9),
              SoftCard(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Column(
                  children: List.generate(current.checklist.length, (index) {
                    final checked = current.completedChecklist.contains(index);
                    return CheckboxListTile(
                      value: checked,
                      activeColor: AppColors.brown,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        current.checklist[index],
                        style: TextStyle(
                          fontFamily: 'Arial',
                          decoration:
                              checked ? TextDecoration.lineThrough : null,
                          color: checked ? AppColors.muted : AppColors.ink,
                        ),
                      ),
                      onChanged: (_) async {
                        await state.toggleChecklist(current, index);
                        if (context.mounted) {
                          showStateError(context, state.saveError);
                        }
                      },
                    );
                  }),
                ),
              ),
            ],
            const SizedBox(height: 24),
            SectionHeading(
              'Little moments',
              trailing: TextButton.icon(
                onPressed: () => _addPhoto(context, state, current),
                icon: const Icon(Icons.add_a_photo_outlined, size: 17),
                label: const Text('Add photo'),
                style: TextButton.styleFrom(foregroundColor: AppColors.brown),
              ),
            ),
            const SizedBox(height: 10),
            if (current.photos.isEmpty)
              SoftCard(
                color: const Color(0xFFF2E8DD),
                child: const Text(
                  'Add a photo after your date to keep the story here.',
                  style: TextStyle(fontFamily: 'Arial'),
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: current.photos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 11,
                  mainAxisSpacing: 11,
                ),
                itemBuilder: (_, index) => memoryImage(
                  data: current.photos[index],
                  height: 160,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
          ],
          ),
        ),
      );
    },
  );

  Future<void> _confirmDelete(
    BuildContext context,
    OurDaysState state,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this plan?'),
        content: const Text('This date will be removed from your calendar.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep it'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await state.deleteEvent(eventId);
    if (!context.mounted) return;
    showStateError(context, state.saveError);
    Navigator.of(context).pop();
  }

  Future<void> _addPhoto(
    BuildContext context,
    OurDaysState state,
    CoupleEvent event,
  ) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 72,
      );
      if (picked == null) return;
      if (!context.mounted) return;
      final captionController = TextEditingController();
      final caption = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Add a little story'),
          content: TextField(
            controller: captionController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'What should you remember?'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, captionController.text.trim()),
              child: const Text('Save photo'),
            ),
          ],
        ),
      );
      captionController.dispose();
      if (caption == null) return;
      final photo = base64Encode(await picked.readAsBytes());
      await state.addEventPhoto(
        event,
        imageData: photo,
        caption: caption,
      );
      if (context.mounted) showStateError(context, state.saveError);
    } on Exception catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add that photo: $error')),
        );
      }
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: const TextStyle(
        fontFamily: 'Arial',
        color: AppColors.brown,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),
  );
}

class _CouplePlanBadge extends StatelessWidget {
  const _CouplePlanBadge();

  @override
  Widget build(BuildContext context) => Consumer<OurDaysState>(
    builder: (context, state, _) => SoftCard(
      color: AppColors.softPink,
      child: Row(
        children: [
          const Icon(Icons.favorite_rounded, color: AppColors.brown, size: 19),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'A little plan for ${state.partnerOne} & ${state.partnerTwo}',
              style: const TextStyle(
                fontFamily: 'Arial',
                color: AppColors.brown,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _BarelangIllustration extends StatelessWidget {
  const _BarelangIllustration();

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(22),
    child: Container(
      height: 150,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB9E0DF), Color(0xFF498B91)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 17,
            right: 24,
            child: Container(
              width: 43,
              height: 43,
              decoration: const BoxDecoration(
                color: Color(0xFFFFE6B8),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const Positioned(
            left: 18,
            top: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BARELANG, BATAM',
                  style: TextStyle(
                    fontFamily: 'Arial',
                    color: Color(0xFF315D62),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Jetski & sea view',
                  style: TextStyle(
                    color: Color(0xFF21474D),
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            left: 16,
            bottom: 7,
            child: Icon(
              Icons.waves_rounded,
              size: 57,
              color: Color(0x88FFFFFF),
            ),
          ),
          const Positioned(
            right: 24,
            bottom: 13,
            child: Icon(
              Icons.speed_rounded,
              size: 65,
              color: Color(0xDDFFFFFF),
            ),
          ),
        ],
      ),
    ),
  );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 17, color: AppColors.brown),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 13,
            color: AppColors.ink,
          ),
        ),
      ),
    ],
  );
}

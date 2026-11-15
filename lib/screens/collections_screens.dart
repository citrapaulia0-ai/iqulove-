import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/ourdays_models.dart';
import '../state/ourdays_state.dart';
import '../widgets/ourdays_widgets.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  String _filter = 'All';
  static const _filters = ['All', 'Experience', 'Food', 'Little things'];

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Consumer<OurDaysState>(
      builder: (context, state, _) {
        final items = state.wishlist
            .where((item) => _filter == 'All' || item.category == _filter)
            .toList();
        return ResponsivePage(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            children: [
              PageHeader(
                title: 'Our wishlist',
                subtitle: 'Little dreams are better when shared.',
                action: RoundIconButton(
                  icon: Icons.add_rounded,
                  background: AppColors.brown,
                  foreground: Colors.white,
                  onPressed: () => _addWish(context, state),
                ),
              ),
              const SizedBox(height: 19),
              SoftCard(
                color: AppColors.softPink,
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: AppColors.brown,
                      size: 23,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${state.wishlist.where((item) => item.isDone).length} little dreams made real',
                        style: const TextStyle(
                          color: AppColors.brown,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      '${state.wishlist.where((item) => !item.isDone).length} to go',
                      style: const TextStyle(
                        fontFamily: 'Arial',
                        color: AppColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final selected = _filter == filter;
                    return ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      showCheckmark: false,
                      labelStyle: TextStyle(
                        fontFamily: 'Arial',
                        color: selected ? Colors.white : AppColors.brown,
                        fontSize: 12,
                      ),
                      selectedColor: AppColors.brown,
                      backgroundColor: Colors.white,
                      side: BorderSide.none,
                      onSelected: (_) => setState(() => _filter = filter),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              if (items.isEmpty)
                const _EmptyCollection(
                  icon: Icons.favorite_border_rounded,
                  message: 'A new little dream starts here.',
                )
              else
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 11),
                    child: _WishCard(
                      item: item,
                      onToggle: () async {
                        await state.updateWishlist(
                          item.copyWith(isDone: !item.isDone),
                        );
                        if (context.mounted) {
                          showStateError(context, state.saveError);
                        }
                      },
                      onDelete: () async {
                        await state.deleteWishlist(item.id);
                        if (context.mounted) {
                          showStateError(context, state.saveError);
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );

  Future<void> _addWish(BuildContext context, OurDaysState state) async {
    final draft = await showDialog<_WishDraft>(
      context: context,
      builder: (_) => const _WishDialog(),
    );
    if (draft == null) return;
    await state.addWishlist(
      WishlistItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: draft.title,
        category: draft.category,
        place: draft.place,
        isDone: false,
      ),
    );
    if (context.mounted) showStateError(context, state.saveError);
  }
}

class _WishCard extends StatelessWidget {
  const _WishCard({
    required this.item,
    required this.onToggle,
    required this.onDelete,
  });

  final WishlistItem item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: const EdgeInsets.fromLTRB(15, 13, 9, 13),
    child: Row(
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.isDone ? AppColors.sage : AppColors.softPink,
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.isDone ? Icons.check_rounded : Icons.favorite_border_rounded,
              color: item.isDone ? Colors.white : AppColors.brown,
              size: 19,
            ),
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  decoration: item.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                item.place.isEmpty
                    ? item.category
                    : '${item.category}  ·  ${item.place}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontSize: 11,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Remove wish',
          onPressed: onDelete,
          icon: const Icon(Icons.close_rounded, size: 18),
          color: AppColors.muted,
        ),
      ],
    ),
  );
}

class _WishDraft {
  const _WishDraft(this.title, this.category, this.place);

  final String title;
  final String category;
  final String place;
}

class _WishDialog extends StatefulWidget {
  const _WishDialog();

  @override
  State<_WishDialog> createState() => _WishDialogState();
}

class _WishDialogState extends State<_WishDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _place = TextEditingController();
  String _category = 'Experience';
  static const _categories = ['Experience', 'Food', 'Little things'];

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('A wish for us'),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _title,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'What do you want to do?',
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Add a wish first.'
                : null,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(),
            items: _categories
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (value) =>
                setState(() => _category = value ?? _category),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _place,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Place (optional)'),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: AppColors.brown),
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(
            context,
            _WishDraft(_title.text.trim(), _category, _place.text.trim()),
          );
        },
        child: const Text('Add wish'),
      ),
    ],
  );
}

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Consumer<OurDaysState>(
      builder: (context, state, _) => ResponsivePage(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          children: [
            PageHeader(
              title: 'Our memories',
              subtitle: 'Little moments, kept close.',
              action: RoundIconButton(
                icon: Icons.add_a_photo_outlined,
                background: AppColors.brown,
                foreground: Colors.white,
                onPressed: () => _addMemory(context, state),
              ),
            ),
            const SizedBox(height: 21),
            SoftCard(
              color: const Color(0xFFF2E8DD),
              child: Row(
                children: [
                  const Icon(
                    Icons.photo_album_outlined,
                    color: AppColors.brown,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${state.memories.length} moments in your little album',
                      style: const TextStyle(color: AppColors.brown),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (state.memories.isEmpty)
              const _EmptyCollection(
                icon: Icons.photo_library_outlined,
                message: 'Your first memory is waiting to be made.',
              )
            else
              ...state.memories.map(
                (memory) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _MemoryCard(
                    memory: memory,
                    onTap: () => _showMemory(context, memory),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );

  Future<void> _addMemory(BuildContext context, OurDaysState state) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 70,
      );
      if (picked == null) return;
      if (!context.mounted) return;
      final details = await showDialog<_MemoryDraft>(
        context: context,
        builder: (_) => const _MemoryDialog(),
      );
      if (details == null) return;
      final data = base64Encode(await picked.readAsBytes());
      await state.addMemory(
        MemoryItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: details.title,
          caption: details.caption,
          date: details.date,
          imageData: data,
        ),
      );
      if (context.mounted) showStateError(context, state.saveError);
    } on Exception catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add that memory: $error')),
        );
      }
    }
  }

  void _showMemory(BuildContext context, MemoryItem memory) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: ColoredBox(
            color: AppColors.cream,
            child: ListView(
              shrinkWrap: true,
              children: [
                memoryImage(
                  data: memory.imageData,
                  height: 320,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDate(memory.date, includeYear: true),
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          color: AppColors.latte,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        memory.title,
                        style: const TextStyle(
                          color: AppColors.brown,
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (memory.caption.isNotEmpty) ...[
                        const SizedBox(height: 9),
                        Text(
                          memory.caption,
                          style: const TextStyle(
                            fontFamily: 'Arial',
                            height: 1.45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoryCard extends StatelessWidget {
  const _MemoryCard({required this.memory, required this.onTap});

  final MemoryItem memory;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SoftCard(
    padding: EdgeInsets.zero,
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        memoryImage(
          data: memory.imageData,
          height: 190,
          width: double.infinity,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(17, 14, 17, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formatDate(memory.date, includeYear: true).toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Arial',
                  color: AppColors.latte,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                memory.title,
                style: const TextStyle(
                  fontSize: 19,
                  color: AppColors.brown,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (memory.caption.isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  memory.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _MemoryDraft {
  const _MemoryDraft(this.title, this.caption, this.date);

  final String title;
  final String caption;
  final DateTime date;
}

class _MemoryDialog extends StatefulWidget {
  const _MemoryDialog();

  @override
  State<_MemoryDialog> createState() => _MemoryDialogState();
}

class _MemoryDialogState extends State<_MemoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _caption = TextEditingController();
  DateTime _date = DateUtils.dateOnly(DateTime.now());

  @override
  void dispose() {
    _title.dispose();
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Keep this memory'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _title,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Give it a title'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Add a title for this moment.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _caption,
              minLines: 2,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'A little caption'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _date = date);
              },
              icon: const Icon(Icons.calendar_today_outlined, size: 17),
              label: Text(formatDate(_date, includeYear: true)),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: AppColors.brown),
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(
            context,
            _MemoryDraft(_title.text.trim(), _caption.text.trim(), _date),
          );
        },
        child: const Text('Save memory'),
      ),
    ],
  );
}

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Consumer<OurDaysState>(
      builder: (context, state, _) {
        final notes = [...state.notes]
          ..sort((a, b) {
            if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
            return b.updatedAt.compareTo(a.updatedAt);
          });
        return ResponsivePage(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            children: [
              PageHeader(
                title: 'Little notes',
                subtitle: 'The things you want to remember together.',
                action: RoundIconButton(
                  icon: Icons.add_rounded,
                  background: AppColors.brown,
                  foreground: Colors.white,
                  onPressed: () => _editNote(context, state),
                ),
              ),
              const SizedBox(height: 20),
              if (notes.isEmpty)
                const _EmptyCollection(
                  icon: Icons.sticky_note_2_outlined,
                  message: 'Leave each other a little note.',
                )
              else
                ...notes.map(
                  (note) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NoteCard(
                      note: note,
                      onEdit: () => _editNote(context, state, note: note),
                      onPin: () async {
                        await state.updateNote(
                          note.copyWith(isPinned: !note.isPinned),
                        );
                        if (context.mounted) {
                          showStateError(context, state.saveError);
                        }
                      },
                      onDelete: () async {
                        await state.deleteNote(note.id);
                        if (context.mounted) {
                          showStateError(context, state.saveError);
                        }
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );

  Future<void> _editNote(
    BuildContext context,
    OurDaysState state, {
    SharedNote? note,
  }) async {
    final draft = await showDialog<_NoteDraft>(
      context: context,
      builder: (_) => _NoteDialog(note: note),
    );
    if (draft == null) return;
    if (note == null) {
      await state.addNote(
        SharedNote(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: draft.title,
          content: draft.content,
          isPinned: draft.isPinned,
          updatedAt: DateTime.now(),
        ),
      );
    } else {
      await state.updateNote(
        note.copyWith(
          title: draft.title,
          content: draft.content,
          isPinned: draft.isPinned,
          updatedAt: DateTime.now(),
        ),
      );
    }
    if (context.mounted) showStateError(context, state.saveError);
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onEdit,
    required this.onPin,
    required this.onDelete,
  });

  final SharedNote note;
  final VoidCallback onEdit;
  final VoidCallback onPin;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => SoftCard(
    onTap: onEdit,
    color: note.isPinned ? const Color(0xFFFFF2EB) : Colors.white,
    padding: const EdgeInsets.fromLTRB(17, 15, 11, 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                note.title,
                style: const TextStyle(
                  color: AppColors.brown,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            IconButton(
              tooltip: note.isPinned ? 'Unpin note' : 'Pin note',
              onPressed: onPin,
              icon: Icon(
                note.isPinned
                    ? Icons.push_pin_rounded
                    : Icons.push_pin_outlined,
                size: 19,
              ),
              color: note.isPinned ? AppColors.brown : AppColors.muted,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              tooltip: 'Delete note',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: 19),
              color: AppColors.muted,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        Text(
          note.content,
          style: const TextStyle(
            fontFamily: 'Arial',
            color: AppColors.ink,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 11),
        Text(
          'UPDATED ${formatDate(note.updatedAt).toUpperCase()}',
          style: const TextStyle(
            fontFamily: 'Arial',
            color: AppColors.latte,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: .7,
          ),
        ),
      ],
    ),
  );
}

class _NoteDraft {
  const _NoteDraft(this.title, this.content, this.isPinned);

  final String title;
  final String content;
  final bool isPinned;
}

class _NoteDialog extends StatefulWidget {
  const _NoteDialog({this.note});

  final SharedNote? note;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _content;
  late bool _isPinned;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.note?.title ?? '');
    _content = TextEditingController(text: widget.note?.content ?? '');
    _isPinned = widget.note?.isPinned ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.note == null ? 'Write a little note' : 'Edit note'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _title,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'A little title'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Add a title.' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _content,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Write it down…'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Add something to remember.'
                  : null,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pin this note'),
              value: _isPinned,
              activeTrackColor: AppColors.latte,
              onChanged: (value) => setState(() => _isPinned = value),
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: AppColors.brown),
        onPressed: () {
          if (!_formKey.currentState!.validate()) return;
          Navigator.pop(
            context,
            _NoteDraft(_title.text.trim(), _content.text.trim(), _isPinned),
          );
        },
        child: const Text('Save note'),
      ),
    ],
  );
}

class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => SoftCard(
    color: AppColors.softPink,
    child: Row(
      children: [
        Icon(icon, color: AppColors.brown),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(fontFamily: 'Arial', color: AppColors.brown),
          ),
        ),
      ],
    ),
  );
}

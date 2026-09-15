// /stanverse/desk — private back office where worlds (artists) get created
// and edited, backed by Firestore (project stanverse-fanapp) — the exact
// data the iOS app reads. Not linked from any public page.
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/site_shell.dart';
import '../sv_colors.dart';
import 'stanverse_desk_service.dart';

class StanverseDeskPage extends StatefulWidget {
  const StanverseDeskPage({super.key});

  @override
  State<StanverseDeskPage> createState() => _StanverseDeskPageState();
}

class _StanverseDeskPageState extends State<StanverseDeskPage> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    return SiteShell(
      ground: SVColors.ink,
      children: [
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 1080 : 760),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 48 : 22,
                isWide ? 56 : 32,
                isWide ? 48 : 22,
                96,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _unlocked
                    ? _Desk(key: const ValueKey('desk'), isWide: isWide)
                    : _Gate(
                        key: const ValueKey('gate'),
                        onUnlock: () => setState(() => _unlocked = true),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Gate extends StatefulWidget {
  final VoidCallback onUnlock;
  const _Gate({super.key, required this.onUnlock});

  @override
  State<_Gate> createState() => _GateState();
}

class _GateState extends State<_Gate> {
  final _controller = TextEditingController();
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WORLD DESK',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
            color: SVColors.mono,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the passphrase to manage worlds.',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            color: SVColors.paper,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _controller,
          obscureText: true,
          style: GoogleFonts.ibmPlexSans(color: SVColors.paper),
          decoration: InputDecoration(
            filled: true,
            fillColor: SVColors.paperDim.withValues(alpha: 0.08),
            hintText: 'Passphrase',
            hintStyle: TextStyle(color: SVColors.mono),
            errorText: _error,
            border: const OutlineInputBorder(borderSide: BorderSide.none),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: SVColors.paper),
          child: const Text('ENTER', style: TextStyle(color: SVColors.ink)),
        ),
      ],
    );
  }

  void _submit() {
    // ponytail: hardcoded shared secret, fine for a single-operator desk —
    // Firestore's own rules are the real access boundary for the data
    // itself; this just keeps the page off a casual visitor's radar.
    if (_controller.text == 'stanverse-owner') {
      widget.onUnlock();
    } else {
      setState(() => _error = 'Wrong passphrase');
    }
  }
}

const _swatches = [
  Color(0xFF7C5CFF),
  Color(0xFFFF2FA0),
  Color(0xFFFF9F3E),
  Color(0xFF34C77B),
  Color(0xFF3E86FF),
  Color(0xFF9B5CFF),
];

class _Desk extends StatefulWidget {
  final bool isWide;
  const _Desk({super.key, required this.isWide});

  @override
  State<_Desk> createState() => _DeskState();
}

class _DeskState extends State<_Desk> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _worlds;
  String? _editingId;
  final _nameController = TextEditingController();
  Color _pickedColor = _swatches.first;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final snap = await stanverseDb.collection('artists').orderBy('name').get();
    if (mounted) setState(() => _worlds = snap.docs);
  }

  Future<void> _addWorld() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final id = slugify(name);
    await stanverseDb.collection('artists').doc(id).set({
      'name': name,
      'tagline': '',
      'description': '',
      'liveCount': '',
      'colorHex': _pickedColor.toARGB32(),
      'deepColorHex': _pickedColor.toARGB32(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    _nameController.clear();
    await _load();
  }

  Future<void> _deleteWorld(String id) async {
    await stanverseDb.collection('artists').doc(id).delete();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_editingId != null) {
      return _WorldEditor(
        artistId: _editingId!,
        onBack: () {
          setState(() => _editingId = null);
          _load();
        },
      );
    }

    final worlds = _worlds;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WORLD DESK',
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 3,
            fontWeight: FontWeight.w600,
            color: SVColors.mono,
          ),
        ),
        const SizedBox(height: 24),
        if (worlds == null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: CircularProgressIndicator(color: SVColors.paper),
            ),
          )
        else if (worlds.isEmpty)
          Text(
            'No worlds yet — add one below.',
            style: TextStyle(color: SVColors.mono),
          )
        else
          for (final doc in worlds)
            Builder(
              builder: (context) {
                final data = doc.data();
                final color = Color(data['colorHex'] as int? ?? 0xFF7C5CFF);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SVColors.paperDim.withValues(alpha: 0.06),
                    border: Border(left: BorderSide(color: color, width: 4)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'] as String? ?? doc.id,
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: SVColors.paper,
                              ),
                            ),
                            Text(
                              (data['tagline'] as String?)?.isNotEmpty == true
                                  ? data['tagline'] as String
                                  : 'No tagline yet.',
                              style: TextStyle(
                                fontSize: 12,
                                color: SVColors.mono,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _editingId = doc.id),
                        child: const Text('EDIT'),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: SVColors.mono),
                        onPressed: () => _deleteWorld(doc.id),
                      ),
                    ],
                  ),
                );
              },
            ),
        const SizedBox(height: 24),
        Text(
          'ADD A WORLD',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
            color: SVColors.mono,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          style: GoogleFonts.ibmPlexSans(color: SVColors.paper),
          decoration: InputDecoration(
            filled: true,
            fillColor: SVColors.paperDim.withValues(alpha: 0.08),
            hintText: 'Artist name',
            hintStyle: TextStyle(color: SVColors.mono),
            border: const OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (final c in _swatches)
              GestureDetector(
                onTap: () => setState(() => _pickedColor = c),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: _pickedColor == c
                        ? Border.all(color: SVColors.paper, width: 2)
                        : null,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _addWorld,
          style: ElevatedButton.styleFrom(backgroundColor: SVColors.paper),
          child: const Text('ADD WORLD', style: TextStyle(color: SVColors.ink)),
        ),
      ],
    );
  }
}

class _WorldEditor extends StatefulWidget {
  const _WorldEditor({required this.artistId, required this.onBack});
  final String artistId;
  final VoidCallback onBack;

  @override
  State<_WorldEditor> createState() => _WorldEditorState();
}

class _WorldEditorState extends State<_WorldEditor> {
  Map<String, dynamic>? _data;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _dates = const [];
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _descController = TextEditingController();
  final _liveCountController = TextEditingController();
  final _imageUrlController = TextEditingController();
  Color _color = _swatches.first;
  Color _deep = _swatches.first;
  Uint8List? _pickedImageBytes;
  String? _imageUrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await stanverseDb
        .collection('artists')
        .doc(widget.artistId)
        .get();
    final data = doc.data() ?? {};
    final datesSnap = await stanverseDb
        .collection('artists')
        .doc(widget.artistId)
        .collection('tourDates')
        .orderBy('date')
        .get();
    if (!mounted) return;
    setState(() {
      _data = data;
      _nameController.text = data['name'] as String? ?? '';
      _taglineController.text = data['tagline'] as String? ?? '';
      _descController.text = data['description'] as String? ?? '';
      _liveCountController.text = data['liveCount'] as String? ?? '';
      _color = Color(data['colorHex'] as int? ?? 0xFF7C5CFF);
      _deep = Color(data['deepColorHex'] as int? ?? 0xFF4B2FBF);
      _imageUrl = data['imageUrl'] as String?;
      _imageUrlController.text = _imageUrl ?? '';
      _dates = datesSnap.docs;
    });
  }

  Future<void> _pickImage() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() => _pickedImageBytes = bytes);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    String? imageUrl = _imageUrl;
    if (_pickedImageBytes != null) {
      final ref = stanverseStorage.ref('artist_images/${widget.artistId}.jpg');
      await ref.putData(_pickedImageBytes!);
      imageUrl = await ref.getDownloadURL();
    } else if (_imageUrlController.text.trim().isNotEmpty) {
      imageUrl = _imageUrlController.text.trim();
    }
    await stanverseDb.collection('artists').doc(widget.artistId).update({
      'name': _nameController.text.trim(),
      'tagline': _taglineController.text.trim(),
      'description': _descController.text.trim(),
      'liveCount': _liveCountController.text.trim(),
      'colorHex': _color.toARGB32(),
      'deepColorHex': _deep.toARGB32(),
      'imageUrl': ?imageUrl,
    });
    if (!mounted) return;
    setState(() {
      _saving = false;
      _imageUrl = imageUrl;
      _pickedImageBytes = null;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Saved.')));
  }

  Future<void> _addDate({
    required DateTime date,
    required String city,
    required String venue,
    required String status,
    required String buyUrl,
  }) async {
    await stanverseDb
        .collection('artists')
        .doc(widget.artistId)
        .collection('tourDates')
        .add({
          'date': Timestamp.fromDate(date),
          'city': city,
          'venue': venue,
          'status': status,
          'buyUrl': buyUrl,
        });
    await _load();
  }

  Future<void> _deleteDate(String dateDocId) async {
    await stanverseDb
        .collection('artists')
        .doc(widget.artistId)
        .collection('tourDates')
        .doc(dateDocId)
        .delete();
    await _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _descController.dispose();
    _liveCountController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CircularProgressIndicator(color: SVColors.paper),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: widget.onBack,
              icon: Icon(Icons.arrow_back, color: SVColors.mono, size: 18),
              label: Text(
                'ALL WORLDS',
                style: TextStyle(color: SVColors.mono, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final form = _EditorForm(
              nameController: _nameController,
              taglineController: _taglineController,
              descController: _descController,
              liveCountController: _liveCountController,
              imageUrlController: _imageUrlController,
              color: _color,
              deep: _deep,
              imageUrl: _imageUrl,
              pickedImageBytes: _pickedImageBytes,
              onPickColor: (c) => setState(() => _color = c),
              onPickDeep: (c) => setState(() => _deep = c),
              onPickImage: _pickImage,
              onSave: _saving ? null : _save,
              saving: _saving,
              dates: _dates,
              artistName: _nameController.text,
              onAddDate: _addDate,
              onDeleteDate: _deleteDate,
            );
            final preview = _PreviewPane(
              name: _nameController.text,
              tagline: _taglineController.text,
              description: _descController.text,
              liveCount: _liveCountController.text,
              color: _color,
              deep: _deep,
              imageUrl: _imageUrl,
              pickedImageBytes: _pickedImageBytes,
              dates: _dates,
            );
            if (!wide) {
              return Column(
                children: [form, const SizedBox(height: 32), preview],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: form),
                const SizedBox(width: 32),
                Expanded(flex: 2, child: preview),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _EditorForm extends StatefulWidget {
  const _EditorForm({
    required this.nameController,
    required this.taglineController,
    required this.descController,
    required this.liveCountController,
    required this.imageUrlController,
    required this.color,
    required this.deep,
    required this.imageUrl,
    required this.pickedImageBytes,
    required this.onPickColor,
    required this.onPickDeep,
    required this.onPickImage,
    required this.onSave,
    required this.saving,
    required this.dates,
    required this.artistName,
    required this.onAddDate,
    required this.onDeleteDate,
  });

  final TextEditingController nameController;
  final TextEditingController taglineController;
  final TextEditingController descController;
  final TextEditingController liveCountController;
  final TextEditingController imageUrlController;
  final Color color;
  final Color deep;
  final String? imageUrl;
  final Uint8List? pickedImageBytes;
  final ValueChanged<Color> onPickColor;
  final ValueChanged<Color> onPickDeep;
  final VoidCallback onPickImage;
  final VoidCallback? onSave;
  final bool saving;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> dates;
  final String artistName;
  final Future<void> Function({
    required DateTime date,
    required String city,
    required String venue,
    required String status,
    required String buyUrl,
  })
  onAddDate;
  final Future<void> Function(String dateDocId) onDeleteDate;

  @override
  State<_EditorForm> createState() => _EditorFormState();
}

class _EditorFormState extends State<_EditorForm> {
  final _cityController = TextEditingController();
  final _venueController = TextEditingController();
  final _buyUrlController = TextEditingController();
  DateTime? _pickedDate;
  String _status = 'onSale';

  @override
  void dispose() {
    _cityController.dispose();
    _venueController.dispose();
    _buyUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _pickedDate = picked);
  }

  void _prefillBuyUrl() {
    if (_buyUrlController.text.isNotEmpty) return;
    final q = Uri.encodeComponent(widget.artistName);
    _buyUrlController.text = 'https://www.ticketmaster.com/search?q=$q';
  }

  Future<void> _addDate() async {
    if (_pickedDate == null ||
        _cityController.text.trim().isEmpty ||
        _venueController.text.trim().isEmpty) {
      return;
    }
    _prefillBuyUrl();
    await widget.onAddDate(
      date: _pickedDate!,
      city: _cityController.text.trim(),
      venue: _venueController.text.trim(),
      status: _status,
      buyUrl: _buyUrlController.text.trim(),
    );
    setState(() {
      _pickedDate = null;
      _cityController.clear();
      _venueController.clear();
      _buyUrlController.clear();
      _status = 'onSale';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('NAME'),
        _field(widget.nameController, 'Artist name'),
        const SizedBox(height: 16),
        _label('TAGLINE'),
        _field(widget.taglineController, 'One line, shown on the hero card'),
        const SizedBox(height: 16),
        _label('DESCRIPTION'),
        _field(
          widget.descController,
          'A few sentences about this world',
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        _label('FOLLOWER COUNT (SHOWN AS-IS, YOUR CALL)'),
        _field(widget.liveCountController, 'e.g. 18.4K FOLLOWERS'),
        const SizedBox(height: 16),
        _label('PROFILE IMAGE'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: widget.onPickImage,
          child: Container(
            height: 140,
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: SVColors.paperDim.withValues(alpha: 0.08),
              border: Border.all(color: SVColors.line),
            ),
            child: widget.pickedImageBytes != null
                ? Image.memory(widget.pickedImageBytes!, fit: BoxFit.cover)
                : widget.imageUrl != null
                ? Image.network(widget.imageUrl!, fit: BoxFit.cover)
                : Center(
                    child: Icon(
                      Icons.add_photo_alternate,
                      color: SVColors.mono,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        _field(widget.imageUrlController, 'Or paste an image URL directly'),
        const SizedBox(height: 16),
        _label('ACCENT COLOR'),
        const SizedBox(height: 8),
        _swatchRow(widget.color, widget.onPickColor),
        const SizedBox(height: 16),
        _label('DEEP COLOR'),
        const SizedBox(height: 8),
        _swatchRow(widget.deep, widget.onPickDeep),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: widget.onSave,
          style: ElevatedButton.styleFrom(backgroundColor: SVColors.paper),
          child: Text(
            widget.saving ? 'SAVING…' : 'SAVE WORLD',
            style: const TextStyle(color: SVColors.ink),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'TOUR DATES',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
            color: SVColors.mono,
          ),
        ),
        const SizedBox(height: 12),
        for (final doc in widget.dates)
          Builder(
            builder: (context) {
              final d = doc.data();
              final date = (d['date'] as Timestamp).toDate();
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: SVColors.paperDim.withValues(alpha: 0.06),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}  '
                        '${d['city']} · ${d['venue']} · ${d['status']}',
                        style: TextStyle(color: SVColors.paper, fontSize: 12),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: SVColors.mono,
                        size: 18,
                      ),
                      onPressed: () => widget.onDeleteDate(doc.id),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 12),
        Text(
          'ADD A DATE',
          style: TextStyle(
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
            color: SVColors.mono,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton(
              onPressed: _pickDate,
              child: Text(
                _pickedDate == null
                    ? 'PICK DATE'
                    : '${_pickedDate!.year}-${_pickedDate!.month.toString().padLeft(2, '0')}-${_pickedDate!.day.toString().padLeft(2, '0')}',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _field(_cityController, 'City, ST')),
          ],
        ),
        const SizedBox(height: 8),
        _field(_venueController, 'Venue'),
        const SizedBox(height: 8),
        Row(
          children: [
            DropdownButton<String>(
              value: _status,
              dropdownColor: SVColors.ink,
              style: TextStyle(color: SVColors.paper),
              items: const [
                DropdownMenuItem(value: 'onSale', child: Text('ON SALE')),
                DropdownMenuItem(value: 'soldOut', child: Text('SOLD OUT')),
                DropdownMenuItem(value: 'vip', child: Text('VIP LEFT')),
              ],
              onChanged: (v) => setState(() => _status = v ?? 'onSale'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                _buyUrlController,
                'Buy link (defaults to a Ticketmaster search if left blank)',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton(onPressed: _addDate, child: const Text('ADD DATE')),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1,
      color: SVColors.mono,
    ),
  );

  Widget _field(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.ibmPlexSans(color: SVColors.paper, fontSize: 13),
        decoration: InputDecoration(
          filled: true,
          fillColor: SVColors.paperDim.withValues(alpha: 0.08),
          hintText: hint,
          hintStyle: TextStyle(color: SVColors.mono, fontSize: 12),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          isDense: true,
        ),
      ),
    );
  }

  Widget _swatchRow(Color selected, ValueChanged<Color> onPick) {
    return Row(
      children: [
        for (final c in _swatches)
          GestureDetector(
            onTap: () => onPick(c),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: selected.toARGB32() == c.toARGB32()
                    ? Border.all(color: SVColors.paper, width: 2)
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}

/// What the app will actually show — same shape as ArtistHero + a tour-date
/// row + the profile name/description, rendered here as a close visual
/// copy since supremolabs can't import stanverse's own widgets directly.
class _PreviewPane extends StatelessWidget {
  const _PreviewPane({
    required this.name,
    required this.tagline,
    required this.description,
    required this.liveCount,
    required this.color,
    required this.deep,
    required this.imageUrl,
    required this.pickedImageBytes,
    required this.dates,
  });

  final String name;
  final String tagline;
  final String description;
  final String liveCount;
  final Color color;
  final Color deep;
  final String? imageUrl;
  final Uint8List? pickedImageBytes;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> dates;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PREVIEW — WHAT SHIPS TO THE APP',
          style: TextStyle(
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
            color: SVColors.mono,
          ),
        ),
        const SizedBox(height: 12),
        // Hero card, ~ArtistHero + board-screen card overlay.
        Container(
          height: 200,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0x33FFFFFF)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (pickedImageBytes != null)
                Image.memory(pickedImageBytes!, fit: BoxFit.cover)
              else if (imageUrl != null)
                Image.network(imageUrl!, fit: BoxFit.cover)
              else
                DecoratedBox(decoration: BoxDecoration(color: color)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC0E0D10)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      name.isEmpty ? 'UNNAMED WORLD' : name,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    if (liveCount.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        liveCount,
                        style: TextStyle(
                          color: const Color(0xE6FFFFFF),
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          tagline.isEmpty ? 'No tagline yet.' : tagline,
          style: TextStyle(color: SVColors.paper, fontSize: 13, height: 1.4),
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(color: SVColors.mono, fontSize: 12, height: 1.4),
          ),
        ],
        const SizedBox(height: 20),
        Text(
          'NEXT DATES',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: SVColors.mono,
          ),
        ),
        const SizedBox(height: 8),
        if (dates.isEmpty)
          Text(
            'No dates yet.',
            style: TextStyle(color: SVColors.mono, fontSize: 12),
          )
        else
          for (final doc in dates.take(3))
            Builder(
              builder: (context) {
                final d = doc.data();
                final date = (d['date'] as Timestamp).toDate();
                final status = d['status'] as String? ?? 'onSale';
                final label = switch (status) {
                  'soldOut' => 'SOLD OUT',
                  'vip' => 'VIP LEFT',
                  _ => 'ON SALE',
                };
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${date.month}/${date.day}  ${d['city']}',
                          style: TextStyle(color: SVColors.paper, fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: deep),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(color: deep, fontSize: 9),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      ],
    );
  }
}

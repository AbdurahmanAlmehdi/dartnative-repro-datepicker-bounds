import 'package:dartnative/dartnative.dart';

import 'dartnative_plugin_registrant.dart';

void main() {
  DartNativePluginRegistrant.registerAll();
  runApp(const DateBoundsRepro());
}

const _ink = TextStyle(fontSize: 15, color: Color(0xFF111111));
const _red = TextStyle(fontSize: 15, color: Color(0xFFC62828));
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _fmt(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

class DateBoundsRepro extends StatefulWidget {
  const DateBoundsRepro({super.key});

  @override
  State<DateBoundsRepro> createState() => _DateBoundsReproState();
}

class _DateBoundsReproState extends State<DateBoundsRepro> {
  // What the app wants to pass (see README); showDatePicker can't take them.
  static final _initial = DateTime(2026, 1, 15);
  static final _first = DateTime(2026, 1, 1);
  static final _last = DateTime(2026, 1, 31);

  DateTime? _picked;

  @override
  void initState() {
    super.initState();
    // Opens the picker once without a tap, so the problem shows right after launch.
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _pick();
    });
  }

  bool get _inRange =>
      _picked != null && !_picked!.isBefore(_first) && !_picked!.isAfter(_last);

  Future<void> _pick() async {
    final d = await showDatePicker(context: context);
    if (d != null) setState(() => _picked = d);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      brightness: Brightness.light,
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(title: const Text('Date picker bounds')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expected (Flutter): showDatePicker(initialDate: ${_fmt(_initial)}, '
              'firstDate: ${_fmt(_first)}, lastDate: ${_fmt(_last)}) opens on '
              '${_fmt(_initial)} and only allows 1–31 Jan 2026.',
              style: _ink,
            ),
            const SizedBox(height: 8),
            const Text(
              'Actual: showDatePicker takes only (context, mode, confirmText). '
              'It opens on today and any date can be picked.',
              style: _red,
            ),
            const SizedBox(height: 24),
            Button(
              title: 'Pick a date (1–31 Jan 2026)',
              onPressed: _pick,
            ),
            const Text('(opens by itself 3 s after launch)',
                style: TextStyle(fontSize: 12, color: Color(0xFF777777))),
            const SizedBox(height: 16),
            Text('Today: ${_fmt(DateTime.now())}', style: _ink),
            Text(
              _picked == null ? 'Picked: —' : 'Picked: ${_fmt(_picked!)}',
              style: const TextStyle(fontSize: 18, color: Color(0xFF111111)),
            ),
            if (_picked != null)
              Text(
                _inRange ? 'inside 1–31 Jan 2026' : 'outside 1–31 Jan 2026',
                style: _inRange ? _ink : _red,
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class ParentMessageScreen extends StatefulWidget {
  const ParentMessageScreen({super.key});
  @override
  State<ParentMessageScreen> createState() => _ParentMessageScreenState();
}

class _ParentMessageScreenState extends State<ParentMessageScreen> {
  final _msgCtrl = TextEditingController();
  String _selectedTeacher = 'Mr. Ravi Sharma (Mathematics)';

  final _teachers = [
        'Mr. Ravi Sharma (Mathematics)',
        'Mrs. Priya (English)',
        'Mr. Kumar (Science)',
        'Mrs. Gupta (Hindi)',
        'Class Teacher',
  ];

  final List<Map<String, dynamic>> _messages = [
    {'sender': 'parent', 'text': 'Hello sir, how is Rahul performing in class?', 'time': '10:30 AM'},
    {'sender': 'teacher', 'text': 'Rahul is doing well! He is attentive and submits homework on time. His math score has improved significantly.', 'time': '11:15 AM'},
    {'sender': 'parent', 'text': 'That is great to hear! Thank you.', 'time': '11:20 AM'},
    {'sender': 'teacher', 'text': 'You are welcome. Please ensure he practices the algebra chapter this weekend.', 'time': '11:25 AM'},
  ];

  @override
  void dispose() { _msgCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Teacher'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.go('/dashboard/parent'),
        ),
      ),
      body: Column(children: [
        // Teacher selector
        Container(color: Colors.white, padding: const EdgeInsets.all(12),
          child: DropdownButtonFormField<String>(
            value: _selectedTeacher,
            decoration: const InputDecoration(
              labelText: 'Select Teacher', prefixIcon: Icon(Icons.person),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
            items: _teachers.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12)))).toList(),
            onChanged: (v) => setState(() => _selectedTeacher = v!),
          )),
        const Divider(height: 1),

        // Messages
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: _messages.length,
          itemBuilder: (context, i) {
            final m = _messages[i];
            final isParent = m['sender'] == 'parent';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: isParent ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  if (!isParent) CircleAvatar(radius: 16,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 16)),
                  if (!isParent) const SizedBox(width: 8),
                  Flexible(child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isParent ? AppTheme.primaryColor : Colors.grey.shade100,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: Radius.circular(isParent ? 12 : 0),
                        bottomRight: Radius.circular(isParent ? 0 : 12))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (!isParent) Text(_selectedTeacher.split('(')[0].trim(),
                        style: TextStyle(fontSize: 10, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                      Text(m['text'] as String,
                        style: TextStyle(fontSize: 13, color: isParent ? Colors.white : Colors.black87)),
                      const SizedBox(height: 4),
                      Text(m['time'] as String,
                        style: TextStyle(fontSize: 9, color: isParent ? Colors.white70 : Colors.grey)),
                    ]),
                  )),
                  if (isParent) const SizedBox(width: 8),
                  if (isParent) CircleAvatar(radius: 16,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    child: const Icon(Icons.family_restroom, color: Colors.green, size: 16)),
                ],
              ),
            );
          },
        )),

        // Input
        Container(color: Colors.white,
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _msgCtrl,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            )),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: () {
                  if (_msgCtrl.text.isNotEmpty) {
                    setState(() {
                      _messages.add({'sender': 'parent', 'text': _msgCtrl.text, 'time': 'Now'});
                      _msgCtrl.clear();
                    });
                  }
                },
              ),
            ),
          ])),
      ]),
    );
  }
}



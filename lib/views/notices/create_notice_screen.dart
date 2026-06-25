import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notice_provider.dart';

class CreateNoticeScreen extends StatefulWidget {
  const CreateNoticeScreen({super.key});
  @override
  State<CreateNoticeScreen> createState() => _CreateNoticeScreenState();
}

class _CreateNoticeScreenState extends State<CreateNoticeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  String _target = 'All';

  @override
  void dispose() { _title.dispose(); _desc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white), onPressed: () => context.go((() { final role = context.read<AuthProvider>().user?.role; return role == 'staff' ? '/dashboard/staff' : role == 'student' ? '/dashboard/student' : role == 'parent' ? '/dashboard/parent' : '/dashboard/admin'; })())),title: const Text('Create Notice')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.title)),
              validator: (v) => (v == null || v.isEmpty) ? 'Title required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _desc,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description), alignLabelWithHint: true),
              validator: (v) => (v == null || v.isEmpty) ? 'Description required' : null,
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _target,
              decoration: const InputDecoration(labelText: 'Target Audience', prefixIcon: Icon(Icons.people)),
              items: ['All', 'Students', 'Staff', 'Parents']
                .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _target = v!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await context.read<NoticeProvider>().createNotice(_title.text, _desc.text);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notice published!'), backgroundColor: Colors.green));
                    context.go('/notices');
                  }
                }
              },
              child: const Text('Publish Notice'),
            ),
          ]),
        ),
      ),
    );
  }
}








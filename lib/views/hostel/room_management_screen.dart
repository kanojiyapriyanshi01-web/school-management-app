import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/hostel_provider.dart';
import '../../core/theme/app_theme.dart';

class RoomManagementScreen extends StatefulWidget {
  const RoomManagementScreen({super.key});
  @override
  State<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends State<RoomManagementScreen> {
  final _search = TextEditingController();
  bool _isCardView = true;
  String _filter = 'All';

  final List<String> _filters = ['All', 'available', 'occupied', 'maintenance'];

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Color _statusColor(String status) {
    switch (status) {
      case 'available':   return Colors.green;
      case 'occupied':    return Colors.blue;
      case 'maintenance': return Colors.orange;
      default:            return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<HostelProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/hostel/admission'),
        icon: const Icon(Icons.add),
        label: const Text('Add Room'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(children: [
        // Search + toggle
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _search,
              onChanged: p.setSearch,
              decoration: InputDecoration(
                hintText: 'Search room, block...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear),
                      onPressed: () { _search.clear(); p.setSearch(''); })
                  : null,
              ),
            )),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(_isCardView ? Icons.table_rows : Icons.grid_view),
              onPressed: () => setState(() => _isCardView = !_isCardView),
              tooltip: _isCardView ? 'Table View' : 'Card View',
            ),
          ]),
        ),
        // Filter chips
        SizedBox(
          height: 42,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _filters.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(_filters[i], style: const TextStyle(fontSize: 12)),
                selected: _filter == _filters[i],
                onSelected: (_) {
                  setState(() => _filter = _filters[i]);
                  p.setFilter(_filters[i] == 'All' ? 'All' : _filters[i]);
                },
                selectedColor: AppTheme.primaryColor.withOpacity(0.15),
                checkmarkColor: AppTheme.primaryColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Content
        Expanded(child: _isCardView ? _cardView(p) : _tableView(p)),
      ]),
    );
  }

  Widget _cardView(HostelProvider p) => GridView.builder(
    padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 220, mainAxisExtent: 200,
      crossAxisSpacing: 10, mainAxisSpacing: 10),
    itemCount: p.rooms.length,
    itemBuilder: (context, i) {
      final r = p.rooms[i];
      final color = _statusColor(r.status);
      return Card(child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Room ${r.roomNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(r.status.toUpperCase(),
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color))),
          ]),
          Text('${r.hostelName} Rs  Floor ${r.floor}',
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const Divider(),
          _roomInfo('Type', r.roomType),
          _roomInfo('Capacity', '${r.occupied}/${r.capacity}'),
          _roomInfo('Rent', 'Rs ${r.monthlyRent.toStringAsFixed(0)}/mo'),
          const Spacer(),
          Row(children: [
            if (r.isAC) _badge('AC', Colors.blue),
            const SizedBox(width: 4),
            if (r.isFurnished) _badge('Furnished', Colors.green),
          ]),
          const SizedBox(height: 6),
          // Bed occupancy indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: r.capacity > 0 ? r.occupied / r.capacity : 0,
              backgroundColor: Colors.grey.shade200,
              color: color, minHeight: 6)),
        ]),
      ));
    },
  );

  Widget _tableView(HostelProvider p) => SingleChildScrollView(
    padding: const EdgeInsets.all(14),
    child: Card(child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppTheme.primaryColor.withOpacity(0.08)),
        columns: const [
          DataColumn(label: Text('Room',    style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Hostel',  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Type',    style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Beds',    style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Rent',    style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(label: Text('Status',  style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: p.rooms.map((r) {
          final color = _statusColor(r.status);
          return DataRow(cells: [
            DataCell(Text('${r.roomNumber} (F${r.floor})', style: const TextStyle(fontSize: 12))),
            DataCell(Text(r.hostelName, style: const TextStyle(fontSize: 12))),
            DataCell(Text(r.roomType, style: const TextStyle(fontSize: 12))),
            DataCell(Text('${r.occupied}/${r.capacity}', style: const TextStyle(fontSize: 12))),
            DataCell(Text('Rs ${r.monthlyRent.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12))),
            DataCell(Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(r.status.toUpperCase(),
                style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)))),
          ]);
        }).toList(),
      ),
    )),
  );

  Widget _roomInfo(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Row(children: [
      Text('$label: ', style: const TextStyle(fontSize: 10, color: Colors.grey)),
      Text(val, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
    child: Text(text, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold)),
  );

  void _showAddRoomDialog(BuildContext context) {
    final _roomNo = TextEditingController();
    String hostel = 'Boys Hostel A';
    String type = 'double';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Room'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          DropdownButtonFormField<String>(
            value: hostel,
            decoration: const InputDecoration(labelText: 'Hostel'),
            items: ['Boys Hostel A','Girls Hostel B','Senior Boys Hostel']
              .map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
            onChanged: (v) => hostel = v!,
          ),
          const SizedBox(height: 10),
          TextField(controller: _roomNo,
            decoration: const InputDecoration(labelText: 'Room Number *')),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: type,
            decoration: const InputDecoration(labelText: 'Room Type'),
            items: ['single','double','triple','four','dormitory']
              .map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
            onChanged: (v) => type = v!,
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Room added!'), backgroundColor: Colors.green));
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}







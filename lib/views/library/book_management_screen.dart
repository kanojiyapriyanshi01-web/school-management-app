import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class BookManagementScreen extends StatefulWidget {
  const BookManagementScreen({super.key});
  @override
  State<BookManagementScreen> createState() => _BookManagementScreenState();
}

class _BookManagementScreenState extends State<BookManagementScreen> {
  final _search = TextEditingController();
  final List<String> _categories = [
        'All','Textbook','Fiction','Biography','Science','History',
        'Computer Science','Mathematics','English Literature','Hindi Literature',
        'Reference','Encyclopedia','Self Help','Sports','Art & Culture',
        'Magazine','Journal',
  ];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
      context.read<LibraryProvider>().fetchBooks());
  }

  @override
  void dispose() { _search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LibraryProvider>();
    final role = context.read<AuthProvider>().user?.role;
    final isAdmin = role == 'admin' || role == 'staff';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(children: [
        // Search
        Padding(
          padding: const EdgeInsets.all(14),
          child: TextField(
            controller: _search,
            decoration: InputDecoration(
              hintText: 'Search by title, author, ISBN...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear),
                    onPressed: () { _search.clear(); p.setSearch(''); })
                : null,
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none)),
            onChanged: p.setSearch,
          ),
        ),

        // Category filters
        SizedBox(height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _categories.length,
            itemBuilder: (ctx, i) {
              final cat = _categories[i];
              final selected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat, style: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.white : Colors.black87)),
                  selected: selected,
                  onSelected: (_) => setState(() {
                    _selectedCategory = cat;
                    p.setFilter(cat);
                  }),
                  backgroundColor: Colors.white,
                  selectedColor: AppTheme.primaryColor,
                  checkmarkColor: Colors.white,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Stats row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(children: [
            _statChip('Total: ${p.totalBooks}', Colors.blue),
            const SizedBox(width: 8),
            _statChip('Available: ${p.availableBooks}', Colors.green),
            const SizedBox(width: 8),
            _statChip('Issued: ${p.issuedBooks}', Colors.orange),
          ]),
        ),
        const SizedBox(height: 8),

        // Books list
        Expanded(child: p.isLoading
          ? const Center(child: CircularProgressIndicator())
          : p.books.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.menu_book, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('No books found', style: TextStyle(color: Colors.grey)),
                if (isAdmin) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showAddBookDialog(context, p),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Book')),
                ],
              ]))
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: p.books.length,
                itemBuilder: (ctx, i) => _bookCard(ctx, p.books[i], isAdmin, p),
              )),
      ]),
      floatingActionButton: isAdmin ? FloatingActionButton.extended(
        onPressed: () => _showAddBookDialog(context, p),
        icon: const Icon(Icons.add),
        label: const Text('Add Book'),
      ) : null,
    );
  }

  Widget _bookCard(BuildContext context, book, bool isAdmin, LibraryProvider p) {
    final available = book.availableCopies > 0;
    final categoryColors = {
        'Textbook': Colors.blue,
        'Fiction': Colors.purple,
        'Biography': Colors.orange,
        'Science': Colors.green,
        'History': Colors.brown,
        'Computer Science': Colors.teal,
    };
    final color = categoryColors[book.category] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          // Book icon
          Container(
            width: 50, height: 65,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3))),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.menu_book, color: color, size: 24),
              const SizedBox(height: 2),
              Text(book.category.split(' ').first,
                style: TextStyle(fontSize: 7, color: color),
                textAlign: TextAlign.center,
                maxLines: 2),
            ])),
          const SizedBox(width: 12),

          // Book details
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(book.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('by ${book.author}',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4)),
                child: Text(book.category,
                  style: TextStyle(fontSize: 9, color: color,
                    fontWeight: FontWeight.bold))),
              const SizedBox(width: 6),
              Text('ISBN: ${book.isbn}',
                style: const TextStyle(fontSize: 9, color: Colors.grey)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.library_books, size: 12,
                color: available ? Colors.green : Colors.red),
              const SizedBox(width: 4),
              Text('${book.availableCopies}/${book.totalCopies} available',
                style: TextStyle(fontSize: 11,
                  color: available ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500)),
              const Spacer(),
              Text(book.location,
                style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ]),
          ])),

          // Actions
          if (isAdmin) PopupMenuButton(
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
            onSelected: (v) async {
              if (v == 'delete') {
                final ok = await p.deleteBook(book.id);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Book deleted' : 'Failed'),
                    backgroundColor: ok ? Colors.green : Colors.red));
              }
            },
          ),
        ]),
      ),
    );
  }

  Widget _statChip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: TextStyle(fontSize: 11, color: color,
      fontWeight: FontWeight.w500)));

  void _showAddBookDialog(BuildContext context, LibraryProvider p) {
    final titleCtrl = TextEditingController();
    final authorCtrl = TextEditingController();
    final isbnCtrl = TextEditingController();
    final publisherCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    String category = 'Textbook';
    int copies = 1;
    int year = DateTime.now().year;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add New Book'),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Book Title *', prefixIcon: Icon(Icons.book))),
            const SizedBox(height: 10),
            TextField(controller: authorCtrl,
              decoration: const InputDecoration(
                labelText: 'Author *', prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 10),
            TextField(controller: isbnCtrl,
              decoration: const InputDecoration(
                labelText: 'ISBN', prefixIcon: Icon(Icons.qr_code))),
            const SizedBox(height: 10),
            TextField(controller: publisherCtrl,
              decoration: const InputDecoration(
                labelText: 'Publisher', prefixIcon: Icon(Icons.business))),
            const SizedBox(height: 10),
            TextField(controller: locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Shelf Location', prefixIcon: Icon(Icons.location_on))),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: 'Category'),
              isExpanded: true,
              items: [
        'Textbook','Fiction','Non-Fiction','Science','Mathematics',
        'History','Geography','English Literature','Hindi Literature',
        'Computer Science','Reference','Encyclopedia','Biography',
        'Self Help','Sports','Art & Culture','Religion','Magazine','Journal',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setS(() => category = v!),
            ),
            const SizedBox(height: 10),
            Row(children: [
              const Text('Copies: ', style: TextStyle(fontSize: 13)),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: copies > 1 ? () => setS(() => copies--) : null),
              Text('$copies', style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => setS(() => copies++)),
            ]),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
            ElevatedButton.icon(
              onPressed: () async {
                if (titleCtrl.text.isEmpty || authorCtrl.text.isEmpty) return;
                Navigator.pop(ctx);
                final ok = await p.addBook(
                  title: titleCtrl.text,
                  author: authorCtrl.text,
                  isbn: isbnCtrl.text,
                  category: category,
                  copies: copies,
                  publisher: publisherCtrl.text,
                  location: locationCtrl.text,
                );
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? 'Book added successfully!' : 'Failed to add book'),
                    backgroundColor: ok ? Colors.green : Colors.red));
              },
              icon: const Icon(Icons.save),
              label: const Text('Add Book')),
          ],
        ),
      ),
    );
  }
}




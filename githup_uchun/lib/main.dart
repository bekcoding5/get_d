import 'package:flutter/material.dart';

void main() {
  runApp(const MyContactApp());
}

class MyContactApp extends StatelessWidget {
  const MyContactApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kontaktlar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
      ),
      themeMode: ThemeMode.system,
      home: const ContactHomePage(),
    );
  }
}

class Contact {
  String name;
  String phone;

  Contact({required this.name, required this.phone});
}

class ContactHomePage extends StatefulWidget {
  const ContactHomePage({super.key});

  @override
  State<ContactHomePage> createState() => _ContactHomePageState();
}

class _ContactHomePageState extends State<ContactHomePage> {
  final List<Contact> _contactList = [];
  bool isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void _openContactModal({Contact? contact, int? index}) {
    final nameController = TextEditingController(text: contact?.name ?? '');
    final phoneController = TextEditingController(text: contact?.phone ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: MediaQuery.of(ctx).viewInsets.add(const EdgeInsets.all(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              contact == null ? 'Yangi kontakt' : 'Kontaktni yangilash',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Ism'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Telefon'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                if (name.isNotEmpty && phone.isNotEmpty) {
                  setState(() {
                    if (index != null) {
                      _contactList[index] = Contact(name: name, phone: phone);
                    } else {
                      _contactList.add(Contact(name: name, phone: phone));
                    }
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Saqlash'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _deleteContact(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('O‘chirish'),
        content: const Text('Bu kontaktni o‘chirilsinmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _contactList.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text('O‘chirish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = isDarkMode ? ThemeMode.dark : ThemeMode.light;

    return MaterialApp(
      themeMode: currentTheme,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('📇 Kontaktlar'),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        body: _contactList.isEmpty
            ? const Center(
                child: Text(
                  'Kontaktlar yo‘q',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _contactList.length,
                itemBuilder: (ctx, i) {
                  final contact = _contactList[i];
                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(contact.name[0].toUpperCase()),
                      ),
                      title: Text(contact.name),
                      subtitle: Text(contact.phone),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _openContactModal(contact: contact, index: i),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteContact(i),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openContactModal(),
          icon: const Icon(Icons.add),
          label: const Text('Kontakt qo‘shish'),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const ContactsApp());
}

// Kontakt modeli
class Contact {
  final String name;
  final String phone;

  Contact({required this.name, required this.phone});
}

class ContactsApp extends StatefulWidget {
  const ContactsApp({Key? key}) : super(key: key);

  @override
  State<ContactsApp> createState() => _ContactsAppState();
}

class _ContactsAppState extends State<ContactsApp> {
  ThemeMode _themeMode = ThemeMode.system;

  bool get isLightTheme {
    if (_themeMode == ThemeMode.system) {
      return SchedulerBinding.instance.window.platformBrightness ==
          Brightness.light;
    }
    return _themeMode == ThemeMode.light;
  }

  void _switchTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kontaktlar ilovasi',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.teal,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.teal,
      ),
      home: ContactsPage(
        isLightTheme: isLightTheme,
        onThemeToggle: _switchTheme,
      ),
    );
  }
}

class ContactsPage extends StatefulWidget {
  final bool isLightTheme;
  final VoidCallback onThemeToggle;

  const ContactsPage({
    Key? key,
    required this.isLightTheme,
    required this.onThemeToggle,
  }) : super(key: key);

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final List<Contact> _contacts = [];

  Future<void> _openContactForm({Contact? contact, int? index}) async {
    final result = await Navigator.of(context).push<Contact>(
      MaterialPageRoute(
        builder: (context) => ContactFormScreen(contact: contact),
      ),
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          _contacts[index] = result;
        } else {
          _contacts.add(result);
        }
      });
    }
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kontaktni o‘chirish'),
        content: const Text('Haqiqatan ham o‘chirmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _contacts.removeAt(index);
              });
              Navigator.of(context).pop();
            },
            child: const Text('O‘chirish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontaktlar ro‘yxati'),
        actions: [
          IconButton(
            tooltip: 'Mavzuni o‘zgartirish',
            icon: widget.isLightTheme
                ? const Icon(Icons.dark_mode)
                : const Icon(Icons.light_mode),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: _contacts.isEmpty
          ? const Center(child: Text('Kontaktlar mavjud emas'))
          : ListView.separated(
              itemCount: _contacts.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return ListTile(
                  title: Text(contact.name),
                  subtitle: Text(contact.phone),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _openContactForm(contact: contact, index: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openContactForm(),
        tooltip: 'Yangi kontakt qo‘shish',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ContactFormScreen extends StatefulWidget {
  final Contact? contact;

  const ContactFormScreen({Key? key, this.contact}) : super(key: key);

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _phone;

  @override
  void initState() {
    super.initState();
    _name = widget.contact?.name ?? '';
    _phone = widget.contact?.phone ?? '';
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final newContact = Contact(name: _name, phone: _phone);
      Navigator.of(context).pop(newContact);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.contact != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Kontaktni tahrirlash' : 'Yangi kontakt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Ism'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Iltimos, ism kiriting';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!.trim(),
              ),
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(labelText: 'Telefon raqam'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Iltimos, telefon raqam kiriting';
                  }
                  return null;
                },
                onSaved: (value) => _phone = value!.trim(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Saqlash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

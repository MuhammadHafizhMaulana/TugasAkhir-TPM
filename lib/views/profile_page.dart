import 'package:flutter/material.dart';
import 'package:royal_clothes/db/database_helper.dart';
import 'package:royal_clothes/views/sidebar_menu_page.dart';
import 'package:royal_clothes/views/appBar_page.dart';

class ProfilePage extends StatefulWidget {
  final String email; // Email sebagai identitas login
  const ProfilePage({super.key, required this.email});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  String _email = '';
  bool _isEditing = false;
  bool _isLoading = true;

  // Fungsi dekripsi Caesar cipher
  String caesarDecrypt(String text, int key) {
    return String.fromCharCodes(text.runes.map((char) {
      if (char >= 65 && char <= 90) {
        // Uppercase
        return ((char - 65 - key + 26) % 26) + 65;
      } else if (char >= 97 && char <= 122) {
        // Lowercase
        return ((char - 97 - key + 26) % 26) + 97;
      } else {
        // Non-alphabetic characters stay the same
        return char;
      }
    }));
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await DBHelper().getUserByEmail(widget.email);
    if (user != null) {
      // Dekripsi nama dan email sesuai kunci masing-masing
      final decryptedName = caesarDecrypt(user['name'], 7);
      final decryptedEmail = caesarDecrypt(user['email'], 14);

      setState(() {
        _email = decryptedEmail;
        _nameController.text = decryptedName;
        _isLoading = false;
      });
    } else {
      // Handle user not found
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not found")),
      );
    }
  }

  Future<void> _saveNewName() async {
    // Simpan nama dalam bentuk terenkripsi (kunci 7)
    final encryptedName = _nameController.text.isNotEmpty
        ? _caesarEncrypt(_nameController.text, 7)
        : '';

    await DBHelper().updateUserName(_email, encryptedName);
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nama berhasil diperbarui")),
    );
  }

  // Fungsi enkripsi Caesar cipher untuk menyimpan nama
  String _caesarEncrypt(String text, int key) {
    return String.fromCharCodes(text.runes.map((char) {
      if (char >= 65 && char <= 90) {
        return ((char - 65 + key) % 26) + 65;
      } else if (char >= 97 && char <= 122) {
        return ((char - 97 + key) % 26) + 97;
      } else {
        return char;
      }
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppbarPage(
        title: ("Profile"),
      ),
      drawer: SidebarMenu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar Profile
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[800],
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nama
                  TextField(
                    controller: _nameController,
                    enabled: _isEditing,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.amber),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Email (readonly)
                  TextFormField(
                    initialValue: _email,
                    enabled: false,
                    style: const TextStyle(color: Colors.white70),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Tombol Aksi
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(_isEditing ? Icons.save : Icons.edit),
                      label: Text(_isEditing ? "Simpan" : "Edit Nama"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isEditing ? Colors.green : Colors.amber,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isEditing ? _saveNewName : () {
                        setState(() => _isEditing = true);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

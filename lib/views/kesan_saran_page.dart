import 'package:flutter/material.dart';
import 'package:royal_clothes/views/appBar_page.dart';
import 'package:royal_clothes/views/sidebar_menu_page.dart';

class KesanSaranPage extends StatelessWidget {
  const KesanSaranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPage(
        title: ('Kesan dan Saran'),
      ),
      drawer: SidebarMenu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/3X4.jpg'), // Ganti dengan nama file Anda
            ),
            const SizedBox(height: 16),
            const Text(
              'Muhammad Hafizh Maulana',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'NIM: 123210194',
              style: TextStyle(fontSize: 16),
            ),
            const Text(
              'Kelas: IF-B',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kesan:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sangat menyenangkan belajar bersama dengan pak Bagus dan teman teman dikelas, sebuah pengalaman yang asik dan menantang.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Saran:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ujiannya soalnya sudah cukup banyak dan menantang, mungkin akan lebih menantang lagi apabila soal yang salah diberi poin negatif.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
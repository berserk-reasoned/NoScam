// lib/features/pairing/presentation/pairing_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class PairingScreen extends ConsumerStatefulWidget {
  const PairingScreen({super.key});

  @override
  ConsumerState<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends ConsumerState<PairingScreen> {
  String? generatedCode;
  final TextEditingController _codeController = TextEditingController();

  // Step A: User side - Generate Code
  void _generateCode() {
    // Generate a 6-digit alphanumeric code
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final code = String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));

    setState(() {
      generatedCode = code;
    });

    // TODO: Write to Firestore
    // FirebaseFirestore.instance.collection('pairing_codes').doc(code).set({
    //   'creator_uid': 'currentUserUID', // Replace with actual Auth UID
    //   'timestamp': FieldValue.serverTimestamp(),
    // });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code $code generated! Valid for 10 minutes.')),
    );
  }

  // Step B & C & D: Guardian side - Link User
  void _linkUser() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit code.')),
      );
      return;
    }

    // TODO: Firestore logic
    // 1. Query 'pairing_codes' collection for document ID == code
    // 2. If exists, read 'creator_uid'
    // 3. Update 'users' collection where doc ID == creator_uid -> add current guardian UID to 'guardians' array
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Linking to user... (Mocked)')),
    );
    
    // Navigate to dashboard after success
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pairing Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'I Need Protection (User)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateCode,
              child: const Text('Generate 6-Digit Code'),
            ),
            if (generatedCode != null) ...[
              const SizedBox(height: 16),
              Text(
                generatedCode!,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                textAlign: TextAlign.center,
              ),
              const Text(
                'Share this code with your Guardian.',
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 48),
            const Divider(),
            const SizedBox(height: 48),
            const Text(
              'I am Monitoring Someone (Guardian)',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Enter 6-Digit Code',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _linkUser,
              child: const Text('Link with User'),
            ),
          ],
        ),
      ),
    );
  }
}

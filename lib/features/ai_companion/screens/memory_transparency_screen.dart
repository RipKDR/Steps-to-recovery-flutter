// Stub — full implementation in Task 9
import 'package:flutter/material.dart';
import '../../../core/services/sponsor_service.dart';

class MemoryTransparencyScreen extends StatelessWidget {
  const MemoryTransparencyScreen({
    super.key,
    required this.sponsorName,
    SponsorService? sponsorService,
  });
  final String sponsorName;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('What $sponsorName knows about you.')),
    body: const Center(child: Text('Loading...')),
  );
}

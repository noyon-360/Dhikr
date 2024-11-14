import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhikrs/Controller/NameClass.dart';
import 'package:flutter/material.dart';

class Download extends StatefulWidget {
  const Download({super.key});

  @override
  State<Download> createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<MorningDhikr>> fetchMorningDhikr() async {
    final snapshot = await _firestore.collection('dhikrs').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return MorningDhikr(
        name: data['name'],
        meaning: data['meaning'],
        reference: data['reference'],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Morning Dhikr')),
      body: FutureBuilder<List<MorningDhikr>>(
        future: fetchMorningDhikr(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Dhikr found'));
          }

          final dhikrList = snapshot.data!;
          return ListView.builder(
            itemCount: dhikrList.length,
            itemBuilder: (context, index) {
              final dhikr = dhikrList[index];
              return ListTile(
                title: Text(dhikr.name),
                subtitle: Text(dhikr.meaning),
                trailing: Text(dhikr.reference),
              );
            },
          );
        },
      ),
    );
  }
}

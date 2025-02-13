
  import 'package:flutter/material.dart';

Widget buildActivityRow(String activity, String progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(activity, style: const TextStyle(fontSize: 16)),
          Text(progress, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
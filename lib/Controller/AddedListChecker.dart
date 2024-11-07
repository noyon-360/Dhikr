import 'package:dhikrs/Controller/Provider/AllahNamesProvider.dart';
import 'package:dhikrs/Controller/Provider/DhirkProvider.dart';
import 'package:dhikrs/Controller/Provider/UserSavedProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddedListChecker {
  static List<dynamic> getAllSelectedItems(BuildContext context) {
  final dhikrProvider = Provider.of<DhikrProvider>(context, listen: false);
  final allahNamesProvider = Provider.of<AllahNamesProvider>(context, listen: false);
  final userSaveDuaProvider = Provider.of<UserSaveDuaProvider>(context, listen: false);

  final selectedNames = allahNamesProvider.getSelectedNames();
  final selectedDhikrs = dhikrProvider.getSelectedDhikrs();
  final userAddedList = userSaveDuaProvider.getSelectedSaved();

  return [...selectedNames, ...selectedDhikrs, ...userAddedList];
}
}

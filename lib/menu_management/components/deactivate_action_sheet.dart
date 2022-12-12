import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project1/common/models/product.dart';
import 'package:project1/menu_management/blocs/table_layout_bloc.dart';
import 'package:project1/menu_management/components/success_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeactivateActionSheet extends StatelessWidget {
  const DeactivateActionSheet({
    Key? key,
    required this.productResult,
  }) : super(key: key);

  final Product productResult;
  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: const CupertinoThemeData(
        textTheme: CupertinoTextThemeData(primaryColor: Colors.black),
      ),
      child: CupertinoActionSheet(
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.red),
          ),
        ),
        title: Text(productResult.enabled
            ? 'Are you sure you want to take out this menu item?'
            : 'Are you sure you want make this menu item available?'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              deactivateProduct(context);
            },
            child: Text(productResult.enabled
                ? 'Deactivate until further notice'
                : 'Confirm'),
          ),
          if (productResult.enabled)
            CupertinoActionSheetAction(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final today = DateTime.now();
                final tomorrow =
                    DateTime(today.year, today.month, today.day + 1);
                final DateFormat formatter = DateFormat('yyyyMMdd');
                await prefs.setString(
                  productResult.id,
                  formatter.format(tomorrow),
                );
                deactivateProduct(context);
              },
              child: const Text('Deactivate until tomorrow'),
            ),
        ],
      ),
    );
  }

  void deactivateProduct(BuildContext context) async {
    final succesfull =
        await context.read<TableLayoutBloc>().changeProductStatus(
              productResult,
            );
    if (succesfull) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => const SuccessScreen(),
        ),
      );
      Navigator.pop(context);
    }
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project1/common/models/category.dart';
import 'package:project1/common/models/product.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:project1/menu_management/blocs/table_layout_bloc.dart';
import 'package:project1/menu_management/components/add_product_dialog.dart';
import 'package:provider/provider.dart';

class ProductOptionsSheet extends StatelessWidget {
  const ProductOptionsSheet({
    Key? key,
    required this.product,
    required this.currentCategoryId,
    required this.categories,
  }) : super(key: key);

  final Product product;
  final String currentCategoryId;
  final List<ProductCategory>? categories;
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
        title: const Text('Product options'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              final bloc = context.read<TableLayoutBloc>();
              final userSession = context.read<FirebaseUser>();
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return MultiProvider(
                    providers: [
                      Provider.value(value: userSession),
                      Provider.value(value: bloc),
                    ],
                    child: AddOrEditProductDialog(
                      category: currentCategoryId,
                      availableCategories: categories,
                      product: product,
                    ),
                  );
                },
              );
            },
            child: const Text('Edit'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              product.deleted = true;
              context.read<TableLayoutBloc>().softDeleteProduct(product);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

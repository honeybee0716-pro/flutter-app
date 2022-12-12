import 'package:flutter/material.dart';
import 'package:project1/common/models/category.dart';
import 'package:project1/common/models/menu.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:project1/menu_management/blocs/table_layout_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AddOrUpdateCategoryDialog extends StatefulWidget {
  final ProductCategory? category;
  const AddOrUpdateCategoryDialog({
    Key? key,
    this.category,
  }) : super(key: key);

  @override
  State<AddOrUpdateCategoryDialog> createState() =>
      _AddOrUpdateCategoryDialogState();
}

class _AddOrUpdateCategoryDialogState extends State<AddOrUpdateCategoryDialog> {
  TextEditingController nameC = TextEditingController();

  String? selectedMenuId;

  @override
  void initState() {
    if (widget.category != null) {
      nameC.text = widget.category!.name;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 80.w,
          decoration: BoxDecoration(
            color: const Color(0xff2f3032),
            borderRadius: BorderRadius.circular(5.w),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModalTitle(context),
              Padding(
                padding: EdgeInsets.all(2.w),
                child: Row(
                  children: [
                    const Text("Sub menu name:",
                        style: TextStyle(color: Colors.white)),
                    Padding(padding: EdgeInsets.all(1.w)),
                    Expanded(
                      child: TextFormField(
                        controller: nameC,
                        cursorColor: Colors.white,
                        cursorWidth: 1,
                        autofocus: true,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                        decoration:
                            const InputDecoration(border: InputBorder.none),
                      ),
                    )
                  ],
                ),
              ),
              if (widget.category != null) buildMenuGroupPicker(),
              const Divider(height: 1, thickness: 3),
              buildSaveAction(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuGroupPicker() {
    final bloc = context.read<TableLayoutBloc>();
    return ListTileTheme(
        dense: true,
        iconColor: Colors.white,
        child: ExpansionTile(
          backgroundColor: Colors.black,
          iconColor: Colors.white,
          collapsedBackgroundColor: Colors.black,
          collapsedIconColor: Colors.white,
          title: Text(
            "Menu:",
            style: TextStyle(color: Colors.white, fontSize: 10.sp),
          ),
          children: [
            IntrinsicHeight(
              child: FutureBuilder<List<Menu>>(
                  future: bloc.getMenusByRestaurantId(),
                  builder: (context, snapshot) {
                    final data = snapshot.data;
                    if (data == null) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Column(
                      children: data.map(
                        (menu) {
                          return Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedMenuId = menu.id;
                                });
                              },
                              child: Container(
                                color: menu.id == selectedMenuId
                                    ? Colors.grey
                                    : const Color(0xff242527),
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    menu.name.toString(),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    );
                  }),
            )
          ],
        ));
  }

  Widget _buildModalTitle(BuildContext context) {
    return Container(
      height: 5.h,
      decoration: BoxDecoration(
          color: const Color(0xff242527),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5.w), topRight: Radius.circular(5.w))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: const Text(
              "Add new sub menu",
              style: TextStyle(color: Colors.white),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                Navigator.pop(context);
              });
            },
            child: Padding(
              padding: EdgeInsets.only(right: 2.w),
              child: const Icon(
                Icons.clear,
                color: Color(0xff5c5d5e),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildSaveAction(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: ValueListenableBuilder<bool>(
        valueListenable: context.read<TableLayoutBloc>().loading,
        builder: (context, bool loading, _) {
          return GestureDetector(
            onTap: updateOrCreateCategory,
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff242527),
                      borderRadius: BorderRadius.circular(1.h),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: const Text(
                        "SAVE",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  void updateOrCreateCategory() async {
    final bloc = context.read<TableLayoutBloc>();
    final finalCategory = ProductCategory(
      id: widget.category?.id ?? '',
      name: nameC.text,
      status: widget.category?.status ?? true,
      restaurantId: context.read<FirebaseUser>().uid,
    );
    if (widget.category != null) {
      await bloc.updateCategory(
        finalCategory,
        selectedMenuId,
      );
    } else {
      await bloc.addCategory(finalCategory);
    }

    Navigator.pop(context);
  }
}

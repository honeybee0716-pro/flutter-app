import 'package:flutter/material.dart';
import 'package:project1/common/models/menu.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:project1/menu_management/blocs/table_layout_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AddOrUpdateMenuDialog extends StatefulWidget {
  final Menu? menu;
  const AddOrUpdateMenuDialog({
    Key? key,
    this.menu,
  }) : super(key: key);

  @override
  State<AddOrUpdateMenuDialog> createState() => _AddOrUpdateMenuDialogState();
}

class _AddOrUpdateMenuDialogState extends State<AddOrUpdateMenuDialog> {
  TextEditingController nameC = TextEditingController();

  @override
  void initState() {
    if (widget.menu != null) {
      nameC.text = widget.menu!.name;
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
              borderRadius: BorderRadius.circular(5.w)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5.h,
                decoration: BoxDecoration(
                  color: const Color(0xff242527),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5.w),
                    topRight: Radius.circular(5.w),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 20.w),
                      child: const Text(
                        "Add new Menu Group",
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
              ),
              Padding(
                padding: EdgeInsets.all(2.w),
                child: Row(
                  children: [
                    const Text("Menu name:",
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
              const Divider(height: 1, thickness: 3),
              buildSaveAction(context),
            ],
          ),
        ),
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
            onTap: updateOrCreateMenu,
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

  void updateOrCreateMenu() async {
    final bloc = context.read<TableLayoutBloc>();
    final finalMenu = Menu(
      id: widget.menu?.id ?? '',
      name: nameC.text,
      restaurantId: context.read<FirebaseUser>().uid,
    );
    if (widget.menu != null) {
      await bloc.updateMenu(finalMenu);
    } else {
      await bloc.addMenu(finalMenu);
    }

    Navigator.of(context).pop(true);
  }
}

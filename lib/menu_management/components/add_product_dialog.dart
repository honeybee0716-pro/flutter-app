import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project1/common/models/category.dart';
import 'package:project1/common/models/menu.dart';
import 'package:project1/common/models/product.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:project1/common/utils/utils.dart';
import 'package:project1/menu_management/blocs/table_layout_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class AddOrEditProductDialog extends StatefulWidget {
  final String category;
  final List<ProductCategory>? availableCategories;
  final Product? product;
  const AddOrEditProductDialog({
    Key? key,
    required this.category,
    required this.availableCategories,
    this.product,
  }) : super(key: key);

  @override
  State<AddOrEditProductDialog> createState() => _AddOrEditProductDialogState();
}

class _AddOrEditProductDialogState extends State<AddOrEditProductDialog> {
  List filters = ["chicken", "Seafood", "Chicken", "Salads"];
  File? mYimage;
  File? myImage2;
  String base64im = "";
  bool isSubmit = false;
  int? selectedFilter;

  late String selectedCategoryId;
  String? selectedMenuId;

  TextEditingController itemnumberC = TextEditingController();
  TextEditingController nameC = TextEditingController();
  TextEditingController descriptionC = TextEditingController();
  TextEditingController priceC = TextEditingController();
  TextEditingController stockC = TextEditingController();

  @override
  void initState() {
    selectedCategoryId = widget.category;
    if (widget.product != null) {
      itemnumberC.text = '123';
      nameC.text = widget.product!.name;
      stockC.text = '123';
      priceC.text = widget.product!.price.toString();
      descriptionC.text = widget.product!.description;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 80.w,
        decoration: const BoxDecoration(
          color: Color(0xff2f3032),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildDialogHeader(context),
              buildPicturesField(),
              buildProductNameField(),
              buildPriceField(),
              buildDescriptionField(),
              const Divider(height: 1),
              buildMenuGroupPicker(),
              buildProductCategoryPicker(),
              const Divider(height: 1),
              buildSubmitAction(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildItemNumberField() {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: Row(
        children: [
          const Text("Item number : # ", style: TextStyle(color: Colors.white)),
          Padding(padding: EdgeInsets.all(1.w)),
          Expanded(
            child: TextFormField(
              controller: itemnumberC,
              cursorHeight: 5.w,
              cursorColor: Colors.white,
              style: TextStyle(color: Colors.white, fontSize: 10.sp),
              cursorWidth: 1,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          )
        ],
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

  Widget buildProductCategoryPicker() {
    return ListTileTheme(
        dense: true,
        iconColor: Colors.white,
        child: ExpansionTile(
          backgroundColor: Colors.black,
          iconColor: Colors.white,
          collapsedBackgroundColor: Colors.black,
          collapsedIconColor: Colors.white,
          title: Text(
            "Category :",
            style: TextStyle(color: Colors.white, fontSize: 10.sp),
          ),
          children: [
            IntrinsicHeight(
              child: Column(
                  children: widget.availableCategories!.map((category) {
                return Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedCategoryId = category.id;
                      });
                    },
                    child: Container(
                      color: category.id == selectedCategoryId
                          ? Colors.grey
                          : const Color(0xff242527),
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(category.name.toString(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  ),
                );
              }).toList()),
            )
          ],
        ));
  }

  Widget buildSubmitAction(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: GestureDetector(
        onTap: updateOrCreateProduct,
        child: ValueListenableBuilder(
          valueListenable: context.read<TableLayoutBloc>().loading,
          builder: (context, bool loading, _) {
            return Container(
              decoration: BoxDecoration(
                  color: const Color(0xff242527),
                  borderRadius: BorderRadius.circular(1.h)),
              child: Padding(
                padding: EdgeInsets.all(3.w),
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "SUBMIT",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildDescriptionField() {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: Row(
        children: [
          const Text("Description : ", style: TextStyle(color: Colors.white)),
          Padding(padding: EdgeInsets.all(1.w)),
          Expanded(
            child: TextFormField(
              controller: descriptionC,
              style: TextStyle(color: Colors.white, fontSize: 10.sp),
              cursorHeight: 5.w,
              cursorColor: Colors.white,
              cursorWidth: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPriceField() {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: Row(children: [
        const Text("Price : \$ ", style: TextStyle(color: Colors.white)),
        Padding(padding: EdgeInsets.all(1.w)),
        Expanded(
            child: TextFormField(
          controller: priceC,
          style: TextStyle(color: Colors.white, fontSize: 10.sp),
          cursorHeight: 5.w,
          cursorColor: Colors.white,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          cursorWidth: 1,
          decoration: const InputDecoration(border: InputBorder.none),
        ))
      ]),
    );
  }

  Widget buildProductNameField() {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: Row(children: [
        const Text("Name : ", style: TextStyle(color: Colors.white)),
        Padding(padding: EdgeInsets.all(1.w)),
        Expanded(
            child: TextFormField(
          controller: nameC,
          cursorHeight: 5.w,
          cursorColor: Colors.white,
          style: TextStyle(color: Colors.white, fontSize: 10.sp),
          cursorWidth: 1,
          decoration: const InputDecoration(border: InputBorder.none),
        ))
      ]),
    );
  }

  Widget buildPicturesField() {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Pictures: ", style: TextStyle(color: Colors.white)),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 2.w, bottom: 2.w),
              child: mYimage != null
                  ? SizedBox(
                      height: 7.h,
                      width: 7.h,
                      child: Image.file(
                        mYimage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : widget.product != null
                      ? kIsWeb
                          ? Image.network(
                              widget.product!.image,
                              width: 7.h,
                              height: 7.h,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              width: 7.h,
                              height: 7.h,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.low,
                              imageUrl: widget.product!.image,
                              errorWidget: (context, url, error) {
                                return Center(
                                    child: Text(
                                  error.toString(),
                                  style: const TextStyle(color: Colors.red),
                                ));
                              },
                              placeholder: (context, url) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              },
                            )
                      : Container(
                          height: 7.h,
                          width: 7.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                          ),
                        ),
            ),
          ),
          IconButton(
            onPressed: () async {
              mYimage = await pickImage();
              setState(() {});
            },
            icon: const Icon(Icons.add, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget buildDialogHeader(BuildContext context) {
    return Container(
      height: 5.h,
      decoration: const BoxDecoration(
        color: Color(0xff242527),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 30.w),
            child: const Text(
              "Insert Item",
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

  void updateOrCreateProduct() async {
    final bloc = context.read<TableLayoutBloc>();
    final finalProduct = Product(
      id: widget.product?.id ?? itemnumberC.text,
      name: nameC.text,
      image: widget.product?.image ?? 'noImage',
      description: descriptionC.text,
      categoryId: selectedCategoryId,
      enabled: true,
      price: double.parse(priceC.text),
      views: 0,
      deleted: widget.product?.deleted ?? false,
      restaurantId: context.read<FirebaseUser>().uid,
      positionInCategory: widget.product?.positionInCategory,
      menuId: selectedMenuId,
    );
    if (widget.product != null) {
      await bloc.updateProduct(finalProduct, mYimage);
    } else {
      await bloc.addProduct(finalProduct, mYimage);
    }

    Navigator.pop(context);
  }
}

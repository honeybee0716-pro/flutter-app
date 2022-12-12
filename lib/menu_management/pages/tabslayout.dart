import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project1/common/models/category.dart';
import 'package:project1/common/models/product.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:project1/common/style/mynuu_colors.dart';
import 'package:project1/common/utils/debounce.dart';
import 'package:project1/menu_management/components/add_category_dialog.dart';
import 'package:project1/menu_management/components/add_menu_dialog.dart';
import 'package:project1/menu_management/components/add_product_dialog.dart';
import 'package:project1/menu_management/components/deactivate_action_sheet.dart';
import 'package:project1/menu_management/components/product_options_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../blocs/table_layout_bloc.dart';

class TabsLayout extends StatefulWidget {
  final int? previousTab;
  final int? initalTab;
  const TabsLayout({Key? key, this.previousTab, this.initalTab})
      : super(key: key);

  @override
  State<TabsLayout> createState() => _TabsLayoutState();
}

class _TabsLayoutState extends State<TabsLayout> {
  late final TableLayoutBloc bloc = context.read<TableLayoutBloc>();
  TextEditingController searchC = TextEditingController();

  List<Product> filteredProducts = [];

  late final userSession = context.read<FirebaseUser>();

  int? tabBarIndex;

  final Debounce _debounce = Debounce(const Duration(milliseconds: 100));

  List<Product> _productList = <Product>[];

  @override
  void initState() {
    tabBarIndex = widget.initalTab ?? 0;
    super.initState();
  }

  String searchText = "";
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xff18191B),
            Color(0xff3A3B3D),
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        borderRadius: BorderRadius.circular(4.h),
      ),
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child: StreamBuilder<List<ProductCategory>>(
          stream: bloc.streamCategories(),
          builder: (BuildContext context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            final categories = snapshot.data ?? [];

            return DefaultTabController(
              length: categories.length,
              initialIndex: widget.initalTab ?? 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: mynuuBackground,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Padding(
                            padding: EdgeInsets.only(left: 4.0),
                            child: Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      buildSearchOptions(context),
                    ],
                  ),
                  if (searchC.text.isEmpty)
                    buildCategoriesTabBar(categories, context),
                  if (categories.isNotEmpty && searchC.text.isEmpty)
                    buildProductList(
                      context,
                      categoryId: categories[tabBarIndex!].id,
                      categories: categories,
                    ),
                  if (searchC.text.isNotEmpty)
                    _buildFilteredProductsTable(categories, context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilteredProductsTable(
      List<ProductCategory> categories, BuildContext context) {
    List<String> filteredCategories = [];
    for (final pro in filteredProducts) {
      if (!filteredCategories.contains(pro.categoryId)) {
        filteredCategories.add(pro.categoryId);
      }
    }
    return Expanded(
      child: ListView(
        children: [
          Table(
            border: TableBorder.all(
              color: const Color(0xff1d1f20),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  tableHeader("Pictures", isHeader: true),
                  tableHeader("Name", isHeader: true),
                  tableHeader("Description", isHeader: true),
                  tableHeader("Price", isHeader: true),
                  tableHeader("Access", isHeader: true),
                ],
              ),
            ],
          ),
          ...categories
              .where(
                (element) => filteredCategories.contains(element.id),
              )
              .map(
                (category) => ListTileTheme(
                  dense: true,
                  child: ExpansionTile(
                    iconColor: Colors.white,
                    collapsedBackgroundColor: Colors.black,
                    collapsedIconColor: Colors.white,
                    title: Text(
                      category.name,
                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                    ),
                    initiallyExpanded: true,
                    children: [
                      Table(
                        children: filteredProducts
                            .where(
                                (element) => element.categoryId == category.id)
                            .map(
                              (pro) => TableRow(children: [
                                _buildProductImage(
                                    context, categories, category.id, pro),
                                TableRowInkWell(
                                  onTap: () => openProductOptionsDialog(
                                    context,
                                    categories: categories,
                                    categoryId: category.id,
                                    pro: pro,
                                  ),
                                  child: tableHeader(
                                    pro.name,
                                  ),
                                ),
                                TableRowInkWell(
                                  onTap: () => openProductOptionsDialog(
                                    context,
                                    categories: categories,
                                    categoryId: category.id,
                                    pro: pro,
                                  ),
                                  child: tableHeader(
                                    pro.description,
                                  ),
                                ),
                                TableRowInkWell(
                                  onTap: () => openProductOptionsDialog(
                                    context,
                                    categories: categories,
                                    categoryId: category.id,
                                    pro: pro,
                                  ),
                                  child: tableHeader(
                                    "\$${pro.price}",
                                  ),
                                ),
                                _buildAccessStatus(context, pro),
                              ]),
                            )
                            .toList(),
                      )
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget buildCategoriesTabBar(
      List<ProductCategory> categories, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TabBar(
            onTap: (v) {
              setState(() {
                searchC.clear();
                tabBarIndex = v;
              });
            },
            isScrollable: true,
            indicator: const BoxDecoration(
              color: Color(0xff2f3032),
            ),
            tabs: categories.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    e.name.toString(),
                    style: TextStyle(color: Colors.white, fontSize: 10.sp),
                  ),
                  categories[tabBarIndex!].id == e.id
                      ? buildCategoryHeaderOptions(context, e)
                      : const SizedBox()
                ],
              );
            }).toList(),
          ),
        ),
        buildAddNewCategory(context)
      ],
    );
  }

  Widget buildAddNewCategory(BuildContext context) {
    return PopupMenuButton(
      onSelected: (value) async {
        if (value == 0) {
          final result = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return MultiProvider(
                providers: [
                  Provider.value(value: userSession),
                  Provider.value(value: bloc),
                ],
                child: const AddOrUpdateMenuDialog(),
              );
            },
          );
          if (result != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Yay! Menu succesfully created!'),
              ),
            );
          }
        }

        if (value == 1) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return MultiProvider(
                providers: [
                  Provider.value(value: userSession),
                  Provider.value(value: bloc),
                ],
                child: const AddOrUpdateCategoryDialog(),
              );
            },
          );
        }
      },
      icon: CircleAvatar(
        radius: 5.w,
        backgroundColor: const Color(0xff2f3032),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      itemBuilder: (context) {
        return const [
          PopupMenuItem(
            value: 0,
            child: Text(
              "Menu Group",
              style: TextStyle(color: Colors.white),
            ),
          ),
          PopupMenuItem(
            value: 1,
            child: Text(
              "Sub Category",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ];
      },
    );
  }

  Widget buildCategoryHeaderOptions(
      BuildContext context, ProductCategory category) {
    return PopupMenuButton(
      onSelected: (value) {
        if (value == 0) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return MultiProvider(
                providers: [
                  Provider.value(value: userSession),
                  Provider.value(value: bloc),
                ],
                child: AddOrUpdateCategoryDialog(
                  category: category,
                ),
              );
            },
          );
        }
        if (value == 1) {
          bloc.deleteCategory(category.id);
        }
      },
      color: const Color(0xff242527),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.w)),
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) {
        return const [
          PopupMenuItem(
            value: 0,
            child: Text(
              "Edit",
              style: TextStyle(color: Colors.white),
            ),
          ),
          PopupMenuItem(
            value: 1,
            child: Text(
              "Delete",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ];
      },
    );
  }

  Widget buildProductList(
    BuildContext context, {
    required String categoryId,
    required List<ProductCategory> categories,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(top: 2.w, bottom: 2.w),
        child: StreamBuilder<List<Product>>(
          stream: bloc.streamProductByCategory(
              categoryId), // .getProductsByCategory(categoryId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            _productList = snapshot.data!;

            if (_productList.isEmpty) {
              return Column(
                children: [
                  buildAddNewEntry(
                    context,
                    categoryId: categoryId,
                    categories: categories,
                  ),
                  const Center(
                    key: ValueKey('new_entry'),
                    child: Text(
                      "Add new item",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              );
            }

            // Sort them
            _productList.sort((a, b) => (a.positionInCategory ?? 0)
                .compareTo(b.positionInCategory ?? 0));

            // We have to check that all products do have a Position in Category, otherwise, we have to assign one
            final bool productsHaveNoPosition =
                _productList.any((x) => x.positionInCategory != null);

            // If all of them are unsorted, which means that this code runs for the first time,
            // assign positions
            if (productsHaveNoPosition) {
              int i = 0;
              for (var product in _productList) {
                product.positionInCategory = i;
                i++;
              }

              // Update Products (Fire and Forget)
              bloc.updateProducts(_productList);
            }

            return ReorderableListView(
                header: Table(
                  key: ValueKey('header'),
                  border: TableBorder.all(
                    color: const Color(0xff1d1f20),
                  ),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      children: [
                        tableHeader("Pictures", isHeader: true),
                        tableHeader("Name", isHeader: true),
                        tableHeader("Description", isHeader: true),
                        tableHeader("Price", isHeader: true),
                        tableHeader("Access", isHeader: true),
                      ],
                    ),
                  ],
                ),
                onReorder: (int oldIndex, int newIndex) {
                  // In order to avoid moving the object under the plus button
                  if (newIndex > _productList.length) return;

                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final Product item = _productList.removeAt(oldIndex);
                  _productList.insert(newIndex, item);

                  // Update position for all products
                  int i = 0;
                  for (var product in _productList) {
                    product.positionInCategory = i;
                    i++;
                  }

                  // Update products in firestore and update UI
                  bloc
                      .updateProducts(_productList)
                      .then((value) => setState(() {
                            _productList = _productList;
                          }));
                },
                children: [
                  ..._productList
                      .map((pro) => Table(
                              border: TableBorder.all(
                                color: const Color(0xff1d1f20),
                              ),
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              key: ValueKey(pro),
                              children: [
                                TableRow(children: [
                                  _buildProductImage(
                                      context, categories, categoryId, pro),
                                  TableRowInkWell(
                                    onTap: () => openProductOptionsDialog(
                                      context,
                                      categories: categories,
                                      categoryId: categoryId,
                                      pro: pro,
                                    ),
                                    child: tableHeader(
                                      pro.name,
                                    ),
                                  ),
                                  TableRowInkWell(
                                    onTap: () => openProductOptionsDialog(
                                      context,
                                      categories: categories,
                                      categoryId: categoryId,
                                      pro: pro,
                                    ),
                                    child: tableHeader(pro.description),
                                  ),
                                  TableRowInkWell(
                                    onTap: () => openProductOptionsDialog(
                                      context,
                                      categories: categories,
                                      categoryId: categoryId,
                                      pro: pro,
                                    ),
                                    child: tableHeader("\$${pro.price}"),
                                  ),
                                  _buildAccessStatus(context, pro),
                                ]),
                              ]))
                      .toList(),
                  buildAddNewEntry(
                    context,
                    categoryId: categoryId,
                    categories: categories,
                  ),
                  const Center(
                    key: ValueKey('new_entry'),
                    child: Text(
                      "Add new item",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ]);
          },
        ),
      ),
    );
  }

  Widget _buildAccessStatus(BuildContext context, Product pro) {
    return IconButton(
      onPressed: () async {
        await showCupertinoModalPopup(
          context: context,
          builder: (context) => MultiProvider(
            providers: [
              Provider.value(value: userSession),
              Provider.value(value: bloc),
            ],
            child: DeactivateActionSheet(productResult: pro),
          ),
        );
        setState(() {});
      },
      icon: Icon(
        Icons.circle,
        color: pro.enabled ? Colors.green : Colors.red,
        size: 3.w,
      ),
    );
  }

  Widget _buildProductImage(BuildContext context,
      List<ProductCategory> categories, String categoryId, Product pro) {
    return TableRowInkWell(
      onTap: () => openProductOptionsDialog(
        context,
        categories: categories,
        categoryId: categoryId,
        pro: pro,
      ),
      child: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(2.w),
          child: CachedNetworkImage(
            width: 26,
            height: 36,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.low,
            imageUrl: pro.image,
            errorWidget: (context, url, error) {
              return Center(
                  child: Text(
                error.toString(),
                style: const TextStyle(color: Colors.red),
              ));
            },
            placeholder: (context, url) {
              return const Center(
                child: SizedBox(
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void openProductOptionsDialog(
    BuildContext context, {
    required Product pro,
    required List<ProductCategory> categories,
    required String categoryId,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => MultiProvider(
        providers: [
          Provider.value(value: userSession),
          Provider.value(value: bloc),
        ],
        child: ProductOptionsSheet(
          product: pro,
          categories: categories,
          currentCategoryId: categoryId,
        ),
      ),
    );
  }

  Widget buildAddNewEntry(
    BuildContext context, {
    required String categoryId,
    required List<ProductCategory> categories,
  }) {
    return Padding(
      key: ValueKey('buildAddNewEntry'),
      padding: EdgeInsets.all(2.w),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return MultiProvider(
                providers: [
                  Provider.value(value: userSession),
                  Provider.value(value: bloc),
                ],
                child: AddOrEditProductDialog(
                  category: categoryId,
                  availableCategories: categories,
                ),
              );
            },
          );
        },
        child: CircleAvatar(
          radius: 5.w,
          backgroundColor: const Color(0xff2f3032),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildSearchOptions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 50.w,
        height: 5.h,
        child: TextFormField(
          controller: searchC,
          cursorColor: Colors.white,
          maxLines: 1,
          style: const TextStyle(color: Colors.white),
          onChanged: (v) {
            _debounce(() {
              search();
              setState(() {});
            });
          },
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            hintText: "Search text",
            hintStyle: const TextStyle(
              color: Color(0xffb5b6b8),
            ),
            contentPadding: EdgeInsets.only(top: 1.w, left: 3.w),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(5.h),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(5.h),
            ),
          ),
        ),
      ),
    );
  }

  Widget tableHeader(
    String data, {
    bool isHeader = false,
  }) {
    var text = Text(
      data.toString(),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: isHeader ? 12 : 10,
        fontWeight: isHeader ? FontWeight.bold : FontWeight.w300,
        color: Colors.white,
      ),
    );
    return isHeader
        ? Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
            child: text,
          )
        : text;
  }

  void search() async {
    final searchText = searchC.text;
    if (searchText.isNotEmpty) {
      final userSession = context.read<FirebaseUser>();
      filteredProducts = await bloc.searchProducts(userSession.uid, searchText);
    }
  }
}

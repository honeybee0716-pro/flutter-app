import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project1/common/models/product.dart';
import 'package:project1/menu_management/blocs/table_layout_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class Trash extends StatefulWidget {
  final int? previousTab;
  const Trash({Key? key, this.previousTab}) : super(key: key);

  @override
  State<Trash> createState() => _TrashState();
}

class _TrashState extends State<Trash> {
  late final TableLayoutBloc bloc = context.read<TableLayoutBloc>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: 3.w),
        Container(
          color: const Color(0xff1d1f20),
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: const Text(
              "Trash",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        buildDataTable(),
      ]),
    );
  }

  Widget buildDataTable() {
    return StreamBuilder<List<Product>>(
        stream: bloc.streamDeletedProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }
          final products = snapshot.data!;
          if (products.isEmpty) {
            return const Center(
              child: Text(
                "Trash is Empty",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.only(top: 2.w, bottom: 2.w),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildTableHeaders(),
                  buildProductsList(products),
                ],
              ),
            ),
          );
        });
  }

  Widget buildProductsList(List<Product> products) {
    return Column(
        children: products
            .map(
              (e) => Column(
                children: [
                  SizedBox(
                      height: 6.h,
                      width: double.infinity,
                      child: Row(
                        children: [
                          divider(),
                          tableHeader(e.image, 13.w, isPicture: true),
                          divider(),
                          tableHeader(e.name, 12.w),
                          divider(),
                          tableHeader(e.description, 17.w),
                          divider(),
                          tableHeader("\$${e.price}", 9.5.w),
                          divider(),
                          tableHeader('', 12.5.w),
                          divider(),
                          tableHeader(e.views, 12.w),
                          divider(),
                          tableHeader(
                            Icons.circle,
                            12.w,
                            isIcon: true,
                          ),
                          divider(),
                          InkWell(
                            onTap: () {
                              e.deleted = false;
                              bloc.softDeleteProduct(e);
                            },
                            child: tableHeader("Trash out", 8.w),
                          ),
                          divider(),
                        ],
                      )),
                  const Divider(
                    thickness: 2,
                    height: 1,
                    color: Color(0xff242527),
                  ),
                ],
              ),
            )
            .toList());
  }

  Widget buildTableHeaders() {
    return Container(
        color: const Color(0xff242527),
        height: 6.h,
        width: double.infinity,
        child: Row(
          children: [
            tableHeader("Pictures", 13.w),
            divider(),
            tableHeader("Name", 12.w),
            divider(),
            tableHeader("Description", 17.w),
            divider(),
            tableHeader("price", 9.5.w),
            divider(),
            tableHeader("Filters", 12.5.w),
            divider(),
            tableHeader("Time Viewed", 12.w),
            divider(),
            tableHeader("Access", 12.w),
            divider(),
            tableHeader(" ", 8.w),
          ],
        ));
  }

  VerticalDivider divider({Color c = const Color(0xff1d1f20)}) {
    return VerticalDivider(
      width: 0,
      thickness: 1,
      color: c,
    );
  }

  Widget tableHeader(dynamic data, double width,
      {bool isIcon = false, bool isPicture = false}) {
    return SizedBox(
      width: width,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(.8.w),
          child: isIcon
              ? Icon(data, color: Colors.red, size: 4.w)
              : isPicture
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(2.w),
                      child: kIsWeb
                          ? Image.network(
                              data,
                              width: 10.w,
                              height: 5.h,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.low,
                            )
                          : CachedNetworkImage(
                              width: 10.w,
                              height: 5.h,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.low,
                              imageUrl: data,
                              errorWidget: (context, url, error) {
                                return Center(
                                  child: Text(
                                    error.toString(),
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              },
                              placeholder: (context, url) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                    )
                  : Text(
                      data.toString(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(fontSize: 7.5.sp, color: Colors.white),
                    ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project1/common/models/guest.dart';
import 'package:project1/common/style/mynuu_colors.dart';
import 'package:project1/menu_management/blocs/table_layout_bloc.dart';
import 'package:project1/menu_management/pages/guest_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class GuestsTableScreen extends StatefulWidget {
  const GuestsTableScreen({Key? key}) : super(key: key);

  @override
  State<GuestsTableScreen> createState() => _GuestsTableScreenState();
}

class _GuestsTableScreenState extends State<GuestsTableScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TableLayoutBloc bloc = context.read<TableLayoutBloc>();
    return Container(
      color: const Color(0xFF0F0F0F),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          const SizedBox(height: 10),
          buildSearchOptions(context),
          const SizedBox(height: 10),
          _buildTitle(),
          _buildTableHeaders(),
          StreamBuilder<List<Guest>>(
            stream: bloc.streamRestaurantGuests(),
            builder:
                (BuildContext context, AsyncSnapshot<List<Guest>> snapshot) {
              final guests = snapshot.data;
              if (guests == null) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (guests.isEmpty) {
                return const Center(
                  child: Text(
                    "No guests yet",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              return _buildTableBody(guests, context, bloc);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      decoration: const BoxDecoration(
        color: mynuuDarkGrey,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Restaurant guests',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            _buildTodayDateChip()
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeaders() {
    return Table(
      border: TableBorder.all(
        color: const Color(0xff1d1f20),
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          children: [
            tableHeader("Name", isHeader: true),
            tableHeader("Contact", isHeader: true),
            tableHeader("Birthday", isHeader: true),
            tableHeader("First visit", isHeader: true),
            tableHeader("Last visit", isHeader: true),
          ],
        ),
      ],
    );
  }

  Widget _buildTableBody(
      List<Guest> guests, BuildContext context, TableLayoutBloc bloc) {
    return Table(
      border: TableBorder.all(
        color: const Color(0xff1d1f20),
      ),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: guests
          .where((element) => element.name.toLowerCase().contains(
                searchController.text.toLowerCase(),
              ))
          .map(
            (guest) => TableRow(
              children: [
                TableRowInkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Provider.value(
                          value: bloc,
                          child: GuestDetailScreen(
                            guestId: guest.id,
                          ),
                        ),
                      ),
                    );
                  },
                  child: tableHeader(guest.name),
                ),
                TableRowInkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Provider.value(
                          value: bloc,
                          child: GuestDetailScreen(
                            guestId: guest.id,
                          ),
                        ),
                      ),
                    );
                  },
                  child: tableHeader(_getGuestId(guest)),
                ),
                TableRowInkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Provider.value(
                          value: bloc,
                          child: GuestDetailScreen(
                            guestId: guest.id,
                          ),
                        ),
                      ),
                    );
                  },
                  child: tableHeader(guest.birthdate == null
                      ? ''
                      : DateFormat('MMM dd')
                          .format(guest.birthdate!)
                          .toString()),
                ),
                TableRowInkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Provider.value(
                          value: bloc,
                          child: GuestDetailScreen(
                            guestId: guest.id,
                          ),
                        ),
                      ),
                    );
                  },
                  child: tableHeader(
                    DateFormat('dd/MM/yyyy HH:mm:ss').format(
                      guest.firstVisit!.toDate(),
                    ),
                  ),
                ),
                TableRowInkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Provider.value(
                          value: bloc,
                          child: GuestDetailScreen(
                            guestId: guest.id,
                          ),
                        ),
                      ),
                    );
                  },
                  child: tableHeader(
                    DateFormat('dd/MM/yyyy HH:mm:ss').format(
                      guest.lastVisit!.toDate(),
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }

  String _getGuestId(Guest guest) {
    if (guest.email == '') {
      return guest.phone ?? '';
    }
    return guest.email;
  }

  Widget _buildTodayDateChip() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          'Date\n' +
              DateFormat('dd/MM/yyyy').format(
                DateTime.now(),
              ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black,
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
          controller: searchController,
          cursorColor: Colors.white,
          maxLines: 1,
          style: const TextStyle(color: Colors.white),
          onChanged: (v) {
            //search();
            setState(() {});
          },
          decoration: InputDecoration(
            suffixIcon: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            hintText: "Search guest",
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
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: text,
          );
  }
}

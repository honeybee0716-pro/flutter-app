import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project1/authentication/components/footer.dart';
import 'package:project1/common/models/guest.dart';
import 'package:project1/menu_management/blocs/table_layout_bloc.dart';
import 'package:provider/provider.dart';

class GuestDetailScreen extends StatefulWidget {
  const GuestDetailScreen({
    Key? key,
    required this.guestId,
  }) : super(key: key);

  final String guestId;
  @override
  State<GuestDetailScreen> createState() => _GuestDetailScreenState();
}

class _GuestDetailScreenState extends State<GuestDetailScreen> {
  late TableLayoutBloc bloc = context.read<TableLayoutBloc>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.asset(
          'assets/logo-2.png',
          width: 75,
        ),
        centerTitle: false,
      ),
      body: StreamBuilder<Guest>(
          stream: bloc.streamGuestById(widget.guestId),
          builder: (context, snapshot) {
            final guest = snapshot.data;
            if (guest == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            }
            return ListView(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Image.asset(
                  'assets/guest-avatar.png',
                  height: 150,
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    guest.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    _getGuestId(guest),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ),
                if (guest.birthdate != null)
                  Center(
                    child: Text(
                      DateFormat('MMM dd').format(guest.birthdate!).toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                _buildGuestTag(
                    title: 'VIP',
                    icon: 'assets/history.png',
                    value: false,
                    onChanged: (value) {},
                    switchable: false),
                const SizedBox(
                  height: 20,
                ),
                _buildTagsList(guest),
                const SizedBox(
                  height: 24,
                ),
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text(
                        'See past checks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                const Footer(),
                const SizedBox(
                  height: 32,
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }

  String _getGuestId(Guest guest) {
    if (guest.email == '') {
      return guest.phone ?? '';
    }
    return guest.email;
  }

  Column _buildTagsList(Guest guest) {
    return Column(
      children: [
        _buildGuestTag(
          title: 'VIP',
          icon: 'assets/vip.png',
          value: guest.vip,
          onChanged: (value) {
            bloc.updateGuest(guest.copyWith(vip: value));
            setState(() {});
          },
        ),
        const SizedBox(
          height: 24,
        ),
        _buildGuestTag(
          title: 'Blacklist',
          icon: 'assets/black.png',
          value: guest.blacklisted,
          onChanged: (value) {
            bloc.updateGuest(guest.copyWith(blacklisted: value));
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildGuestTag({
    required String title,
    required String icon,
    required bool value,
    required Function(bool) onChanged,
    bool switchable = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: switchable
              ? SwitchListTile(
                  value: value,
                  onChanged: onChanged,
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Image.asset(
                          icon,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListTile(
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 12,
                  ),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Image.asset(
                          icon,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

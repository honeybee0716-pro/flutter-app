import 'package:blur/blur.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:project1/common/blocs/home_bloc.dart';
import 'package:project1/common/components/top_menu_option.dart';
import 'package:project1/common/models/menu.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:provider/provider.dart';

class TopMenu extends StatefulWidget {
  const TopMenu({
    Key? key,
    required this.onClose,
    required this.onMenuSelected,
  }) : super(key: key);
  final VoidCallback onClose;
  final Function(Menu) onMenuSelected;
  @override
  State<TopMenu> createState() => _TopMenuState();
}

class _TopMenuState extends State<TopMenu> {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<HomeBloc>();
    final userSession = context.read<FirebaseUser>();
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBlurBackground(context),
        FutureBuilder<List<Menu>>(
            future: bloc.getMenus(userSession.uid),
            builder: (context, snapshot) {
              final data = snapshot.data;
              if (data == null) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildSwiperMenuOptions(data),
                    _buildCloseModalButton(),
                  ],
                ),
              );
            }),
      ],
    );
  }

  Widget _buildSwiperMenuOptions(List<Menu> data) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 50,
      ),
      child: Swiper(
        scrollDirection: Axis.vertical,
        itemCount: data.length,
        viewportFraction: 0.25,
        loop: data.length > 2 ? true : false,
        scale: 0.2,
        itemBuilder: (context, index) {
          return TopMenuOption(
            child: InkWell(
              onTap: (() {
                widget.onMenuSelected(data[index]);
              }),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data[index].name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCloseModalButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white,
          child: IconButton(
            color: Colors.white,
            onPressed: widget.onClose,
            icon: const Icon(
              Icons.close,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Align _buildBlurBackground(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Blur(
        blurColor: Colors.black,
        child: ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black, Colors.black.withOpacity(0)],
              stops: const [0, .4],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstOut,
          child: Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height,
          ),
        ),
      ),
    );
  }
}

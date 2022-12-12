import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project1/common/blocs/home_bloc.dart';
import 'package:project1/common/components/product_card.dart';
import 'package:project1/common/components/top_menu.dart';
import 'package:project1/common/models/category.dart';
import 'package:project1/common/models/menu.dart';
import 'package:project1/common/models/product.dart';
import 'package:project1/common/models/restaurant.dart';
import 'package:project1/common/models/user_system.dart';
import 'package:project1/common/pages/restaurant_logo.dart';
import 'package:project1/common/utils/debounce.dart';
import 'package:project1/main.dart';
import 'package:project1/menu_management/pages/admin_screen.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:project1/common/services/landing_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.shortUrl, this.firebaseUser})
      : super(key: key);

  final String? shortUrl;
  final FirebaseUser? firebaseUser;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String regards = '';
  HomeBloc homeBloc = HomeBloc();

  bool isThereACategorySelected = false;
  ProductCategory? selectedCategory;
  bool searchMode = false;
  List<Product> filteredProducts = [];
  String filter = '';
  bool showSearchResults = false;

  bool isVisibleTopMenu = false;
  final Debounce _debounce = Debounce(
    const Duration(milliseconds: 100),
  );

  Menu? selectedMenu;

  @override
  void initState() {
    int time = DateTime.now().hour;
    if (time < 12) {
      regards = "Good Morning";
    } else if (time < 18) {
      regards = "Good Afternoon";
    } else {
      regards = "Good Evening";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.firebaseUser != null) {
      return buildWhenFirebaseUserExists(context, widget.firebaseUser!);
    }

    return FutureBuilder<Restaurant>(
      future: context
          .read<CloudFirestoreService>()
          .getRestaurantByShortUrl(widget.shortUrl ?? ''),
      builder: (context, snapshot) {
        final restaurantData = snapshot.data;
        if (restaurantData == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }

        if (restaurantData.id == 'notFound') {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo-2.png',
                    filterQuality: FilterQuality.high,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Verify your url, it seems like it is not found!',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return buildWhenFirebaseUserExists(
          context,
          FirebaseUser(
              uid: restaurantData.id,
              email: restaurantData.email,
              isVerified: true,
              providerId: ''),
        );
      },
    );
  }

  Widget buildWhenFirebaseUserExists(
      BuildContext context, FirebaseUser firebaseUser) {
    return StreamBuilder<Restaurant>(
        stream: homeBloc.streamRestaurantById(
          firebaseUser.uid,
        ),
        initialData: Restaurant.empty(),
        builder: (context, snapshot) {
          final restaurant = snapshot.data;
          if (restaurant == null) {
            return _buildLoadindIndicator();
          }
          return Scaffold(
            backgroundColor: restaurant.guestCheckInColor,
            body: Stack(
              children: [
                _buildMainBody(restaurant, context, firebaseUser),
                _buildTopNavigationMenu(context, firebaseUser),
              ],
            ),
          );
        });
  }

  Widget _buildLoadindIndicator() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: const [
          Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavigationMenu(
      BuildContext context, FirebaseUser firebaseUser) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: isVisibleTopMenu ? MediaQuery.of(context).size.height : 0,
      child: AnimatedOpacity(
        opacity: isVisibleTopMenu ? 1 : 0,
        duration: const Duration(milliseconds: 500),
        child: MultiProvider(
          providers: [
            Provider.value(value: firebaseUser),
            Provider.value(value: homeBloc),
          ],
          child: TopMenu(
            onClose: () {
              setState(
                () {
                  isVisibleTopMenu = false;
                },
              );
            },
            onMenuSelected: (menu) {
              setState(() {
                selectedMenu = menu;
                isVisibleTopMenu = false;
                searchByMenuId(menu.id, firebaseUser);
              });
            },
          ),
        ),
      ),
    );
  }

  SafeArea _buildMainBody(
      Restaurant restaurant, BuildContext context, FirebaseUser firebaseUser) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 0,
              maxHeight: kIsWeb ? 200 : 160.0,
              child: MultiProvider(
                providers: [
                  Provider.value(value: firebaseUser),
                  Provider.value(value: homeBloc),
                ],
                child: RestaurantLogo(
                  backgroundColor: restaurant.guestCheckInColor,
                ),
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 80.0,
              maxHeight: 80.0,
              child:
                  _buildHomeOptions(restaurant.guestCheckInColor, firebaseUser),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              minHeight: 60.0,
              maxHeight: 60.0,
              child: buildCategoriesFilter(
                  restaurant.guestCheckInColor, firebaseUser),
            ),
          ),
          showSearchResults
              ? _buildSearchResults(firebaseUser)
              : isThereACategorySelected
                  ? SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          buildStreamProductCategoryList(
                              selectedCategory!, firebaseUser),
                        ],
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          StreamBuilder<List<ProductCategory>>(
                            stream: homeBloc.streamCategories(
                              firebaseUser.uid,
                              limit: 10,
                            ),
                            builder: (BuildContext context, snapshot) {
                              var categories = snapshot.data ?? [];
                              return Column(
                                children: categories
                                    .map(
                                      (category) =>
                                          buildStreamProductCategoryList(
                                              category, firebaseUser),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(FirebaseUser firebaseUser) {
    if (filteredProducts.isEmpty) {
      return _buildNoResults();
    }
    List<String> filteredCategories = [];

    for (final pro in filteredProducts) {
      if (!filteredCategories.contains(pro.categoryId)) {
        filteredCategories.add(pro.categoryId);
      }
    }
    return StreamBuilder<List<ProductCategory>>(
      stream: homeBloc.streamCategories(firebaseUser.uid),
      builder: (context, snapshot) {
        final categories = snapshot.data;
        if (categories == null) {
          return const SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildListDelegate(
            [
              Column(
                children: categories
                    .where(
                      (element) => filteredCategories.contains(element.id),
                    )
                    .map(
                      (category) => _buildProductsByCategory(
                          category,
                          filteredProducts
                              .where(
                                (element) => element.categoryId == category.id,
                              )
                              .toList(),
                          firebaseUser),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoResults() {
    return SliverToBoxAdapter(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              height: 175,
            ),
            Text(
              '(0) Results',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeOptions(Color backgroundColor, FirebaseUser firebaseUser) {
    return Container(
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.only(
          left: searchMode ? 0 : 20,
          right: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRegardSearchTextFieldSwitch(firebaseUser),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (searchMode) {
                      searchByKeyword(firebaseUser);
                    } else {
                      setState(() {
                        searchMode = true;
                      });
                    }
                  },
                  icon: const Icon(Icons.search),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isVisibleTopMenu = !isVisibleTopMenu;
                    });
                  },
                  icon: const Icon(
                    Icons.filter_list_sharp,
                    color: Colors.white,
                  ),
                ),
                if (!kIsWeb) _buildAdminOptions(firebaseUser),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminOptions(FirebaseUser firebaseUser) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () async {
            final currentRestaurant =
                await homeBloc.getRestaurantById(firebaseUser.uid);
            Share.share(
                "https://menu.mynuutheapp.com/#/${currentRestaurant.shortUrl}");
          },
          icon: const Icon(CupertinoIcons.share),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            //  backgroundColor: mynuuPrimary,
            textStyle: const TextStyle(fontSize: 20),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context2) => Provider.value(
                  value: firebaseUser,
                  child: const AdminScreen(),
                ),
              ),
            );
          },
          child: const Text(
            '86',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRegardSearchTextFieldSwitch(FirebaseUser firebaseUser) {
    return Expanded(
      child: searchMode
          ? Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: TextField(
                autofocus: true,
                cursorColor: Colors.white,
                style: const TextStyle(
                  color: Colors.white,
                ),
                onChanged: (value) {
                  _debounce(() {
                    filter = value;
                    searchByKeyword(firebaseUser);
                    setState(() {});
                  });
                },
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(
                        () {
                          searchMode = false;
                          showSearchResults = false;
                          filter = '';
                          filteredProducts = [];
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                  hintText: 'Search',
                  hintStyle: const TextStyle(
                    color: Colors.white,
                  ),
                  border: InputBorder.none,
                ),
              ),
            )
          : Text(
              regards.toString(),
              style: const TextStyle(
                fontFamily: kIsWeb ? 'Metropolis' : null,
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget buildCategoriesFilter(
      Color backgroundColor, FirebaseUser firebaseUser) {
    return Container(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          top: 4,
          bottom: 8,
        ),
        child: StreamBuilder<List<ProductCategory>>(
          stream: homeBloc.streamCategories(
            firebaseUser.uid,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.white));
            }
            return SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: snapshot.data!
                    .map(
                      (index) => buildCategoryOption(index),
                    )
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildCategoryOption(ProductCategory index) {
    return InkWell(
      onTap: () {
        // SELECT FILTER BY CATEORY
        setState(() {
          if (selectedCategory?.id == index.id) {
            isThereACategorySelected = false;
          } else {
            isThereACategorySelected = true;
          }
          selectedCategory = index;
          if (!isThereACategorySelected) {
            selectedCategory = null;
          }
          filteredProducts = [];
          showSearchResults = false;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: selectedCategory?.id == index.id
                ? Colors.grey
                : const Color(0xff2C2C2C),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                index.name,
                style: const TextStyle(
                    fontFamily: kIsWeb ? 'Metropolis' : null,
                    color: Colors.white,
                    fontSize: kIsWeb ? 22 : 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStreamProductCategoryList(
      ProductCategory category, FirebaseUser firebaseUser) {
    return StreamBuilder<List<Product>>(
      stream: homeBloc.streamProductByCategory(category.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: SizedBox(),
          );
        }
        final products = snapshot.data!;
        if (products.isEmpty) {
          return isThereACategorySelected
              ? Column(
                  children: const [
                    SizedBox(
                      height: 175,
                    ),
                    Text(
                      '(0) Products',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
              : const SizedBox();
        }
        // Sort them
        products.sort((a, b) =>
            (a.positionInCategory ?? 0).compareTo(b.positionInCategory ?? 0));
        return _buildProductsByCategory(category, products, firebaseUser);
      },
    );
  }

  Padding _buildProductsByCategory(ProductCategory category,
      List<Product> products, FirebaseUser firebaseUser) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 4.h,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: buildCategoryTitle(category.name),
          ),
          SizedBox(
            height: 250,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              children: products
                  .map(
                    (index) => Provider.value(
                      value: firebaseUser,
                      child: ProductCard(
                        product: index,
                        shortUrl: widget.shortUrl!,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        left: 10,
        bottom: 10,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontFamily: kIsWeb ? 'Metropolis' : null,
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void searchByKeyword(FirebaseUser firebaseUser) async {
    final searchText = filter;
    if (searchText.isNotEmpty) {
      filteredProducts =
          await homeBloc.searchProducts(firebaseUser.uid, searchText);
      if (!recentSearches.contains(filter)) {
        recentSearches.add(filter);
      }
      setState(() {
        showSearchResults = true;
        selectedCategory = null;
      });
    }
  }

  void searchByMenuId(String menuId, FirebaseUser firebaseUser) async {
    filteredProducts =
        await homeBloc.searchProductsByMenuId(firebaseUser.uid, menuId);
    setState(() {
      showSearchResults = true;
      selectedCategory = null;
    });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

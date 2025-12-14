// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});
  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: []),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: Colors.teal.withOpacity(0.5),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 15, 181, 143), Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text('Settings')),
              const PopupMenuItem(value: 2, child: Text('About')),
            ],
            onSelected: (value) {
              // Handle menu item selection
              if (value == 1) {
                Navigator.pushNamed(context, '/settings');
              } else if (value == 2) {
                // Navigate to About
              }
            },
          ),
        ],
      ),
      drawer: NavigationDrawer(
        onDestinationSelected: (value) => {
          setState(() {
            _selectedIndex = value;
          }),
          Navigator.pop(context),
        },

        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Colors.tealAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.green),
                ),
                SizedBox(height: 8),
                Text(
                  'John Doe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'john.doe@example.com',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          NavigationDrawerDestination(
            icon: Icon(Icons.home),
            label: Text('Home'),
            selectedIcon: Icon(Icons.home_filled),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.settings),
            label: Text('Settings'),
            selectedIcon: Icon(Icons.settings),
          ),
          Divider(),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          ListTile(
            leading: const CircleAvatar(child: Text('1')),
            title: const Text('Item'),
            subtitle: const Text('cookies and more'),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const CircleAvatar(child: Text('2')),
            title: const Text('Item'),
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const CircleAvatar(child: Text('3')),
            title: const Text('Item'),
          ),
        ],
      ),

      /*drawer: NavigationDrawer(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (value) => {
            setState(() {
              _selectedIndex = value;
            })
          },
          Navigator.pop(  context);},
          
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.teal,
                ),
                child: Text('Menu',style: TextStyle(color: Colors.white),)),
              NavigationDrawerDestination(
                icon: Icon(Icons.home),
                label: Text('Home'),
                selectedIcon: Icon(Icons.home_filled),
              ),
              NavigationDrawerDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
                selectedIcon: Icon(Icons.settings),
  ``              ),
            ],

      ),*/

      /* bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),*/
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:royal_clothes/views/SettingsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SidebarMenu extends StatefulWidget {
  final Function(String)? onMenuTap;

  SidebarMenu({this.onMenuTap});

  @override
  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  TimeZoneOption _timeZone = TimeZoneOption.WIB;
  final SettingsService _settingsService = SettingsService();
  late DateTime _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadTimeZone();
    _currentTime = DateTime.now().toUtc();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _currentTime = DateTime.now().toUtc();
      });
    });
  }

  Future<void> _loadTimeZone() async {
    TimeZoneOption zone = await _settingsService.loadTimeZone();
    setState(() {
      _timeZone = zone;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  DateTime convertToTimeZone(DateTime utcTime, TimeZoneOption zone) {
    // implementasi konversi zona waktu. 
    switch (zone) {
      case TimeZoneOption.WIB:
        return utcTime.add(Duration(hours: 7));
      case TimeZoneOption.WITA:
        return utcTime.add(Duration(hours: 8));
      case TimeZoneOption.WIT:
        return utcTime.add(Duration(hours: 9));
        case TimeZoneOption.London:
      return utcTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime localTime = convertToTimeZone(_currentTime, _timeZone);
    String formattedTime =
        "${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}:${localTime.second.toString().padLeft(2, '0')}";

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD700), Color.fromARGB(255, 118, 114, 114)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text(
                    //   'Jam Sekarang',
                    //   style: TextStyle(color: Colors.white, fontSize: 24),
                    // ),
                    // SizedBox(height: 10),
                    Text(
                      // 'Waktu: $formattedTime\nZona:${_timeZone.toString().split('.').last}',
                      '$formattedTime',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onMenuTap?.call("home");
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  onTap: () async {
                    Navigator.pop(context);
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    String? email = prefs.getString('userEmail');

                    if (email != null) {
                      Navigator.pushNamed(context, '/profile', arguments: email);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Email tidak ditemukan!")),
                      );
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('Favorite'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onMenuTap?.call("favorite");
                    Navigator.pushNamed(context, '/favorite');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.feedback),
                  title: Text('Kesan & Saran'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onMenuTap?.call("kesan_saran");
                    Navigator.pushNamed(context, '/kesan_saran');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Setting'),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onMenuTap?.call("SettingsPage");
                    Navigator.pushNamed(context, '/SettingsPage');
                  },
                ),
              ],
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.redAccent),
            title: Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              Navigator.pop(context);

              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}

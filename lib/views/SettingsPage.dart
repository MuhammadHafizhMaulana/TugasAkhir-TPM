import 'package:flutter/material.dart';
import 'package:royal_clothes/db/database_helper.dart';
import 'package:royal_clothes/views/appBar_page.dart';
import 'package:royal_clothes/views/sidebar_menu_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

enum TimeZoneOption { WIB, WITA, WIT, London }
enum CurrencyOption { IDR, USD, EUR }

class SettingsService {
  static const String keyTimeZone = 'selected_time_zone';
  static const String keyCurrency = 'selected_currency';

  Future<TimeZoneOption> loadTimeZone() async {
    final prefs = await SharedPreferences.getInstance();
    String? tzString = prefs.getString(keyTimeZone);
    if (tzString != null) {
      return TimeZoneOption.values.firstWhere(
        (e) => e.toString() == tzString,
        orElse: () => TimeZoneOption.WIB,
      );
    }
    return TimeZoneOption.WIB;
  }

  Future<void> saveTimeZone(TimeZoneOption zone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyTimeZone, zone.toString());
  }

  Future<void> saveCurrency(CurrencyOption currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(keyCurrency, currency.index);
  }

  Future<CurrencyOption> loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    int? index = prefs.getInt(keyCurrency);
    if (index != null && index >= 0 && index < CurrencyOption.values.length) {
      return CurrencyOption.values[index];
    }
    return CurrencyOption.IDR;
  }
}

DateTime convertToTimeZone(DateTime utcTime, TimeZoneOption zone) {
  switch (zone) {
    case TimeZoneOption.WIB:
      return utcTime.add(const Duration(hours: 7));
    case TimeZoneOption.WITA:
      return utcTime.add(const Duration(hours: 8));
    case TimeZoneOption.WIT:
      return utcTime.add(const Duration(hours: 9));
    case TimeZoneOption.London:
      return utcTime;
  }
}

class SettingsPage extends StatefulWidget {
  
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TimeZoneOption? _selectedTimeZone;
  CurrencyOption? _selectedCurrency;
  final SettingsService _settingsService = SettingsService();

   int? userId;

  String _currentAddress = 'Alamat belum tersedia';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    TimeZoneOption tz = await _settingsService.loadTimeZone();
    CurrencyOption curr = await _settingsService.loadCurrency();
    setState(() {
      _selectedTimeZone = tz;
      _selectedCurrency = curr;
    });
  }

  void _onTimeZoneChanged(TimeZoneOption? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedTimeZone = newValue;
      });
      _settingsService.saveTimeZone(newValue);
    }
  }

  void _onCurrencyChanged(CurrencyOption? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedCurrency = newValue;
      });
      _settingsService.saveCurrency(newValue);
    }
  }

  Future<void> _getCurrentLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt('userId');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID belum tersedia')),
      );
      return;
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layanan lokasi tidak aktif.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin lokasi ditolak')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak permanen.')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String alamat =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.postalCode}';

        setState(() {
          _currentAddress = alamat;
        });

        // Simpan alamat ke database pakai db_helper dan userId dari SharedPreferences
        await DBHelper().upsertAlamat(userId, alamat);


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alamat berhasil disimpan.')),
        );
      } else {
        setState(() {
          _currentAddress = 'Alamat tidak ditemukan.';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil lokasi: $e')),
      );
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF121212),
    appBar: AppbarPage(title: 'Pengaturan'),
    drawer: SidebarMenu(),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingCard(
            title: "Zona Waktu",
            child: DropdownButton<TimeZoneOption>(
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white),
              value: _selectedTimeZone,
              isExpanded: true,
              items: TimeZoneOption.values.map((tz) {
                return DropdownMenuItem(
                  value: tz,
                  child: Text(tz.toString().split('.').last),
                );
              }).toList(),
              onChanged: _onTimeZoneChanged,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: "Mata Uang",
            child: DropdownButton<CurrencyOption>(
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white),
              value: _selectedCurrency,
              isExpanded: true,
              items: CurrencyOption.values.map((curr) {
                return DropdownMenuItem(
                  value: curr,
                  child: Text(curr.toString().split('.').last),
                );
              }).toList(),
              onChanged: _onCurrencyChanged,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingCard(
            title: "Alamat Sekarang",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentAddress,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  icon: const Icon(Icons.location_on),
                  label: const Text("Ambil Lokasi Sekarang"),
                  onPressed: _getCurrentLocation,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSettingCard({required String title, required Widget child}) {
  return Card(
    color: const Color(0xFF1E1E1E),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

}

String formatPrice(double priceInUSD, CurrencyOption currency) {
  switch (currency) {
    case CurrencyOption.IDR:
      double rate = 16000;
      double priceIDR = priceInUSD * rate;
      final formatter = NumberFormat.currency(
          locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
      return formatter.format(priceIDR);

    case CurrencyOption.EUR:
      double rate = 0.93;
      double priceEUR = priceInUSD * rate;
      return "€${priceEUR.toStringAsFixed(2)}";

    case CurrencyOption.USD:
    default:
      return "\$${priceInUSD.toStringAsFixed(2)}";
  }
}

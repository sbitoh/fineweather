import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import '../services/i18n.dart';

class CitySearchDelegate extends SearchDelegate<CityItem?> {
  @override
  String get searchFieldLabel => I18n.searchCityHint;

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF1E293B),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF334155),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: Colors.white70),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return Container(
        color: const Color(0xFF1E293B),
        child: Center(
          child: Text(
            I18n.searchGuide,
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ),
      );
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<CityItem>>(
      future: WeatherService.searchCities(query.trim()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: const Color(0xFF1E293B),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.lightBlueAccent),
            ),
          );
        }

        final list = snapshot.data ?? [];
        if (list.isEmpty) {
          return Container(
            color: const Color(0xFF1E293B),
            child: Center(
              child: Text(
                I18n.noCityFound,
                style: const TextStyle(color: Colors.white38, fontSize: 14),
              ),
            ),
          );
        }

        return Container(
          color: const Color(0xFF1E293B),
          child: ListView.separated(
            itemCount: list.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.white10, height: 1),
            itemBuilder: (context, index) {
              final city = list[index];
              return ListTile(
                leading: const Icon(Icons.location_on_outlined,
                    color: Colors.lightBlueAccent),
                title: Text(
                  city.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  city.adminArea,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                trailing: Text(
                  '${city.latitude.toStringAsFixed(2)}, ${city.longitude.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white30, fontSize: 11),
                ),
                onTap: () => close(context, city),
              );
            },
          ),
        );
      },
    );
  }
}

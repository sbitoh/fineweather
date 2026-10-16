import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../services/weather_repository.dart';
import '../services/i18n.dart';
import 'city_search_delegate.dart';

class CityManagerSheet extends StatefulWidget {
  final List<CityItem> currentCities;
  final int selectedIndex;
  final Function(int) onSelectCity;
  final VoidCallback onCitiesChanged;

  const CityManagerSheet({
    super.key,
    required this.currentCities,
    required this.selectedIndex,
    required this.onSelectCity,
    required this.onCitiesChanged,
  });

  @override
  State<CityManagerSheet> createState() => _CityManagerSheetState();
}

class _CityManagerSheetState extends State<CityManagerSheet> {
  late List<CityItem> _cities;

  @override
  void initState() {
    super.initState();
    _cities = List.from(widget.currentCities);
  }

  void _addNewCity() async {
    final newCity = await showSearch<CityItem?>(
      context: context,
      delegate: CitySearchDelegate(),
    );

    if (newCity != null) {
      // 避免重复添加
      final exists = _cities.any((c) =>
          c.name == newCity.name &&
          (c.latitude - newCity.latitude).abs() < 0.05);
      if (!exists) {
        setState(() {
          _cities.add(newCity);
        });
        await WeatherRepository.saveCities(_cities);
        widget.onCitiesChanged();
        widget.onSelectCity(_cities.length - 1);
        if (mounted) Navigator.pop(context);
      }
    }
  }

  void _removeCity(int index) async {
    if (_cities.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(I18n.keepOneCity)),
      );
      return;
    }
    setState(() {
      _cities.removeAt(index);
    });
    await WeatherRepository.saveCities(_cities);
    widget.onCitiesChanged();
    widget.onSelectCity(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                I18n.cityManager,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline,
                    color: Colors.lightBlueAccent, size: 28),
                onPressed: _addNewCity,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _cities.length,
            itemBuilder: (context, index) {
              final c = _cities[index];
              final isCurrent = index == widget.selectedIndex;
              final isLoc = index == 0 && c.adminArea.contains('定位');
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? Colors.lightBlueAccent.withOpacity(0.15)
                      : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCurrent
                        ? Colors.lightBlueAccent.withOpacity(0.4)
                        : Colors.white10,
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    isLoc ? Icons.my_location : Icons.location_on,
                    color: isCurrent ? Colors.lightBlueAccent : Colors.white54,
                  ),
                  title: Row(
                    children: [
                      Text(
                        c.name,
                        style: TextStyle(
                          color: isCurrent ? Colors.lightBlueAccent : Colors.white,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isLoc) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.lightBlueAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            I18n.currentLoc,
                            style: const TextStyle(fontSize: 10, color: Colors.lightBlueAccent),
                          ),
                        ),
                      ]
                    ],
                  ),
                  subtitle: Text(
                    c.adminArea,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.white38, size: 20),
                    onPressed: () => _removeCity(index),
                  ),
                  onTap: () {
                    widget.onSelectCity(index);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

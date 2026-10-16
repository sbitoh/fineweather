import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/weather_data.dart';
import 'services/weather_repository.dart';
import 'views/city_manager_sheet.dart';
import 'widgets/glass_card.dart';
import 'widgets/weather_visual.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const FineWeatherApp());
}

class FineWeatherApp extends StatelessWidget {
  const FineWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '初晴天气',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        fontFamily: 'sans-serif',
      ),
      home: const WeatherHomeScreen(),
    );
  }
}

class WeatherHomeScreen extends StatefulWidget {
  const WeatherHomeScreen({super.key});

  @override
  State<WeatherHomeScreen> createState() => _WeatherHomeScreenState();
}

class _WeatherHomeScreenState extends State<WeatherHomeScreen> {
  List<CityItem> _cities = [];
  int _currentCityIndex = 0;
  WeatherData? _weatherData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cities = await WeatherRepository.getSavedCities();
      setState(() {
        _cities = cities;
        if (_currentCityIndex >= cities.length) {
          _currentCityIndex = 0;
        }
      });

      if (_cities.isNotEmpty) {
        await _fetchWeatherForCurrentCity();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '加载城市失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchWeatherForCurrentCity({bool forceRefresh = false}) async {
    if (_cities.isEmpty) return;
    final city = _cities[_currentCityIndex];

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data =
          await WeatherRepository.getWeather(city, forceRefresh: forceRefresh);
      setState(() {
        _weatherData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '天气获取失败，请下拉重试\n$e';
        _isLoading = false;
      });
    }
  }

  void _openCityManager() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CityManagerSheet(
        currentCities: _cities,
        selectedIndex: _currentCityIndex,
        onSelectCity: (index) {
          setState(() {
            _currentCityIndex = index;
          });
          _fetchWeatherForCurrentCity();
        },
        onCitiesChanged: () async {
          final updated = await WeatherRepository.getSavedCities();
          setState(() {
            _cities = updated;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wCode = _weatherData?.weatherCode ?? 2;
    final isDay = _weatherData?.isDay ?? true;
    final bgGradient = WeatherVisual.getGradient(wCode, isDay);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildTopNav(),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.lightBlueAccent,
                        ),
                      )
                    : _errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.cloud_off,
                                      size: 54, color: Colors.white38),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _fetchWeatherForCurrentCity(forceRefresh: true),
                                    child: const Text('点击重试'),
                                  )
                                ],
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            color: Colors.lightBlueAccent,
                            backgroundColor: const Color(0xFF1E293B),
                            onRefresh: () =>
                                _fetchWeatherForCurrentCity(forceRefresh: true),
                            child: ListView(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 8, 20, 40),
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              children: [
                                _buildHeroSection(),
                                _buildHourlySection(),
                                _buildDailySection(),
                                _buildBentoSection(),
                                _buildFooter(),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNav() {
    final cityName = _cities.isNotEmpty
        ? _cities[_currentCityIndex].name
        : '正在加载...';
    final adminArea = _cities.isNotEmpty
        ? _cities[_currentCityIndex].adminArea
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _openCityManager,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.lightBlueAccent, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      cityName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down,
                        color: Colors.white70, size: 24),
                  ],
                ),
                if (adminArea.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, top: 2),
                    child: Text(
                      adminArea,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.format_list_bulleted,
                color: Colors.white, size: 26),
            onPressed: _openCityManager,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    final data = _weatherData!;
    final emoji = WeatherVisual.getIconEmoji(data.weatherCode);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${data.temperature.round()}',
                style: const TextStyle(
                  fontSize: 104,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  letterSpacing: -4,
                  height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '°C',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$emoji ${data.weatherText}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '空气 优',
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '最高 ${data.tempMax.round()}° · 最低 ${data.tempMin.round()}° · 体感 ${data.apparentTemperature.round()}°',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlySection() {
    final hourly = _weatherData!.hourly;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.white60),
              SizedBox(width: 6),
              Text(
                '逐小时预报 · 24小时',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 85,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: hourly.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: 18),
              itemBuilder: (context, index) {
                final item = hourly[index];
                final icon = WeatherVisual.getIconEmoji(item.weatherCode);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.time,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 12),
                    ),
                    Text(
                      icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text(
                      '${item.temperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySection() {
    final daily = _weatherData!.daily;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today, size: 15, color: Colors.white60),
              SizedBox(width: 6),
              Text(
                '7 天天气预报',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: daily.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.white10, height: 16),
            itemBuilder: (context, index) {
              final d = daily[index];
              final icon = WeatherVisual.getIconEmoji(d.weatherCode);
              return Row(
                children: [
                  SizedBox(
                    width: 75,
                    child: Text(
                      d.date,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                    ),
                  ),
                  SizedBox(
                    width: 90,
                    child: Row(
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            d.weatherText,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          '${d.tempMin.round()}°',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 13),
                        ),
                        Expanded(
                          child: Container(
                            height: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.lightBlueAccent,
                                  Colors.orangeAccent
                                ],
                              ),
                            ),
                          ),
                        ),
                        Text(
                          '${d.tempMax.round()}°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBentoSection() {
    final data = _weatherData!;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildBentoItem('💧 相对湿度', '${data.relativeHumidity}%', '体感舒适微凉'),
        _buildBentoItem(
            '💨 风速风向', '${data.windSpeed.round()} km/h', '微风拂面'),
        _buildBentoItem('☀️ 紫外线指数', '1 最弱', '无需特别防护'),
        _buildBentoItem('👁️ 能见度', '10 km', '视线开阔清晰'),
      ],
    );
  }

  Widget _buildBentoItem(String title, String val, String sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 12)),
          Text(val,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
          Text(sub,
              style:
                  const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final source = _weatherData?.source ?? 'Open-Meteo';

    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '🛡️ 纯净模式 · 零广告 · 零资讯跟踪',
              style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '数据源: $source · 自动双源冗余保障',
            style: const TextStyle(color: Colors.white30, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

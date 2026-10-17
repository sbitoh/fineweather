import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/weather_data.dart';
import 'services/weather_helper.dart';
import 'services/weather_repository.dart';
import 'services/location_service.dart';
import 'services/i18n.dart';
import 'views/city_manager_sheet.dart';
import 'widgets/glass_card.dart';
import 'widgets/weather_visual.dart';

class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = CustomHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const FineWeatherApp());
}

class FineWeatherApp extends StatefulWidget {
  const FineWeatherApp({super.key});

  @override
  State<FineWeatherApp> createState() => _FineWeatherAppState();
}

class _FineWeatherAppState extends State<FineWeatherApp> {
  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString('app_lang') ?? 'zh';
    setState(() {
      I18n.lang = savedLang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: I18n.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFE2E8F0),
        fontFamily: 'sans-serif',
      ),
      home: WeatherHomeScreen(
        currentLang: I18n.lang,
        onLanguageChanged: (newLang) async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('app_lang', newLang);
          setState(() {
            I18n.lang = newLang;
          });
          // 语言切换后立即刷新当前小部件数据，显式传入 newLang
          await WeatherRepository.updateWidgetData(lang: newLang);
        },
      ),
    );
  }
}

class WeatherHomeScreen extends StatefulWidget {
  final String currentLang;
  final Function(String) onLanguageChanged;

  const WeatherHomeScreen({
    super.key,
    required this.currentLang,
    required this.onLanguageChanged,
  });

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
    _initDataAndLocation();
  }

  Future<void> _initDataAndLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cities = await WeatherRepository.getSavedCities();
      _cities = cities;

      // 启动自动定位当前城市（静默异步，有定位则优先插入到首位并展示）
      _tryAutoLocation();

      if (_cities.isNotEmpty) {
        await _fetchWeatherForCurrentCity();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
        _isLoading = false;
      });
    }
  }

  Future<void> _tryAutoLocation() async {
    final locCity = await LocationService.getCurrentCity();
    if (locCity != null && mounted) {
      setState(() {
        // 将定位城市更新或置于首位
        final index = _cities.indexWhere((c) =>
            c.adminArea.contains('定位') ||
            c.adminArea.contains('Location') ||
            c.adminArea.contains('Located') ||
            c.name == locCity.name);
        if (index >= 0) {
          _cities[index] = locCity;
        } else {
          _cities.insert(0, locCity);
        }
        _currentCityIndex = 0;
      });
      await WeatherRepository.saveCities(_cities);
      // 保证立刻同步定位城市名给桌面小部件
      final curCity = _cities[0];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('widget_city', I18n.isEn ? WeatherRepository.toEnglishCityName(curCity.name) : curCity.name);
      _fetchWeatherForCurrentCity();
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
      // 每次主界面获取完天气，强制把最新数据同步给小组件并唤起原生刷新
      await WeatherRepository.syncWidgetData(data);
    } catch (e) {
      setState(() {
        _errorMessage = '${I18n.locateFailed}\n$e';
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

  void _openSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(I18n.settings, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(I18n.language, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('简体中文'),
                  selected: I18n.lang == 'zh',
                  onSelected: (val) {
                    if (val) {
                      widget.onLanguageChanged('zh');
                      Navigator.pop(context);
                      _fetchWeatherForCurrentCity(forceRefresh: true);
                    }
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('English'),
                  selected: I18n.lang == 'en',
                  onSelected: (val) {
                    if (val) {
                      widget.onLanguageChanged('en');
                      Navigator.pop(context);
                      _fetchWeatherForCurrentCity(forceRefresh: true);
                    }
                  },
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 32),
            Text(I18n.about, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(
              I18n.aboutDesc,
              style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
            ),
            const SizedBox(height: 12),
            const Text(
              'FineWeather v0.2.2\nAuthor: sbitoh\nLicense: Apache-2.0',
              style: TextStyle(color: Colors.white30, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(I18n.close, style: const TextStyle(color: Colors.lightBlueAccent)),
          ),
        ],
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
                          color: Colors.white,
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
                                      size: 54, color: Colors.white54),
                                  const SizedBox(height: 16),
                                  Text(
                                    _errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _fetchWeatherForCurrentCity(forceRefresh: true),
                                    child: Text(I18n.retry),
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
        ? I18n.getLocalizedCityName(_cities[_currentCityIndex].name)
        : I18n.locating;
    final isLoc = _cities.isNotEmpty &&
        (_cities[_currentCityIndex].adminArea.contains('定位') ||
         _cities[_currentCityIndex].adminArea.contains('Location') ||
         _cities[_currentCityIndex].adminArea.contains('Located'));
    final adminArea = _cities.isNotEmpty
        ? I18n.getLocalizedAdminArea(_cities[_currentCityIndex].adminArea)
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
                    Icon(isLoc ? Icons.my_location : Icons.location_on,
                        color: Colors.white, size: 20),
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
                          color: Colors.white70, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: Colors.white, size: 24),
                onPressed: _openSettingsDialog,
              ),
              IconButton(
                icon: const Icon(Icons.format_list_bulleted,
                    color: Colors.white, size: 24),
                onPressed: _openCityManager,
              ),
            ],
          )
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
                '$emoji ${WeatherHelper.getWeatherDescription(data.weatherCode, isEn: I18n.isEn)}',
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  I18n.airQuality,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${I18n.high} ${data.tempMax.round()}° · ${I18n.low} ${data.tempMin.round()}° · ${I18n.feelsLike} ${data.apparentTemperature.round()}°',
            style: const TextStyle(color: Colors.white, fontSize: 14),
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
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                I18n.hourlyForecast,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
                final timeDisplay = (index == 0 && item.time != '00:00') ? I18n.now : item.time;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeDisplay,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
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
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 15, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                I18n.dailyForecast,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
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
                const Divider(color: Colors.white12, height: 16),
            itemBuilder: (context, index) {
              final d = daily[index];
              final icon = WeatherVisual.getIconEmoji(d.weatherCode);
    final enWeekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final zhWeekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final isEn = I18n.isEn;
    final dayLabel = isEn
        ? (index == 0
            ? 'Today'
            : index == 1
                ? 'Tomorrow'
                : enWeekdays[(d.weekday - 1).clamp(0, 6)])
        : (index == 0
            ? '今天'
            : index == 1
                ? '明天'
                : zhWeekdays[(d.weekday - 1).clamp(0, 6)]);
    // 提取真实日期数字（如 10/17 或从 d.date 里的 '10/18' 提取）
    String mDay = d.monthDay;
    if (mDay.isEmpty) {
      final reg = RegExp(r'\d{1,2}/\d{1,2}');
      final match = reg.firstMatch(d.date);
      if (match != null) {
        mDay = match.group(0)!;
      } else {
        // 如果没有，直接按当前时间递推
        final targetDate = DateTime.now().add(Duration(days: index));
        mDay = '${targetDate.month.toString().padLeft(2, '0')}/${targetDate.day.toString().padLeft(2, '0')}';
      }
    }
    final displayDate = '$dayLabel $mDay';
    final descText = WeatherHelper.getWeatherDescription(d.weatherCode, isEn: isEn);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: isEn ? 102 : 78,
                      child: Text(
                        displayDate,
                        maxLines: 1,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Row(
                        children: [
                          Text(icon, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              descText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${d.tempMin.round()}°',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 28,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.amberAccent
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
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
                ),
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
        _buildBentoItem('💧 ${I18n.humidity}', '${data.relativeHumidity}%', I18n.comfortable),
        _buildBentoItem('💨 ${I18n.wind}', '${data.windSpeed.round()} km/h', I18n.gentleBreeze),
        _buildBentoItem('☀️ ${I18n.uvIndex}', '1', I18n.uvLow),
        _buildBentoItem('👁️ ${I18n.visibility}', '10 km', I18n.clearView),
      ],
    );
  }

  Widget _buildBentoItem(String title, String val, String sub) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(val,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
          Text(sub,
              style:
                  const TextStyle(color: Colors.white60, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              I18n.pureMode,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            I18n.dataSource,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

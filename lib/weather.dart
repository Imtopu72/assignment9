import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  WeatherPageState createState() => WeatherPageState();
}

class WeatherPageState extends State<WeatherPage> {
  String _location = '';
  String _temperature = '';
  String _weatherDescription = '';
  String _weatherIcon = '';
  String _currentTime = '';
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
    _updateTime();
  }
  void _updateTime() {
    setState(() {
      _currentTime = DateFormat.jm().format(DateTime.now());
    });
    // Update the time every minute
    Future.delayed(const Duration(minutes: 1), _updateTime);
  }

  Future<void> _fetchWeatherData() async {
    try {

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);


      String apiKey = '03c52c6b71075e0a76c6aec5108175a4';
      String apiUrl =
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey';
      http.Response response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Parse weather data
        Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _location = data['name'];
          _temperature = '${(data['main']['temp'] - 273.15).toStringAsFixed(1)}°C';
          _weatherDescription = data['weather'][0]['description'];
          _weatherIcon = data['weather'][0]['icon'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _hasError
            ? const Text(
          'Failed to fetch weather data',
          style: TextStyle(fontSize: 18.0),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _location,
              style: const TextStyle(fontSize: 35.0,fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Updated: $_currentTime',
              style: const TextStyle(fontSize: 25),
            ),
            const SizedBox(height: 16.0),
            Row(

              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://openweathermap.org/img/w/$_weatherIcon.png',
                ),
                Text(
                  _temperature,
                  style: const TextStyle(
                    fontSize: 48.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text(
              _weatherDescription,
              style: const TextStyle(
                  fontSize: 24.0,fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
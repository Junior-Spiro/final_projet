import 'package:flutter/material.dart';

class DonneesMeteoWidget extends StatelessWidget {
  final Map<String, dynamic> donneesMeteo;

  const DonneesMeteoWidget({super.key, required this.donneesMeteo});

  @override
  Widget build(BuildContext context) {
    final ville = donneesMeteo['name'];
    final temp = donneesMeteo['main']['temp'];
    final description = donneesMeteo['weather'][0]['description'];
    final iconCode = donneesMeteo['weather'][0]['icon'];
    final humidite = donneesMeteo['main']['humidity'];
    final iconUrl = 'https://openweathermap.org/img/wn/$iconCode@2x.png';

    return Card(
      color: Colors.green[300],
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            Text(
              '$ville',
              style: Theme.of(context).textTheme.headlineLarge,
              overflow: TextOverflow.ellipsis,
            ),
            Image.network(iconUrl, width: 150, height: 100, fit: BoxFit.cover),
            Text(
              '${temp.toStringAsFixed(1)}°C',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              description[0].toUpperCase() + description.substring(1),
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
            if (humidite != null)
              Text(
                'Humidité: $humidite %',
                style: Theme.of(context).textTheme.titleMedium,
              ),
          ],
        ),
      ),
    );
  }
}

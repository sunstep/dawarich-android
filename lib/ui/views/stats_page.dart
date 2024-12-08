import 'package:dawarich/application/dependency_injection/service_locator.dart';
import 'package:dawarich/ui/models/stats_page_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:dawarich/ui/widgets/drawer.dart';
import 'package:dawarich/ui/widgets/appbar.dart';
import 'package:provider/provider.dart';

class StatsPage extends StatelessWidget {

  const StatsPage({super.key});

  Widget _pageContent(BuildContext context){

    StatsPageViewModel viewModel = context.watch<StatsPageViewModel>();

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final borderColor = Theme.of(context).dividerColor;
    final textLarge = Theme.of(context).textTheme.bodyLarge;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(context, viewModel),
          const SizedBox(height: 20),
          Center(
            child:
            ElevatedButton(
              onPressed: viewModel.isLoading ? null : viewModel.refreshStats,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: borderColor,
                ),
              ),
              child: Text(
                'Update stats',
                style: textLarge,
              ),
            ),
          ),
          const SizedBox(height: 20),
          //_buildYearlyStats(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, StatsPageViewModel viewModel) {

    List<Widget> statItems = [
      _buildHeaderItem(context, viewModel.isLoading? null : '${viewModel.stats?.totalCountries}', 'Countries visited', Colors.purple, 150, 90),
      _buildHeaderItem(context, viewModel.isLoading? null : '${viewModel.stats?.totalCities}', 'Cities visited', Colors.green, 150, 90),
      _buildHeaderItem(context, viewModel.isLoading? null : '${viewModel.stats?.totalPoints}', 'Geopoints Tracked', Colors.pink, 150, 90),
      _buildHeaderItem(context, viewModel.isLoading? null : '${viewModel.stats?.totalReverseGeocodedPoints}', 'Reverse geocoded', Colors.orange, 150, 90),
      _buildHeaderItem(context, viewModel.isLoading? null : '${viewModel.stats?.totalDistance} km', 'Total distance', Colors.blue, 325, 90),
    ];

    return Column(
      children: [
        Wrap(
          spacing: 20.0,
          runSpacing: 20.0,
          alignment: WrapAlignment.center,
          children: statItems.length.isEven
              ? statItems
              : statItems.sublist(0, statItems.length - 1),
        ),
        if (statItems.length.isOdd)
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              statItems.last,
            ],
          ),
      ],
    );
  }

  Widget _buildHeaderItem(BuildContext context, String? value, String label, Color color, double? width, double? height) {

    final textSmall = Theme.of(context).textTheme.bodySmall;

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 100),
            child: value == null
                ? Container(
              width: 40.0,
              height: 20.0,
              color: Colors.grey.shade300,
            )
                : Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              key: ValueKey<String?>(value),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textSmall,
          ),
        ],
      ),
    );
  }

  // Widget _buildYearlyStats() {
  //
  // }

  Widget _pageBase(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: "Stats", fontSize: 40),
      body: _pageContent(context),
      drawer: const CustomDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final StatsPageViewModel viewModel = getIt<StatsPageViewModel>();
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Builder(builder: (context) => _pageBase(context)
      ),
    );
  }

}

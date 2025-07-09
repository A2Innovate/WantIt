import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile/stores/client.dart';
import 'package:mobile/types/log.dart';
import 'package:mobile/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/user_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final Map<String, String> statTypes = {
    'users': '',
    'requests': '',
    'offers': '',
  };

  Future<void> getStat() async {
    final response = await useApi().get("/admin/stats");
    if (response.statusCode == 200) {
      setState(() {
        statTypes['users'] = response.data['users'].toString();
        statTypes['requests'] = response.data['requests'].toString();
        statTypes['offers'] = response.data['offers'].toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final current = Provider.of<UserProvider>(context, listen: false).current;
      if (!(current?.isAdmin ?? false)) {
        Navigator.pop(context);
      }
    });
    getStat();
  }

  @override
  Widget build(BuildContext context) {
    final current = Provider.of<UserProvider>(context).current;

    if (!(current?.isAdmin ?? false)) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatCard(type: 'users', value: statTypes['users']!),
                StatCard(type: 'requests', value: statTypes['requests']!),
                StatCard(type: 'offers', value: statTypes['offers']!),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                GraphCard(type: 'requests'),
                GraphCard(type: 'offers'),
                GraphCard(type: 'users'),
                // GraphCard(type: 'ratelimits'),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const RecentActivityListInline(),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String type;
  final String value;

  const StatCard({super.key, required this.type, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.translate(type),
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GraphCard extends StatefulWidget {
  final String type;

  const GraphCard({super.key, required this.type});

  State<GraphCard> createState() => _GraphCardState();
}

class _GraphCardState extends State<GraphCard> {
  List<num>? count;
  List<String>? days;
  bool isLoading = true;

  Future<void> getStat() async {
    final response = await useApi().get("/admin/stats/${widget.type}");
    if (response.statusCode == 200) {
      setState(() {
        days = List<String>.from(response.data['day']);
        count = List<num>.from(response.data['count']);
        isLoading = false;
      });
    } else {
      // Handle error or set loading false
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getStat();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 200,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    // If no data, show a placeholder text
    if (count == null || count!.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 200,
          child: Center(child: Text('No data available')),
        ),
      );
    }

    // Build spots for chart from count list
    final spots = <FlSpot>[];
    for (var i = 0; i < count!.length; i++) {
      spots.add(FlSpot(i.toDouble(), count![i].toDouble()));
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FlutterI18n.translate(
                  context,
                  'created_in_last_days',
                  translationParams: {
                    "type": context.translate(widget.type),
                    "count": "30",
                  },
                ),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 3,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (days != null &&
                                index >= 0 &&
                                index < days!.length &&
                                index % 5 == 0) {
                              return SideTitleWidget(
                                space: 4,
                                meta: meta,
                                child: Transform.rotate(
                                  angle: -0.5, // ~ -28 degrees
                                  child: Text(
                                    days![index],
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, interval: 1),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: true),
                    minY: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RecentActivityListInline extends StatefulWidget {
  const RecentActivityListInline({super.key});

  @override
  State<RecentActivityListInline> createState() =>
      _RecentActivityListInlineState();
}

class _RecentActivityListInlineState extends State<RecentActivityListInline> {
  final List<Log> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getLogs();
  }

  Future<void> getLogs() async {
    final response = await useApi().get("/admin/logs");
    if (response.statusCode == 200) {
      setState(() {
        logs.addAll(List<Log>.from(response.data.map((e) => Log.fromJson(e))));
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatLogMessage(Log log) {
    final userName = log.user?.username ?? log.ip ?? 'System';
    final content = log.content;

    switch (log.type) {
      case 'USER_LOGIN':
        return '$userName Logged in';
      case 'USER_LOGIN_FAILURE':
        return '$userName Failed login attempt to $content';
      case 'USER_LOGOUT':
        return '$userName Logged out';
      case 'USER_REGISTRATION':
        return '$userName Registered';
      case 'REQUEST_CREATE':
        return '$userName Created request $content';
      case 'REQUEST_UPDATE':
        return '$userName Updated request $content';
      case 'REQUEST_DELETE':
        return '$userName Deleted request $content';
      case 'OFFER_CREATE':
        return '$userName Created offer $content';
      case 'OFFER_UPDATE':
        return '$userName Updated offer $content';
      case 'OFFER_DELETE':
        return '$userName Deleted offer $content';
      case 'RATELIMIT_HIT':
        return '$userName Hit rate limit on $content';
      default:
        return '$userName performed an unknown action';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (logs.isEmpty) {
      return const Center(child: Text('No recent activity found.'));
    }

    return Column(children: logs.map(_buildActivityItem).toList());
  }

  Widget _buildActivityItem(Log log) {
    final userName = log.user?.username ?? log.ip ?? 'IP';
    final avatarLetter =
        log.user?.username.characters.first.toUpperCase() ?? 'IP';
    final actionText = _formatLogMessage(log);
    final timeAgo = timeago.format(log.createdAt);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 14,
            child: Text(avatarLetter, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$userName ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: actionText.replaceFirst('$userName ', '')),
                ],
              ),
            ),
          ),

          // Time
          Text(timeAgo, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

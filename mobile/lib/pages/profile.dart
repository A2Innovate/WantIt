import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile/pages/chat_details.dart';
import 'package:mobile/pages/request_detail_page.dart';
import 'package:mobile/stores/client.dart';
import 'package:mobile/types/user.dart';
import 'package:mobile/widgets/converted_budget.dart';
import 'package:provider/provider.dart';
import 'package:mobile/utils/extensions.dart';

import '../providers/user_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../stores/currencies.dart';
import '../utils/global.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  const ProfilePage({super.key, required this.userId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileData? _profileData;

  Future<(Currency, double)?> _loadCurrencyAndConvert(
    RequestData request,
  ) async {
    final current = Provider.of<UserProvider>(context, listen: false).current;
    if (current == null) return null;

    final result = await convertCurrency(
      request.currency,
      current.preferredCurrency,
      request.budget,
    );

    return (current.preferredCurrency, result);
  }

  Future<void> _loadProfileData() async {
    final response = await useApi().get('/user/${widget.userId}');
    if (response.statusCode == 200) {
      setState(() {
        _profileData = ProfileData.fromJson(response.data);
      });
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void initState() {
    _loadProfileData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final current = Provider.of<UserProvider>(context).current;

    if (_profileData == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isSelf = current?.id == widget.userId;

    return Scaffold(
      appBar: AppBar(title: Text(context.translate("profile"))),
      body: Column(
        children: [
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 50,
            child: Text(
              _profileData!.username.isNotEmpty
                  ? _profileData!.username[0].toUpperCase()
                  : '?',
              style: const TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _profileData!.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '@${_profileData!.username}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (!isSelf && current != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.message),
              label: Text(context.translate("send_message")),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatDetailsPage(userId: widget.userId),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 24),

          // REQUESTS SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.translate("requests"),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: _profileData!.requests.isEmpty
                ? Center(
                    child: Text(
                      context.translate("no_requests_yet"),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _profileData!.requests.length,
                    itemBuilder: (context, index) {
                      final request = _profileData!.requests[index];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RequestDetailPage(requestId: request.id),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.content,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 8),
                                ConvertedBudgetText(
                                  budget: (request.budget as num).toDouble(),
                                  baseCurrency: request.currency,
                                  future: _loadCurrencyAndConvert(request),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  timeago.format(
                                    request.createdAt,
                                    locale: FlutterI18n.currentLocale(
                                      context,
                                    )!.languageCode,
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // REVIEWS SECTION
        ],
      ),
    );
  }
}

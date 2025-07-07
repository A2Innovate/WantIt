import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:mobile/stores/client.dart';
import 'package:mobile/pages/request_detail_page.dart';
import 'package:mobile/widgets/user_menu_button.dart'; // Your user menu widget
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../providers/user_provider.dart';
import '../types/request.dart';
import '../utils/global.dart';
import '../widgets/new_request_modal.dart';

class PersistentSearchPage extends StatefulWidget {
  const PersistentSearchPage({super.key});

  @override
  _PersistentSearchPageState createState() => _PersistentSearchPageState();
}

class _PersistentSearchPageState extends State<PersistentSearchPage> {
  final TextEditingController _controller = TextEditingController();
  String query = '';
  Future<List<Request>>? futureItems;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      setState(() {
        futureItems = fetchItems(query);
      });
    });
  }

  Future<void> _openRequestDetails(Request item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestDetailPage(
          requestId: item.id,
          onChanged: () {
            setState(() {
              futureItems = fetchItems(query);
            });
          },
        ),
      ),
    );
    if (result != null && result) {
      setState(() {
        futureItems = fetchItems(query);
      });
    }
  }

  Future<List<Request>> fetchItems(String query) async {
    try {
      final dio = useApi();
      final response = await dio.get(
        '/request',
        queryParameters: query.isNotEmpty ? {'content': query} : null,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          List<dynamic> data = response.data;
          return data
              .map((item) => Request.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception(
            FlutterI18n.translate(context, 'invalid_response_format'),
          );
        }
      } else {
        throw Exception(
          FlutterI18n.translate(context, 'failed_to_fetch_items'),
        );
      }
    } on DioException {
      throw Exception(FlutterI18n.translate(context, 'network_error'));
    }
  }

  void _search(String input) {
    setState(() {
      query = input;
      futureItems = fetchItems(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = Provider.of<UserProvider>(context).current;
    final searchHint = FlutterI18n.translate(context, 'search_items');
    final noResultsText = FlutterI18n.translate(context, 'no_requests_found');

    final currentLocale = FlutterI18n.currentLocale(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('WantIt'),
        actions: const [UserMenuButton()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: searchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Request>>(
              future: futureItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        futureItems = fetchItems(query);
                      });
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: 300,
                          child: Center(
                            child: Text(
                              snapshot.error?.toString().replaceFirst(
                                    'Exception: ',
                                    '',
                                  ) ??
                                  'Unknown error',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        futureItems = fetchItems(query);
                      });
                    },
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: 300,
                          child: Center(child: Text(noResultsText)),
                        ),
                      ],
                    ),
                  );
                }

                final items = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      futureItems = fetchItems(query);
                    });
                  },
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return InkWell(
                        onTap: () {
                          _openRequestDetails(item);
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.content,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatCurrency(
                                    (item.budget as num).toDouble(),
                                    item.currency,
                                    locale: currentLocale!.languageCode,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      item.user.username,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      timeago.format(
                                        item.createdAt!,
                                        locale: currentLocale.languageCode,
                                      ),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: current == null
          ? null
          : FloatingActionButton(
              onPressed: () async {
                final result = await showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  isScrollControlled: true,
                  builder: (context) => const CreateRequestModal(),
                );
                if (result == true) {
                  setState(() {
                    futureItems = fetchItems(query);
                  });
                }
              },
              tooltip: FlutterI18n.translate(context, 'new_request'),
              child: const Icon(Icons.add),
            ),
    );
  }
}

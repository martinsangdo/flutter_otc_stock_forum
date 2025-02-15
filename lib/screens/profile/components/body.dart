import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../constants.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class IPOBody extends StatefulWidget {
  const IPOBody({super.key});

  @override
  State<IPOBody> createState() =>
      _State();
}

class _State extends State<IPOBody> {
    List<dynamic> _ipoList = [];
    late bool _isLoading = true;


  String getCurrentDateFormatted() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return formattedDate;
  }

  String getDateSixMonthsAgoFormatted() {
    DateTime now = DateTime.now();
    DateTime sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);

    // Handle cases where subtracting 6 months goes to a previous year
    if (sixMonthsAgo.month <= 0) {
      int previousYear = now.year - 1;
      int previousMonth = now.month - 6 + 12; // Add 12 to wrap around
      sixMonthsAgo = DateTime(previousYear, previousMonth, now.day);


      //Edge case: If day is greater than number of days in the month
      int daysInPreviousMonth = DateTime(previousYear, previousMonth + 1, 0).day;
      if (now.day > daysInPreviousMonth) {
        sixMonthsAgo = DateTime(previousYear, previousMonth, daysInPreviousMonth);
      }
    } else {
        //Edge case: If day is greater than number of days in the month
        int daysInPreviousMonth = DateTime(now.year, sixMonthsAgo.month + 1, 0).day;
        if (now.day > daysInPreviousMonth) {
          sixMonthsAgo = DateTime(now.year, sixMonthsAgo.month, daysInPreviousMonth);
        }
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(sixMonthsAgo);
    return formattedDate;
  }
  //load IPO details, default is 6 months from now
  _loadIPOCalendar() async{
    final response = await http.Client().get(Uri.parse(
      glb_fin_uri + fin_ipoCalendar + glb_fin_key + '&from='+getDateSixMonthsAgoFormatted()+'&to='+getCurrentDateFormatted()));
    if (response.statusCode != 200){
        debugPrint('Cannot get ipo from cloud');
      } else {
        Map<String, dynamic> objFromCloud = jsonDecode(response.body);
        //debugPrint(objFromCloud.toString());
        List<Map<String, dynamic>> list = [];
        for (Map<String, dynamic> item in objFromCloud['ipoCalendar']){
          if (item['price'] != null){
            list.add({
              'symbol': item['symbol']!,
              'name': item['name']!,
              'numberOfShares': formatNumberWithCommas(item['numberOfShares']),
              'totalSharesValue': formatNumberWithCommas(item['totalSharesValue']),
              'price': item['price']!,
              'date': convertDateFormat(item['date']!)
            });
          }
        }
        //debugPrint(list.length.toString()); ~89 items
        setState(() {
          _ipoList = list;
          _isLoading = false;
        });
      }
  }
  //
  String convertDateFormat(String inputDate) {
    try {
      // 1. Parse the input date (yyyy-MM-dd)
      DateFormat inputFormat = DateFormat('yyyy-MM-dd');
      DateTime dateTime = inputFormat.parse(inputDate);

      // 2. Format the date to the desired output format (dd/mm/yyyy)
      DateFormat outputFormat = DateFormat('dd/MM/yyyy');
      String formattedDate = outputFormat.format(dateTime);

      return formattedDate;
    } catch (e) {
      // Handle parsing errors (e.g., invalid input format)
      return 'Invalid date format'; // Or throw an exception, return null, etc.
    }
  }
  //
  String formatDateFromTimestamp(int timestamp) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}";
  }
  //
  String formatNumberWithCommas(dynamic number, {int decimalPlaces = 0}) {
    try {
      double parsedNumber;

      if (number is String) {
        // Try parsing if it's a string
        parsedNumber = double.parse(number);
      } else if (number is int) {
        parsedNumber = number.toDouble(); // Convert to double if it's an int
      } else if (number is double) {
        parsedNumber = number;
      } else {
        return "Invalid Input"; // Handle other types as needed
      }


      final formatter = NumberFormat.currency(
        locale: 'en_US', // You can change the locale for different comma/decimal separators
        symbol: '', // Remove currency symbol if you don't need it
        decimalDigits: decimalPlaces, // Number of decimal places
      );
      return formatter.format(parsedNumber);
    } catch (e) {
      return "Error formatting: $e"; // Handle parsing or formatting errors
    }
  }
  //
  @override
  void initState() {
    super.initState();
    _loadIPOCalendar();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0), // Or EdgeInsets.symmetric, etc.
                  child: Center(
                    child: CircularProgressIndicator(), // Or any other widget
                  ),
                ),
              for (int i=0; i<_ipoList.length; i++) ...[
                IpoListItem(
                  title: _ipoList[i]['symbol'],
                  subTitle: _ipoList[i]['name'],
                  shares: _ipoList[i]['numberOfShares'],
                  share_value: _ipoList[i]['totalSharesValue'],
                  price: _ipoList[i]['price'],
                  date: _ipoList[i]['date'],
                ),
                const Divider(thickness: 0.3,),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class StockListItem extends StatelessWidget {
  const StockListItem({
    super.key,
    this.title,
    this.subTitle,
    this.iconData,
    this.press,
    this.commentCount,
    this.price,
    this.pctChange
  });

  final String? title, subTitle, commentCount, price;
  final IconData? iconData;
  final double? pctChange;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 3),
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        onTap: press,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Container( // Wrap the Row in a Container
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(
                  color: Colors.grey, // Border color
                  width: 0.2,          // Border thickness
                ),
              ),
            ),
            child: Row(
                children: [
                  const Icon(Icons.comment),
                  SizedBox(
                    width: 25,
                    child: Text(
                      commentCount!
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title!,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subTitle!,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (price != null && price!.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            price!,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${pctChange!}%',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 10,
                              color: pctChange! >= 0? Colors.green: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    iconData, //open detail
                    size: 20,
                  ),
                ],
              ),
            ),//end row
        ),  //end container
      ),
    );
  }
}

class IpoListItem extends StatelessWidget {
  const IpoListItem({
    super.key,
    this.title,
    this.subTitle,
    this.price,
    this.shares,
    this.share_value,
    this.date
  });

  final String? title, subTitle, price, shares, share_value, date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title!,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      subTitle!,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 12, color: Colors.black
                      ),
                    ),
                    Text(
                      "Number of Shares: " + shares!,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12,
                        color: titleColor.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      "Total share value: " + share_value!,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12,
                        color: titleColor.withOpacity(0.54),
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price!,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date!,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 10
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
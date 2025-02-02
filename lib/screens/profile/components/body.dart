import 'package:flutter/material.dart';
import '../../../constants.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: defaultPadding),
              Text("IPO Calendar",
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              IpoListPage(
                svgSrc: "assets/icons/profile.svg",
                title: "ZNTL",
                subTitle: "ZENTALIS PHARMACEUTICALS, LLC",
                press: () {},
              ),
              const Divider(thickness: 0.3,),
              IpoListPage(
                svgSrc: "assets/icons/lock.svg",
                title: "Change Password",
                subTitle: "Change your password",
                press: () {},
              ),
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
    this.svgSrc,
    this.press,
    this.commentCount,
    this.price,
    this.pctChange
  });

  final String? title, subTitle, svgSrc, commentCount, price;
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
                          style: TextStyle(
                            fontSize: 14,
                            color: titleColor.withOpacity(0.54),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
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
                  const Icon(
                    Icons.arrow_forward_ios_outlined,
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

class IpoListPage extends StatelessWidget {
  const IpoListPage({
    super.key,
    this.title,
    this.subTitle,
    this.svgSrc,
    this.press,
    this.commentCount
  });

  final String? title, subTitle, svgSrc, commentCount;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: InkWell(
        onTap: press,
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
                      style: TextStyle(
                        fontSize: 12,
                        color: titleColor.withOpacity(0.54),
                      ),
                    ),
                    Text(
                      "Number of Shares: 7,650,000",
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12,
                        color: titleColor.withOpacity(0.54),
                      ),
                    ),
                    Text(
                      "Total share value: 158,355,000",
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
                      "16.00 - 18.00",
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "2020-04-03",
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
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
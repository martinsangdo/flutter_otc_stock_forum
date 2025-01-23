import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../constants.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
        controller: EventController(),
        child: const MaterialApp(
            home: Scaffold(
              body: MonthView(),
          )
        )
    );
  }
}

class ProfileMenuCard extends StatelessWidget {
  const ProfileMenuCard({
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
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        onTap: press,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              SvgPicture.asset(
                svgSrc!,
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(
                  titleColor.withOpacity(0.64),
                  BlendMode.srcIn,
                ),
              ),
              // Text(commentCount!),
              const SizedBox(width: 8),
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
                      "1.24",
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "0.10 (8.77%)",
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_outlined,
                size: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}

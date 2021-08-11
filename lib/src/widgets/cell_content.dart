// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../customization/calendar_builders.dart';
import '../customization/calendar_style.dart';

class CellContent extends StatelessWidget {
  final DateTime day;
  final DateTime focusedDay;
  final dynamic locale;
  final bool isTodayHighlighted;
  final bool isToday;
  final bool isSelected;
  final bool isRangeStart;
  final bool isRangeEnd;
  final bool isWithinRange;
  final bool isOutside;
  final bool isDisabled;
  final bool isHoliday;
  final bool isWeekend;
  final CalendarStyle calendarStyle;
  final CalendarBuilders calendarBuilders;
  final List<Map<String, dynamic>>? events;
  final Widget? icon;
  final TextStyle? defaultTextStyle;
  final TextStyle? selectedTextStyle;
  final Decoration? defaultDecoration;
  final Decoration? selectedDecoration;

  const CellContent({
    Key? key,
    required this.day,
    required this.focusedDay,
    required this.calendarStyle,
    required this.calendarBuilders,
    required this.isTodayHighlighted,
    required this.isToday,
    required this.isSelected,
    required this.isRangeStart,
    required this.isRangeEnd,
    required this.isWithinRange,
    required this.isOutside,
    required this.isDisabled,
    required this.isHoliday,
    required this.isWeekend,
    this.locale,
    this.events,
    this.icon,
    this.defaultTextStyle,
    this.selectedTextStyle,
    this.defaultDecoration,
    this.selectedDecoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? cell =
        calendarBuilders.prioritizedBuilder?.call(context, day, focusedDay);

    if (cell != null) {
      return cell;
    }

    final text = '${day.day}';
    final weekdayString = DateFormat.EEEE(locale).format(day);
    final semanticsLabelString =
        '$weekdayString, ${DateFormat.yMMMMd(locale).format(day)}';

    final margin = calendarStyle.cellMargin;
    final duration = const Duration(milliseconds: 250);

    if (isDisabled) {
      cell = calendarBuilders.disabledBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            decoration: calendarStyle.disabledDecoration,
            alignment: Alignment.center,
            child: Semantics(
                label: semanticsLabelString,
                excludeSemantics: true,
                child: Text(text, style: calendarStyle.disabledTextStyle)),
          );
    } else if (isSelected) {
      cell = calendarBuilders.selectedBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            decoration: selectedDecoration ?? calendarStyle.selectedDecoration,
            alignment: Alignment.center,
            child: Semantics(
              label: semanticsLabelString,
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  text,
                  style: selectedTextStyle ?? calendarStyle.selectedTextStyle,
                ),
              ),
            ),
          );
    } else if (isRangeStart) {
      cell =
          calendarBuilders.rangeStartBuilder?.call(context, day, focusedDay) ??
              AnimatedContainer(
                duration: duration,
                margin: margin,
                decoration: calendarStyle.rangeStartDecoration,
                alignment: Alignment.center,
                child: Semantics(
                    label: semanticsLabelString,
                    excludeSemantics: true,
                    child:
                        Text(text, style: calendarStyle.rangeStartTextStyle)),
              );
    } else if (isRangeEnd) {
      cell = calendarBuilders.rangeEndBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            decoration: calendarStyle.rangeEndDecoration,
            alignment: Alignment.center,
            child: Semantics(
                label: semanticsLabelString,
                excludeSemantics: true,
                child: Text(text, style: calendarStyle.rangeEndTextStyle)),
          );
    } else if (isToday && isTodayHighlighted) {
      cell = calendarBuilders.todayBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            decoration: defaultDecoration ?? calendarStyle.todayDecoration,
            alignment: Alignment.center,
            child: Semantics(
                label: semanticsLabelString,
                excludeSemantics: true,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Text(text,
                      style: defaultTextStyle ?? calendarStyle.todayTextStyle),
                )),
          );
    } else if (isOutside) {
      cell = calendarBuilders.outsideBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            decoration: calendarStyle.outsideDecoration,
            alignment: Alignment.center,
            child: Semantics(
                label: semanticsLabelString,
                excludeSemantics: true,
                child: Text(text, style: calendarStyle.outsideTextStyle)),
          );
    } else {
      cell = calendarBuilders.defaultBuilder?.call(context, day, focusedDay) ??
          AnimatedContainer(
            duration: duration,
            margin: margin,
            decoration: defaultDecoration ?? calendarStyle.todayDecoration,
            alignment: Alignment.center,
            child: Semantics(
              label: semanticsLabelString,
              excludeSemantics: true,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  text,
                  style: defaultTextStyle ?? calendarStyle.todayTextStyle,
                ),
              ),
            ),
          );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 0.5),
      ),
      child: Column(
        children: [
          Expanded(child: Container()),
          Stack(
            children: [
              cell,
              isDisabled
                  ? SizedBox.shrink()
                  : Positioned(
                      top: 3,
                      right: 5,
                      child: icon ?? SizedBox.shrink(),
                    ),
            ],
          ),
          events != null && !isDisabled
              ? Flexible(
                fit: FlexFit.tight,
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(overscroll: false),
                    child: ListView.builder(
                      itemCount: events!.length,
                      itemBuilder: (_, index) {
                        DateTime dateTime = events![index]['date'];
                        if (day.year == dateTime.year &&
                            day.month == dateTime.month &&
                            day.day == dateTime.day) {
                          return Container(
                            child: events![index]['widget'],
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ),
                )
              : Expanded(child: Container()),
        ],
      ),
    );
  }
}

///
/// Code written for:
///
///
///                              ████
///                              ████
///                              ████
///                              ████
///                              ████
///             ███████  ████    ████         ████████              ████████
///           ███████████████    ████      ██████████████        ██████████████
///         ████        █████    ████     ████        ████      ████        ████
///        ████          ████    ████    ████          ████    ████          ████
///         ████        █████    ████     ████        ████      ████        ████
///          ████████████████    ████      ██████████████        ██████████████
///             ███████  ████    ████         ████████              ████████
///                      ████
///                    █████
///                 ██████
///
///                                                    AI & the Church Hackathon
///
///
/// @license The judging committee of the 2023 AI & the Church Hackathon, organized by Gloo LLC,
/// has the permission to use, review, assess, test, and otherwise analyze this file in connection
/// with said Hackathon.
///
/// This file includes code for the household interaction page where the prayer journal is
/// being displayed.
///

import 'package:flutter/material.dart';
import 'package:blesseveryhome/hackathon/providers/data_state.dart';
import 'package:blesseveryhome/hackathon/providers/prayer_journal_provider.dart';
import 'package:blesseveryhome/hackathon/widgets/household_journal/household_journal_entry_text_field.dart';
import 'package:blesseveryhome/hackathon/widgets/household_journal/household_journal_list.dart';
import 'package:blesseveryhome/model/prayer_list_item_model.dart';
import 'package:blesseveryhome/provider/prayer_list_provider.dart';
import 'package:blesseveryhome/widgets/multi_sliver/multi_sliver.dart';
import 'package:provider/provider.dart';

class HouseholdInteractionPage extends StatelessWidget {
  const HouseholdInteractionPage({super.key});

  static const route = "/household_interaction";

  // ... Removed codes that existed before and are not required for the Hackathon.

  @override
  Widget build(BuildContext context) {
    final prayerListItem = context.watch<PrayerListItemModel>();
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        appBar: AppBar(

          // ... Removed codes that existed before and are not required for the Hackathon.

        ),
        body: CustomScrollView(
          slivers: [
            
            // ... Removed codes that existed before and are not required for the Hackathon.

            MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (context) => PrayerJournalProvider(
                    prayerListItem.id,
                    context.read<PrayerListProvider>(),
                  ),
                ),
                ChangeNotifierProvider.value(
                  value: context.read<PrayerListProvider>(),
                ),
              ],
              child: Consumer<PrayerJournalProvider>(
                builder: (context, prayerJournalProvider, child) {
                  switch (prayerJournalProvider.status) {
                    case DataState.loading:
                      
                      // ... Removed codes that existed before and are not required for the Hackathon.

                    case DataState.error:
                      
                      // ... Removed codes that existed before and are not required for the Hackathon.

                    case DataState.success:
                      return const MultiSliver(
                        children: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: JournalEntryTextField(),
                            ),
                          ),
                          SliverToBoxAdapter(child: SizedBox(height: 4.0)),
                          HouseholdJournalList(),
                        ],
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

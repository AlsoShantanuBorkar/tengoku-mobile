import 'package:flutter/material.dart';
import 'package:tengoku/src/ui/components/cards/content_card.dart';

class ContentSlider extends StatelessWidget {
  final List<Widget> cards;

  const ContentSlider({
    super.key,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cards.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        // TODO: Implement ContentCard Widget (see respective file)
        return const ContentCard(
          title: 'Content Title',
          coverImageUrl: 'Cover Image URL',
        );
      },
    );
  }
}
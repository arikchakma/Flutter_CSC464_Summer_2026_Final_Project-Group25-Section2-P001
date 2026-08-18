import 'package:flutter/material.dart';

import 'package:final_project/utility/constant.dart';

class LanguagePickerWidget extends StatelessWidget {
  const LanguagePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Choose a language',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shrinkWrap: true,
              itemCount: AppConstant.supportedLanguages.length,
              itemBuilder: (context, index) {
                final language = AppConstant.supportedLanguages[index];

                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: Text(
                    language.flag,
                    style: const TextStyle(fontSize: 26),
                  ),
                  title: Text(
                    language.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.pop(context, language.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

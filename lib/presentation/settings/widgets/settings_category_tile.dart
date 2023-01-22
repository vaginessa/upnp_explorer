import 'package:flutter/material.dart';

class SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(thickness: 2.0);
  }
}

class SettingsTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool centerLeading;

  const SettingsTile({
    this.title,
    this.subtitle,
    this.leading,
    this.onTap,
    this.trailing,
    this.centerLeading = true,
  });

  MainAxisAlignment _effectiveAlignment() {
    if (centerLeading) {
      return MainAxisAlignment.center;
    }

    return MainAxisAlignment.start;
  }

  Widget effectiveLeading() {
    final _leading = leading ?? const Icon(null);

    if (!centerLeading) {
      return _leading;
    }

    return Column(
      mainAxisAlignment: _effectiveAlignment(),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [_leading],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: theme.useMaterial3
          ? DefaultTextStyle.merge(
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(fontWeight: FontWeight.w400),
              child: title ?? Container(),
            )
          : title,
      subtitle: subtitle,
      trailing: trailing,
      leading: effectiveLeading(),
      onTap: onTap,
    );
  }
}

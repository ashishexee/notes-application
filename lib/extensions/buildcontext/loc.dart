// what is the main purpose of this file?
// by deafult evcrywhere we have to do - AppLocalizations.of(context) !
// this ! is added to avoid the possiblity off null
// here will exxtract the AppLocalization from the context itself and make sure that it does not
// return a null value
import 'package:flutter/material.dart' show BuildContext;
import 'package:flutter_gen/gen_l10n/app_localizations.dart'
    show AppLocalizations;

extension Localization on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
  // basically we have replace the Applocalizations.of(context)! with loc
  // no we dont have to do AppLocalizaions.of(context)!.my_title;  instead
  // we will use context.loc.my_title;
}


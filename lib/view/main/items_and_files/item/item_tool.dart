import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemTool{
  static String getItemCategory(BuildContext context, String id){
    String result = "";

    id = id.toUpperCase();
    if (id == "LOGIN"){
      result = AppLocalizations.of(context)!.loginItemCategoriesAPI;
    } else if (id == "PASSWORD"){
      result = AppLocalizations.of(context)!.passwordItemCategoriesAPI;
    } else if (id == "API_CREDENTIAL"){
      result = AppLocalizations.of(context)!.apiCredentialItemCategoriesAPI;
    } else if (id == "SERVER"){
      result = AppLocalizations.of(context)!.serverItemCategoriesAPI;
    } else if (id == "DATABASE"){
      result = AppLocalizations.of(context)!.databaseItemCategoriesAPI;
    } else if (id == "CREDIT_CARD"){
      result = AppLocalizations.of(context)!.creditCardItemCategoriesAPI;
    } else if (id == "MEMBERSHIP"){
      result = AppLocalizations.of(context)!.membershipItemCategoriesAPI;
    } else if (id == "PASSPORT"){
      result = AppLocalizations.of(context)!.passportItemCategoriesAPI;
    } else if (id == "SOFTWARE_LICENSE"){
      result = AppLocalizations.of(context)!.softwareLicenseItemCategoriesAPI;
    } else if (id == "OUTDOOR_LICENSE"){
      result = AppLocalizations.of(context)!.outdoorLicenseItemCategoriesAPI;
    } else if (id == "SECURE_NOTE"){
      result = AppLocalizations.of(context)!.secureNoteItemCategoriesAPI;
    } else if (id == "WIRELESS_ROUTER"){
      result = AppLocalizations.of(context)!.wirelessRouterItemCategoriesAPI;
    } else if (id == "BANK_ACCOUNT"){
      result = AppLocalizations.of(context)!.bankAccountItemCategoriesAPI;
    } else if (id == "DRIVER_LICENSE"){
      result = AppLocalizations.of(context)!.driverLicenseItemCategoriesAPI;
    } else if (id == "IDENTITY"){
      result = AppLocalizations.of(context)!.identityItemCategoriesAPI;
    } else if (id == "REWARD_PROGRAM"){
      result = AppLocalizations.of(context)!.rewardProgramItemCategoriesAPI;
    } else if (id == "DOCUMENT"){
      result = AppLocalizations.of(context)!.documentItemCategoriesAPI;
    } else if (id == "EMAIL_ACCOUNT"){
      result = AppLocalizations.of(context)!.emailAccountItemCategoriesAPI;
    } else if (id == "SOCIAL_SECURITY_NUMBER"){
      result = AppLocalizations.of(context)!.socialSecurityNumberItemCategoriesAPI;
    } else if (id == "MEDICAL_RECORD"){
      result = AppLocalizations.of(context)!.medicalRecordItemCategoriesAPI;
    } else if (id == "SSH_KEY"){
      result = AppLocalizations.of(context)!.sSHKeyItemCategoriesAPI;
    } else if (id == "OTHER"){
      result = AppLocalizations.of(context)!.otherItemCategoriesAPI;
    } else{
      result = id;
    }

    return result;
  }

  static String getItemType(BuildContext context, String id){
    String result = "";

    id = id.toUpperCase();
    if (id == "STRING"){
      result = AppLocalizations.of(context)!.stringItemTypesAPI;
    } else if (id == "PASSWORD"){
      result = AppLocalizations.of(context)!.passwordItemTypesAPI;
    } else if (id == "EMAIL"){
      result = AppLocalizations.of(context)!.emailItemTypesAPI;
    } else if (id == "CONCEALED"){
      result = AppLocalizations.of(context)!.concealedItemTypesAPI;
    } else if (id == "URL"){
      result = AppLocalizations.of(context)!.uRLItemTypesAPI;
    } else if (id == "OTP"){
      result = AppLocalizations.of(context)!.oTPItemTypesAPI;
    } else if (id == "DATE"){
      result = AppLocalizations.of(context)!.dateItemTypesAPI;
    } else if (id == "MONTH_YEAR"){
      result = AppLocalizations.of(context)!.monthYearItemTypesAPI;
    } else if (id == "MENU"){
      result = AppLocalizations.of(context)!.menuItemTypesAPI;
    } else if (id == "FILE"){
      result = AppLocalizations.of(context)!.fileItemTypesAPI;
    } else{
      result = id;
    }

    return result;
  }
}
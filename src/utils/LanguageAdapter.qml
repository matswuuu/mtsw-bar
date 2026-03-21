pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.i18n

Singleton
{
    property var translations: {
        "us": "eng",
        "English (US)": "eng",
        "ru": "ru",
        "Russian": "ru"
    }
    property var fullTranslations: {
        "us": I18n.t("language.englishUs"),
        "English (US)": I18n.t("language.englishUs"),
        "ru": I18n.t("language.russian"),
        "Russian": I18n.t("language.russian")
    }

    property
        list < string > layouts
    :
    Session.getAdapter().layouts
    property string activeLayout: Session.getAdapter().activeLayout
    property string translatedLayout: activeLayout in translations ? translations[activeLayout] : activeLayout

    function nextLanguage() {
        Session.getAdapter().nextLanguage()
    }

}

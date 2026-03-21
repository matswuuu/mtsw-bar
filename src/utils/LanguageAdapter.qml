pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property var translations: {
        "us": "eng",
        "English (US)": "eng",
        "ru": "ru",
        "Russian": "ru"
    }
    property var fullTranslations: {
        "us": "English (US)",
        "English (US)": "English (US)",
        "ru": "Russian",
        "Russian": "Russian"
    }

    property list<string> layouts: Session.getAdapter().layouts
    property string activeLayout: Session.getAdapter().activeLayout
    property string translatedLayout: activeLayout in translations ? translations[activeLayout] : activeLayout

    function nextLanguage() {
        Session.getAdapter().nextLanguage()
    }

}

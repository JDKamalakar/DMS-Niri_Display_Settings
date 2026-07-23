import QtQuick

Item {
    property string activeProfile: "extend"
    property string text: {
        switch (activeProfile) {
            case "extend": return "Extended";
            default: return "default";
        }
    }
}

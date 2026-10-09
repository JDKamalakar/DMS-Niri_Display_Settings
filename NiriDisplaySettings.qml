import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import qs.Services

PluginSettings {
    id: root
    pluginId: "niriDSA"

    readonly property real outerR: Theme.cornerRadius || 12
    readonly property real innerR: 4

    function loadValue(key, def) {
        if (typeof PluginService !== "undefined" && PluginService && PluginService.loadPluginData) {
            return PluginService.loadPluginData(root.pluginId, key, def);
        }
        return def;
    }

    function saveValue(key, val) {
        if (typeof PluginService !== "undefined" && PluginService && PluginService.savePluginData) {
            PluginService.savePluginData(root.pluginId, key, val);
            if (PluginService.setGlobalVar) {
                PluginService.setGlobalVar(root.pluginId, key, val);
            }
        }
    }

    function loadAll() {
        if (connectionDropdown) connectionDropdown.loadValue();
        if (fallbackToggle) fallbackToggle.loadValue();
        if (disableInternalToggle) disableInternalToggle.loadValue();
        if (profilesToggle) profilesToggle.loadValue();
        if (fallbackDisplayField) fallbackDisplayField.loadValue();
        if (dimSlider) dimSlider.loadValue();
        if (transSlider) transSlider.loadValue();
    }

    Component.onCompleted: loadAll()

    onPluginServiceChanged: {
        if (pluginService) {
            loadAll();
        }
    }

    Connections {
        target: PluginService
        ignoreUnknownSignals: true
        function onPluginDataChanged(pId) {
            if (pId === root.pluginId) {
                root.loadAll();
            }
        }
        function onGlobalVarChanged(pId, varName) {
            if (pId === root.pluginId) {
                root.loadAll();
            }
        }
    }

    Column {
        id: mainSettingsCol
        width: parent.width
        spacing: Theme.spacingL

        // --- Automatic Behaviors Section ---
        Column {
            width: parent.width
            spacing: Theme.spacingS

            Row {
                spacing: Theme.spacingXS
                leftPadding: Theme.spacingM
                DankIcon {
                    name: "cable"
                    size: 16
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
                StyledText {
                    text: I18n.tr("Automatic Behaviors")
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.DemiBold
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Column {
                width: parent.width
                spacing: 2

                // Segment 1: When monitor is connected (Dropdown)
                Rectangle {
                    width: parent.width
                    implicitHeight: connCol.implicitHeight + Theme.spacingM * 2
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    border.width: 1
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                    topLeftRadius: root.outerR
                    topRightRadius: root.outerR
                    bottomLeftRadius: root.innerR
                    bottomRightRadius: root.innerR

                    Column {
                        id: connCol
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingS

                        RowLayout {
                            width: parent.width
                            spacing: Theme.spacingM

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                                Layout.alignment: Qt.AlignVCenter

                                DankIcon {
                                    name: "settings_input_hdmi"
                                    size: 18
                                    color: Theme.primary
                                    anchors.centerIn: parent
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2
                                StyledText { text: I18n.tr("When monitor is connected"); font.weight: Font.Medium; color: Theme.surfaceText }
                                StyledText { text: I18n.tr("Choose what happens automatically when an external monitor is plugged in"); font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                            }
                        }

                        DankDropdown {
                            id: connectionDropdown
                            property string settingKey: "connectionAction"
                            property string defaultValue: "show_menu"
                            width: parent.width

                            property var optionList: [
                                { label: I18n.tr("Show Menu"), value: "show_menu" },
                                { label: I18n.tr("External Only"), value: "external_only" },
                                { label: I18n.tr("Extended"), value: "extend" },
                                { label: I18n.tr("Internal Only"), value: "internal_only" },
                                { label: I18n.tr("Mirror"), value: "mirror" },
                                { label: I18n.tr("Do Nothing"), value: "none" }
                            ]

                            options: optionList.map(function(opt) { return opt.label; })

                            function loadValue() {
                                var savedVal = root.loadValue(settingKey, defaultValue);
                                var found = optionList.find(function(opt) { return opt.value === savedVal; });
                                currentValue = found ? found.label : optionList[0].label;
                            }

                            Component.onCompleted: loadValue()

                            onValueChanged: value => {
                                var found = optionList.find(function(opt) { return opt.label === value; });
                                if (found) {
                                    root.saveValue(settingKey, found.value);
                                }
                            }
                        }
                    }
                }

                // Segment 2: Enable safety fallback
                Rectangle {
                    width: parent.width
                    height: 56
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    border.width: 1
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                    topLeftRadius: root.innerR
                    topRightRadius: root.innerR
                    bottomLeftRadius: root.innerR
                    bottomRightRadius: root.innerR

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingM
                        anchors.rightMargin: Theme.spacingM
                        spacing: Theme.spacingM

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: fallbackToggle.checked ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15) : Qt.rgba(Theme.surfaceContainerHighest.r, Theme.surfaceContainerHighest.g, Theme.surfaceContainerHighest.b, 0.5)
                            Layout.alignment: Qt.AlignVCenter
                            Behavior on color { ColorAnimation { duration: 150 } }

                            DankIcon {
                                name: "security"
                                size: 18
                                color: fallbackToggle.checked ? Theme.primary : Theme.surfaceVariantText
                                anchors.centerIn: parent
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2
                            StyledText { text: I18n.tr("Enable safety fallback"); font.weight: Font.Medium; color: Theme.surfaceText }
                            StyledText { text: I18n.tr("Automatically re-enable the laptop screen if all external monitors are disconnected"); font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; Layout.fillWidth: true; elide: Text.ElideRight }
                        }

                        DankToggle {
                            id: fallbackToggle
                            Layout.alignment: Qt.AlignVCenter
                            property string settingKey: "enableFallback"
                            checked: true

                            function loadValue() {
                                var val = root.loadValue(settingKey, true);
                                checked = (val === true || val === "true");
                            }
                            Component.onCompleted: loadValue()

                            onToggled: isChecked => {
                                checked = isChecked;
                                root.saveValue(settingKey, isChecked);
                            }
                        }
                    }
                }

                // Segment 3: Disable internal display option
                Rectangle {
                    width: parent.width
                    height: 56
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    border.width: 1
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                    topLeftRadius: root.innerR
                    topRightRadius: root.innerR
                    bottomLeftRadius: root.innerR
                    bottomRightRadius: root.innerR

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingM
                        anchors.rightMargin: Theme.spacingM
                        spacing: Theme.spacingM

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: disableInternalToggle.checked ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15) : Qt.rgba(Theme.surfaceContainerHighest.r, Theme.surfaceContainerHighest.g, Theme.surfaceContainerHighest.b, 0.5)
                            Layout.alignment: Qt.AlignVCenter
                            Behavior on color { ColorAnimation { duration: 150 } }

                            DankIcon {
                                name: "desktop_access_disabled"
                                size: 18
                                color: disableInternalToggle.checked ? Theme.primary : Theme.surfaceVariantText
                                anchors.centerIn: parent
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2
                            StyledText { text: I18n.tr("Disable internal display option"); font.weight: Font.Medium; color: Theme.surfaceText }
                            StyledText { text: I18n.tr("Remove the internal display option and 'Internal Only' profile selection from UIs"); font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; Layout.fillWidth: true; elide: Text.ElideRight }
                        }

                        DankToggle {
                            id: disableInternalToggle
                            Layout.alignment: Qt.AlignVCenter
                            property string settingKey: "disableInternalOption"
                            checked: false

                            function loadValue() {
                                var val = root.loadValue(settingKey, false);
                                checked = (val === true || val === "true");
                            }
                            Component.onCompleted: loadValue()

                            onToggled: isChecked => {
                                checked = isChecked;
                                root.saveValue(settingKey, isChecked);
                            }
                        }
                    }
                }

                // Segment 4: Show display profiles
                Rectangle {
                    width: parent.width
                    height: 56
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    border.width: 1
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                    topLeftRadius: root.innerR
                    topRightRadius: root.innerR
                    bottomLeftRadius: root.innerR
                    bottomRightRadius: root.innerR

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingM
                        anchors.rightMargin: Theme.spacingM
                        spacing: Theme.spacingM

                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: profilesToggle.checked ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15) : Qt.rgba(Theme.surfaceContainerHighest.r, Theme.surfaceContainerHighest.g, Theme.surfaceContainerHighest.b, 0.5)
                            Layout.alignment: Qt.AlignVCenter
                            Behavior on color { ColorAnimation { duration: 150 } }

                            DankIcon {
                                name: "view_carousel"
                                size: 18
                                color: profilesToggle.checked ? Theme.primary : Theme.surfaceVariantText
                                anchors.centerIn: parent
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }

                        Column {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2
                            StyledText { text: I18n.tr("Show display profiles"); font.weight: Font.Medium; color: Theme.surfaceText }
                            StyledText { text: I18n.tr("Show saved display configuration profiles under the manual controls section"); font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; Layout.fillWidth: true; elide: Text.ElideRight }
                        }

                        DankToggle {
                            id: profilesToggle
                            Layout.alignment: Qt.AlignVCenter
                            property string settingKey: "showDisplayProfiles"
                            checked: false

                            function loadValue() {
                                var val = root.loadValue(settingKey, false);
                                checked = (val === true || val === "true");
                            }
                            Component.onCompleted: loadValue()

                            onToggled: isChecked => {
                                checked = isChecked;
                                root.saveValue(settingKey, isChecked);
                            }
                        }
                    }
                }

                // Segment 5: Preferred internal display (Text input)
                Rectangle {
                    width: parent.width
                    implicitHeight: prefCol.implicitHeight + Theme.spacingM * 2
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    border.width: 1
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                    topLeftRadius: root.innerR
                    topRightRadius: root.innerR
                    bottomLeftRadius: root.outerR
                    bottomRightRadius: root.outerR

                    Column {
                        id: prefCol
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingS

                        RowLayout {
                            width: parent.width
                            spacing: Theme.spacingM

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                                Layout.alignment: Qt.AlignVCenter

                                DankIcon {
                                    name: "display_settings"
                                    size: 18
                                    color: Theme.primary
                                    anchors.centerIn: parent
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2
                                StyledText { text: I18n.tr("Preferred internal display"); font.weight: Font.Medium; color: Theme.surfaceText }
                                StyledText { text: I18n.tr("The name of your laptop display (e.g. eDP-1). Leave empty for auto-detection."); font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                            }
                        }

                        DankTextField {
                            id: fallbackDisplayField
                            property string settingKey: "fallbackDisplay"
                            property string defaultValue: ""
                            width: parent.width
                            placeholderText: "eDP-1"

                            function loadValue() {
                                text = root.loadValue(settingKey, defaultValue);
                            }
                            Component.onCompleted: loadValue()
                            onEditingFinished: {
                                root.saveValue(settingKey, text);
                            }
                        }
                    }
                }
            }
        }

        // --- Interface Settings Section ---
        Column {
            width: parent.width
            spacing: Theme.spacingS

            Row {
                spacing: Theme.spacingXS
                leftPadding: Theme.spacingM
                DankIcon {
                    name: "palette"
                    size: 16
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
                StyledText {
                    text: I18n.tr("Interface Settings")
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.DemiBold
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Column {
                width: parent.width
                spacing: 2

                // Segment 1: Backdrop Dim Slider
                Rectangle {
                    width: parent.width
                    implicitHeight: dimCol.implicitHeight + Theme.spacingM * 2
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    border.width: 1
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                    topLeftRadius: root.outerR
                    topRightRadius: root.outerR
                    bottomLeftRadius: root.innerR
                    bottomRightRadius: root.innerR

                    Column {
                        id: dimCol
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingS

                        RowLayout {
                            width: parent.width
                            spacing: Theme.spacingM

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                                Layout.alignment: Qt.AlignVCenter

                                DankIcon {
                                    name: "tonality"
                                    size: 18
                                    color: Theme.primary
                                    anchors.centerIn: parent
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2
                                StyledText { text: I18n.tr("Backdrop Dim"); font.weight: Font.Medium; color: Theme.surfaceText }
                                StyledText { text: I18n.tr("Backdrop overlay dim level for fullscreen modal"); font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; Layout.fillWidth: true; elide: Text.ElideRight }
                            }

                            Rectangle {
                                id: dimResetBtn
                                width: 32; height: 32
                                radius: Theme.cornerRadius
                                Layout.alignment: Qt.AlignVCenter
                                color: dimResetMa.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                                border.color: dimResetMa.containsMouse ? Theme.primary : Theme.outline
                                border.width: 1
                                opacity: dimSlider.value !== dimSlider.defaultValue ? (dimResetMa.containsMouse ? 1.0 : 0.9) : 0.0
                                visible: opacity > 0
                                scale: dimResetMa.containsMouse ? 1.1 : 1.0

                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                                DankRipple { 
                                    id: dimRip
                                    anchors.fill: parent
                                    cornerRadius: parent.radius
                                    rippleColor: Theme.primary 
                                }

                                DankIcon {
                                    name: "restart_alt"
                                    size: 18
                                    anchors.centerIn: parent
                                    color: dimResetMa.containsMouse ? Theme.primary : Theme.surfaceVariantText
                                    rotation: dimResetMa.containsMouse ? 90 : 0
                                    Behavior on rotation { NumberAnimation { duration: 450; easing.type: Easing.OutBack } }
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                MouseArea {
                                    id: dimResetMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        dimSlider.value = dimSlider.defaultValue;
                                        root.saveValue(dimSlider.settingKey, dimSlider.defaultValue / 100);
                                    }
                                    onPressed: (m) => dimRip.trigger(m.x, m.y)
                                }
                            }
                        }

                        DankSlider {
                            id: dimSlider
                            property string settingKey: "backdropDim"
                            property int defaultValue: 20
                            width: parent.width
                            minimum: 0
                            maximum: 100
                            step: 1
                            unit: "%"

                            function loadValue() {
                                const savedVal = root.loadValue(settingKey, defaultValue / 100);
                                value = Math.round(parseFloat(savedVal) * 100);
                            }
                            Component.onCompleted: loadValue()
                            onSliderValueChanged: newValue => {
                                value = newValue;
                                root.saveValue(settingKey, newValue / 100);
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: false
                                acceptedButtons: Qt.NoButton
                                onWheel: (wheel) => { wheel.accepted = true; }
                            }
                        }
                    }
                }

                // Segment 2: UI Transparency Slider
                Rectangle {
                    width: parent.width
                    implicitHeight: transCol.implicitHeight + Theme.spacingM * 2
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    border.width: 1
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                    topLeftRadius: root.innerR
                    topRightRadius: root.innerR
                    bottomLeftRadius: root.outerR
                    bottomRightRadius: root.outerR

                    Column {
                        id: transCol
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingS

                        RowLayout {
                            width: parent.width
                            spacing: Theme.spacingM

                            Rectangle {
                                width: 32
                                height: 32
                                radius: 16
                                color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.15)
                                Layout.alignment: Qt.AlignVCenter

                                DankIcon {
                                    name: "opacity"
                                    size: 18
                                    color: Theme.primary
                                    anchors.centerIn: parent
                                }
                            }

                            Column {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 2
                                StyledText { text: I18n.tr("UI Transparency"); font.weight: Font.Medium; color: Theme.surfaceText }
                                StyledText { text: I18n.tr("UI transparency level for settings modal cards"); font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; Layout.fillWidth: true; elide: Text.ElideRight }
                            }

                            Rectangle {
                                id: transResetBtn
                                width: 32; height: 32
                                radius: Theme.cornerRadius
                                Layout.alignment: Qt.AlignVCenter
                                color: transResetMa.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                                border.color: transResetMa.containsMouse ? Theme.primary : Theme.outline
                                border.width: 1
                                opacity: transSlider.value !== transSlider.defaultValue ? (transResetMa.containsMouse ? 1.0 : 0.9) : 0.0
                                visible: opacity > 0
                                scale: transResetMa.containsMouse ? 1.1 : 1.0

                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                                DankRipple { 
                                    id: transRip
                                    anchors.fill: parent
                                    cornerRadius: parent.radius
                                    rippleColor: Theme.primary 
                                }

                                DankIcon {
                                    name: "restart_alt"
                                    size: 18
                                    anchors.centerIn: parent
                                    color: transResetMa.containsMouse ? Theme.primary : Theme.surfaceVariantText
                                    rotation: transResetMa.containsMouse ? 90 : 0
                                    Behavior on rotation { NumberAnimation { duration: 450; easing.type: Easing.OutBack } }
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                MouseArea {
                                    id: transResetMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        transSlider.value = transSlider.defaultValue;
                                        root.saveValue(transSlider.settingKey, transSlider.defaultValue / 100);
                                    }
                                    onPressed: (m) => transRip.trigger(m.x, m.y)
                                }
                            }
                        }

                        DankSlider {
                            id: transSlider
                            property string settingKey: "uiTransparency"
                            property int defaultValue: 50
                            width: parent.width
                            minimum: 0
                            maximum: 100
                            step: 1
                            unit: "%"

                            function loadValue() {
                                const savedVal = root.loadValue(settingKey, defaultValue / 100);
                                value = Math.round(parseFloat(savedVal) * 100);
                            }
                            Component.onCompleted: loadValue()
                            onSliderValueChanged: newValue => {
                                value = newValue;
                                root.saveValue(settingKey, newValue / 100);
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: false
                                acceptedButtons: Qt.NoButton
                                onWheel: (wheel) => { wheel.accepted = true; }
                            }
                        }
                    }
                }
            }
        }

        // --- Commands & Shortcuts Section ---
        Column {
            width: parent.width
            spacing: Theme.spacingS

            Row {
                spacing: Theme.spacingXS
                leftPadding: Theme.spacingM
                DankIcon {
                    name: "terminal"
                    size: 16
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
                StyledText {
                    text: I18n.tr("Commands & Shortcuts")
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.DemiBold
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width: parent.width
                implicitHeight: cmdInnerCol.implicitHeight + Theme.spacingM * 2
                radius: root.outerR
                color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                border.width: 1
                border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                Column {
                    id: cmdInnerCol
                    width: parent.width - Theme.spacingM * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacingM
                    spacing: Theme.spacingM

                    StyledText {
                        width: parent.width
                        text: I18n.tr("You can open, close, or toggle the Niri Display Settings modal using the dms CLI:")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                    }

                    CopyBox {
                        label: I18n.tr("Toggle Modal Command")
                        text: "dms ipc call niriDSA toggle"
                    }

                    CopyBox {
                        label: I18n.tr("Open Modal Command")
                        text: "dms ipc call niriDSA open"
                    }

                    CopyBox {
                        label: I18n.tr("Close Modal Command")
                        text: "dms ipc call niriDSA close"
                    }

                    CopyBox {
                        label: I18n.tr("Apply Profile Command")
                        text: "dms ipc call niriDSA apply internal_only"
                    }

                    StyledText {
                        width: parent.width
                        text: I18n.tr("Valid profiles: internal_only, external_only, extend, mirror")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        opacity: 0.7
                    }

                    StyledText {
                        width: parent.width
                        text: I18n.tr("To trigger the display selector using Mod+P, add this spawn command to your Niri configuration binds:")
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.primary
                        font.italic: true
                        wrapMode: Text.WordWrap
                    }

                    CopyBox {
                        label: I18n.tr("Niri Bind Configuration")
                        text: "Mod+P { spawn \"dms\" \"ipc\" \"call\" \"niriDSA\" \"toggle\"; }"
                    }
                }
            }
        }
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Widgets
import qs.Modules.Plugins
import qs.Modules.Settings.Widgets
import qs.Services

PluginSettings {
    id: root
    pluginId: "niriDSA"

    readonly property real outerR: Theme.cornerRadius || 12
    readonly property real innerR: 4

    component SectionHeader: Row {
        property string title: ""
        property string iconName: ""

        spacing: Theme.spacingXS
        leftPadding: Theme.spacingM

        DankIcon {
            name: iconName
            size: 16
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            text: title
            font.pixelSize: Theme.fontSizeSmall
            font.weight: Font.DemiBold
            color: Theme.primary
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Process {
        id: launchProcess
        command: ["dms", "ipc", "call", "niriDSA", "toggle"]
        running: false
    }

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

            SectionHeader {
                title: I18n.tr("Interface Settings")
                iconName: "palette"
            }

            Column {
                width: parent.width
                spacing: 2

                // Segment 1: Backdrop Dim Slider
                Rectangle {
                    width: parent.width
                    height: dimCol.implicitHeight + Theme.spacingM * 2
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    border.width: 1
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                    topLeftRadius: root.outerR
                    topRightRadius: root.outerR
                    bottomLeftRadius: root.innerR
                    bottomRightRadius: root.innerR

                    ColumnLayout {
                        id: dimCol
                        anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Theme.spacingM; anchors.rightMargin: Theme.spacingM
                        spacing: Theme.spacingS

                        SliderSettingV2 {
                            id: dimSlider
                            Layout.fillWidth: true
                            settingKey: "backdropDim"
                            label: I18n.tr("Backdrop Dim")
                            description: I18n.tr("Backdrop overlay dim level for fullscreen modal")
                            defaultValue: "0.20"
                            minVal: 0.00
                            maxVal: 1.00
                            isFloatBackend: true
                            showPercentage: true
                            iconName: "tonality"
                        }
                    }
                }

                // Segment 2: UI Transparency Slider
                Rectangle {
                    width: parent.width
                    height: transCol.implicitHeight + Theme.spacingM * 2
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    border.width: 1
                    border.color: Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.10)

                    topLeftRadius: root.innerR
                    topRightRadius: root.innerR
                    bottomLeftRadius: root.outerR
                    bottomRightRadius: root.outerR

                    ColumnLayout {
                        id: transCol
                        anchors.left: parent.left; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: Theme.spacingM; anchors.rightMargin: Theme.spacingM
                        spacing: Theme.spacingS

                        SliderSettingV2 {
                            id: transSlider
                            Layout.fillWidth: true
                            settingKey: "uiTransparency"
                            label: I18n.tr("UI Transparency")
                            description: I18n.tr("UI transparency level for settings modal cards")
                            defaultValue: "0.50"
                            minVal: 0.00
                            maxVal: 1.00
                            isFloatBackend: true
                            showPercentage: true
                            iconName: "opacity"
                        }
                    }
                }
            }
        }

        // --- Commands & Shortcuts Section ---
        Column {
            width: parent.width
            spacing: Theme.spacingS

            SectionHeader {
                title: I18n.tr("IPC Commands & Shortcuts")
                iconName: "keyboard_command_key"
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

                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM

                        Column {
                            Layout.fillWidth: true
                            spacing: 2

                            StyledText {
                                text: I18n.tr("You can open, close, or toggle the Niri Display Settings modal using the dms CLI:")
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: parent.width
                                wrapMode: Text.WordWrap
                            }
                        }

                        Rectangle {
                            id: openModalBtn
                            Layout.preferredHeight: 34
                            Layout.preferredWidth: openModalRow.implicitWidth + 24
                            Layout.alignment: Qt.AlignVCenter
                            property bool isHovered: openModalMa.containsMouse

                            radius: isHovered ? (height / 2) : (Theme.cornerRadius || 12)
                            Behavior on radius { NumberAnimation { duration: 350; easing.type: Easing.OutExpo } }

                            color: isHovered ? Theme.withAlpha(Theme.primary, 0.25) : Theme.withAlpha(Theme.primary, 0.15)
                            Behavior on color { ColorAnimation { duration: 150 } }
                            border.width: 1
                            border.color: isHovered ? Theme.primary : Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.3)
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            scale: openModalMa.pressed ? 0.94 : (isHovered ? 1.02 : 1.0)
                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                            DankRipple {
                                id: openModalRip
                                anchors.fill: parent
                                cornerRadius: parent.radius
                                rippleColor: Theme.primary
                            }

                            RowLayout {
                                id: openModalRow
                                anchors.centerIn: parent
                                spacing: 6

                                DankIcon {
                                    name: "open_in_new"
                                    size: 16
                                    color: Theme.primary
                                }

                                StyledText {
                                    text: I18n.tr("Toggle Modal")
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.weight: Font.Medium
                                    color: Theme.primary
                                }
                            }

                            MouseArea {
                                id: openModalMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onPressed: (m) => openModalRip.trigger(m.x, m.y)
                                onClicked: {
                                    launchProcess.running = true;
                                }
                            }
                        }
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

        // --- Required Packages Section ---
        Item {
            id: depsWrapper
            width: parent.width
            implicitHeight: depsCol.implicitHeight

            property bool expanded: false
            property var depStatus: ({
                "niri": true,
                "wl-mirror": true
            })
            property bool isChecking: true

            Process {
                id: depChecker
                command: [
                    "bash", "-c",
                    "python3 -c \"import json, shutil, sys, subprocess\n" +
                    "def is_present(cmd):\n" +
                    "    if shutil.which(cmd):\n" +
                    "        return True\n" +
                    "    try:\n" +
                    "        res = subprocess.run(['flatpak-spawn', '--host', 'which', cmd], capture_output=True)\n" +
                    "        if res.returncode == 0 and res.stdout.strip():\n" +
                    "            return True\n" +
                    "    except Exception:\n" +
                    "        pass\n" +
                    "    return False\n" +
                    "cmds = [('niri', 'niri'), ('wl-mirror', 'wl-mirror')]\n" +
                    "results = {k: is_present(cmd) for k, cmd in cmds}\n" +
                    "sys.stdout.write(json.dumps(results))\n\""
                ]
                stdout: StdioCollector {
                    onStreamFinished: {
                        depsWrapper.isChecking = false;
                        try {
                            if (text && text.trim() !== "") {
                                depsWrapper.depStatus = JSON.parse(text.trim());
                            }
                        } catch (e) {
                            console.warn("Failed to parse dependency status:", e);
                        }
                    }
                }
            }

            Component.onCompleted: {
                depChecker.running = true;
            }

            Column {
                id: depsCol
                width: parent.width
                spacing: 0

                Item {
                    id: depsHeaderRow
                    width: parent.width
                    height: 40

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingM
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingXS

                        DankIcon {
                            name: "extension"
                            size: 16
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        StyledText {
                            text: I18n.tr("Required packages")
                            font.pixelSize: Theme.fontSizeSmall
                            font.weight: Font.DemiBold
                            color: Theme.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    DankIcon {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingM
                        anchors.verticalCenter: parent.verticalCenter
                        name: "expand_more"
                        size: Theme.iconSize || 20
                        color: Theme.surfaceVariantText
                        rotation: depsWrapper.expanded ? 180 : 0

                        Behavior on rotation {
                            NumberAnimation {
                                duration: 200
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            depsWrapper.expanded = !depsWrapper.expanded;
                            if (depsWrapper.expanded) {
                                depsWrapper.isChecking = true;
                                depChecker.running = true;
                            }
                        }
                    }
                }

                Item {
                    id: animHost
                    width: parent.width
                    clip: true
                    height: depsWrapper.expanded ? groupContent.implicitHeight : 0
                    opacity: depsWrapper.expanded ? 1.0 : 0.0
                    visible: height > 0 || depsWrapper.expanded

                    Behavior on height {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }

                    SettingsGroup {
                        id: groupContent
                        width: parent.width

                        SettingsRow {
                            visible: depsWrapper.isChecking
                            iconName: "hourglass_top"
                            title: I18n.tr("Checking packages...")
                        }

                        Repeater {
                            model: [
                                {
                                    id: "niri",
                                    pkg: "niri",
                                    features: "Wayland scrollable-tiling compositor & output management IPC",
                                    present: Boolean(depsWrapper.depStatus["niri"])
                                },
                                {
                                    id: "wl-mirror",
                                    pkg: "wl-mirror",
                                    features: "Low-latency display mirroring for clone/presentation modes",
                                    present: Boolean(depsWrapper.depStatus["wl-mirror"])
                                }
                            ]

                            delegate: SettingsRow {
                                iconName: modelData.present ? "check_circle" : "error"
                                iconColor: modelData.present ? Theme.success : Theme.error
                                title: modelData.pkg
                                subtitle: I18n.tr("Used for: %1").arg(modelData.features)
                                trailingBadge: modelData.present ? I18n.tr("Installed") : I18n.tr("Missing")
                                trailingBadgeColor: modelData.present ? Theme.surfaceVariantText : Theme.error
                            }
                        }
                    }
                }
            }
        }
    }
}

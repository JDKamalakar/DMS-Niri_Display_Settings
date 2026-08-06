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

    Column {
        id: mainSettingsCol
        width: parent.width
        spacing: Theme.spacingL

        function loadValue(key, def) {
            return PluginService.loadPluginData(root.pluginId, key, def);
        }

        function saveValue(key, val) {
            PluginService.savePluginData(root.pluginId, key, val);
        }

        function loadValueInternal() {
            autoBehaviorsRect.loadValue();
            interfaceRect.loadValue();
        }
        
        Component.onCompleted: loadValueInternal()

        // --- Automatic Behaviors Section ---
        Rectangle {
            id: autoBehaviorsRect
            width: parent.width
            height: autoBehaviorsGroup.implicitHeight + Theme.spacingM * 2
            color: Theme.surfaceContainer
            radius: Theme.cornerRadius
            border.color: Theme.outline
            border.width: 1
            opacity: 0.8

            function loadValue() {
                connectionDropdown.loadValue();
                fallbackToggle.loadValue();
                disableInternalToggle.loadValue();
                profilesToggle.loadValue();
                fallbackDisplayField.loadValue();
            }

            Column {
                id: autoBehaviorsGroup
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingM

                Column {
                    width: parent.width
                    spacing: Theme.spacingS

                    // Section Title
                    StyledText {
                        text: I18n.tr("Automatic Behaviors")
                        width: parent.width
                        font.weight: Font.Medium
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                    }

                    // When monitor is connected
                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM
                        DankIcon { name: "cable"; size: 22; Layout.alignment: Qt.AlignVCenter; opacity: 0.8 }
                        Column {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Theme.spacingXXS
                            StyledText { text: I18n.tr("When monitor is connected"); width: parent.width; font.weight: Font.Medium; color: Theme.surfaceText }
                            StyledText { text: I18n.tr("Choose what happens automatically when an external monitor is plugged in"); font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
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
                            var savedVal = mainSettingsCol.loadValue(settingKey, defaultValue);
                            var found = optionList.find(function(opt) { return opt.value === savedVal; });
                            currentValue = found ? found.label : optionList[0].label;
                        }

                        Component.onCompleted: loadValue()

                        onValueChanged: value => {
                            var found = optionList.find(function(opt) { return opt.label === value; });
                            if (found) {
                                mainSettingsCol.saveValue(settingKey, found.value);
                            }
                        }
                    }

                    Item { width: 1; height: Theme.spacingXS }

                    // Enable safety fallback
                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM
                        DankIcon { name: "security"; size: 22; Layout.alignment: Qt.AlignVCenter; opacity: 0.8 }
                        Column {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Theme.spacingXXS
                            StyledText { text: I18n.tr("Enable safety fallback"); width: parent.width; font.weight: Font.Medium; color: Theme.surfaceText }
                            StyledText { text: I18n.tr("Automatically re-enable the laptop screen if all external monitors are disconnected"); font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
                        }
                        DankToggle {
                            id: fallbackToggle
                            Layout.alignment: Qt.AlignVCenter
                            property string settingKey: "enableFallback"
                            checked: true
                            
                            function loadValue() {
                                var val = mainSettingsCol.loadValue(settingKey, true);
                                checked = (val === true || val === "true");
                            }
                            Component.onCompleted: loadValue()
                            
                            onToggled: isChecked => {
                                mainSettingsCol.saveValue(settingKey, isChecked);
                            }
                        }
                    }

                    Item { width: 1; height: Theme.spacingXS }

                    // Disable internal display option
                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM
                        DankIcon { name: "laptop_disabled"; size: 22; Layout.alignment: Qt.AlignVCenter; opacity: 0.8 }
                        Column {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Theme.spacingXXS
                            StyledText { text: I18n.tr("Disable internal display option"); width: parent.width; font.weight: Font.Medium; color: Theme.surfaceText }
                            StyledText { text: I18n.tr("Remove the internal display option and the 'Internal Only' profile selection from both UIs"); font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
                        }
                        DankToggle {
                            id: disableInternalToggle
                            Layout.alignment: Qt.AlignVCenter
                            property string settingKey: "disableInternalOption"
                            checked: false
                            
                            function loadValue() {
                                var val = mainSettingsCol.loadValue(settingKey, false);
                                checked = (val === true || val === "true");
                            }
                            Component.onCompleted: loadValue()
                            
                            onToggled: isChecked => {
                                mainSettingsCol.saveValue(settingKey, isChecked);
                            }
                        }
                    }

                    Item { width: 1; height: Theme.spacingXS }

                    // Show display profiles
                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM
                        DankIcon { name: "view_carousel"; size: 22; Layout.alignment: Qt.AlignVCenter; opacity: 0.8 }
                        Column {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Theme.spacingXXS
                            StyledText { text: I18n.tr("Show display profiles"); width: parent.width; font.weight: Font.Medium; color: Theme.surfaceText }
                            StyledText { text: I18n.tr("Show saved display configuration profiles under the manual controls section"); font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
                        }
                        DankToggle {
                            id: profilesToggle
                            Layout.alignment: Qt.AlignVCenter
                            property string settingKey: "showDisplayProfiles"
                            checked: false
                            
                            function loadValue() {
                                var val = mainSettingsCol.loadValue(settingKey, false);
                                checked = (val === true || val === "true");
                            }
                            Component.onCompleted: loadValue()
                            
                            onToggled: isChecked => {
                                mainSettingsCol.saveValue(settingKey, isChecked);
                            }
                        }
                    }

                    Item { width: 1; height: Theme.spacingXS }

                    // Preferred internal display
                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM
                        DankIcon { name: "display_settings"; size: 22; Layout.alignment: Qt.AlignVCenter; opacity: 0.8 }
                        Column {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Theme.spacingXXS
                            StyledText { text: I18n.tr("Preferred internal display"); width: parent.width; font.weight: Font.Medium; color: Theme.surfaceText }
                            StyledText { text: I18n.tr("The name of your laptop display (e.g. eDP-1). Leave empty for auto-detection."); font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
                        }
                    }

                    DankTextField {
                        id: fallbackDisplayField
                        property string settingKey: "fallbackDisplay"
                        property string defaultValue: ""
                        width: parent.width
                        placeholderText: "eDP-1"
                        
                        function loadValue() {
                            text = mainSettingsCol.loadValue(settingKey, defaultValue);
                        }
                        Component.onCompleted: loadValue()
                        onEditingFinished: {
                            mainSettingsCol.saveValue(settingKey, text);
                        }
                    }
                }
            }
        }

        // --- Interface Settings Section ---
        Rectangle {
            id: interfaceRect
            width: parent.width
            height: interfaceGroup.implicitHeight + Theme.spacingM * 2
            color: Theme.surfaceContainer
            radius: Theme.cornerRadius
            border.color: Theme.outline
            border.width: 1
            opacity: 0.8

            function loadValue() {
                dimSlider.loadValue();
                transSlider.loadValue();
            }

            Column {
                id: interfaceGroup
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingM

                Column {
                    width: parent.width
                    spacing: Theme.spacingS

                    // Section Title
                    StyledText {
                        text: I18n.tr("Interface Settings")
                        width: parent.width
                        font.weight: Font.Medium
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                    }

                    // Backdrop Dim Slider
                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM
                        DankIcon { name: "palette"; size: 22; Layout.alignment: Qt.AlignVCenter; opacity: 0.8 }
                        Column {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Theme.spacingXXS
                            StyledText { text: I18n.tr("Backdrop Dim"); width: parent.width; font.weight: Font.Medium; color: Theme.surfaceText }
                            StyledText { text: I18n.tr("Choose the backdrop overlay dim level for the fullscreen settings modal"); font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
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
                                id: dimResetIcon
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
                                    mainSettingsCol.saveValue(dimSlider.settingKey, dimSlider.defaultValue / 100);
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
                            const savedVal = mainSettingsCol.loadValue(settingKey, defaultValue / 100);
                            value = Math.round(parseFloat(savedVal) * 100);
                        }
                        Component.onCompleted: loadValue()
                        onSliderValueChanged: newValue => {
                            value = newValue;
                            mainSettingsCol.saveValue(settingKey, newValue / 100);
                        }
                    }

                    Item { width: 1; height: Theme.spacingXS }

                    // UI Transparency Slider
                    RowLayout {
                        width: parent.width
                        spacing: Theme.spacingM
                        DankIcon { name: "opacity"; size: 22; Layout.alignment: Qt.AlignVCenter; opacity: 0.8 }
                        Column {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: Theme.spacingXXS
                            StyledText { text: I18n.tr("UI Transparency"); width: parent.width; font.weight: Font.Medium; color: Theme.surfaceText }
                            StyledText { text: I18n.tr("Choose the UI transparency level for the settings modal cards"); font.pixelSize: Theme.fontSizeSmall; color: Theme.surfaceVariantText; width: parent.width; wrapMode: Text.WordWrap }
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
                                id: transResetIcon
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
                                    mainSettingsCol.saveValue(transSlider.settingKey, transSlider.defaultValue / 100);
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
                            const savedVal = mainSettingsCol.loadValue(settingKey, defaultValue / 100);
                            value = Math.round(parseFloat(savedVal) * 100);
                        }
                        Component.onCompleted: loadValue()
                        onSliderValueChanged: newValue => {
                            value = newValue;
                            mainSettingsCol.saveValue(settingKey, newValue / 100);
                        }
                    }
                }
            }
        }

        // --- Commands & Shortcuts Section ---
        Rectangle {
            id: shortcutsRect
            width: parent.width
            height: shortcutsGroup.implicitHeight + Theme.spacingM * 2
            color: Theme.surfaceContainer
            radius: Theme.cornerRadius
            border.color: Theme.outline
            border.width: 1
            opacity: 0.8

            Column {
                id: shortcutsGroup
                anchors.fill: parent
                anchors.margins: Theme.spacingM
                spacing: Theme.spacingM

                Column {
                    width: parent.width
                    spacing: Theme.spacingS

                    StyledText {
                        text: I18n.tr("Commands & Shortcuts")
                        width: parent.width
                        font.weight: Font.Medium
                        font.pixelSize: Theme.fontSizeMedium
                        color: Theme.surfaceText
                    }

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


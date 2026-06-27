import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "niriDSA"

    SettingsCard {
        StyledText {
            width: parent.width
            text: I18n.tr("Automatic Behaviors")
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Font.Medium
            color: Theme.surfaceText
        }

        SelectionSetting {
            settingKey: "connectionAction"
            label: I18n.tr("When monitor is connected")
            description: I18n.tr("Choose what happens automatically when an external monitor is plugged in")
            options: [
                { label: I18n.tr("Show Menu"), value: "show_menu" },
                { label: I18n.tr("External Only"), value: "external_only" },
                { label: I18n.tr("Extended"), value: "extend" },
                { label: I18n.tr("Internal Only"), value: "internal_only" },
                { label: I18n.tr("Mirror"), value: "mirror" },
                { label: I18n.tr("Do Nothing"), value: "none" }
            ]
            defaultValue: "show_menu"
        }

        ToggleSetting {
            settingKey: "enableFallback"
            label: I18n.tr("Enable safety fallback")
            description: I18n.tr("Automatically re-enable the laptop screen if all external monitors are disconnected")
            defaultValue: true
        }

        ToggleSetting {
            settingKey: "disableInternalOption"
            label: I18n.tr("Disable internal display option")
            description: I18n.tr("Remove the internal display option and the 'Internal Only' profile selection from both UIs")
            defaultValue: false
        }

        ToggleSetting {
            settingKey: "showDisplayProfiles"
            label: I18n.tr("Show display profiles")
            description: I18n.tr("Show saved display configuration profiles under the manual controls section")
            defaultValue: false
        }

        StringSetting {
            settingKey: "fallbackDisplay"
            label: I18n.tr("Preferred internal display")
            description: I18n.tr("The name of your laptop display (e.g. eDP-1). Leave empty for auto-detection.")
            placeholder: "eDP-1"
        }
    }

    Component {
        id: sliderSettingComponent
        Column {
            width: parent ? parent.width : 0
            spacing: Theme.spacingS

            property string iconName: parent ? parent.iconName : ""
            property string labelText: parent ? parent.labelText : ""
            property string descriptionText: parent ? parent.descriptionText : ""
            property int sliderDefaultValue: parent ? parent.sliderDefaultValue : 0
            property string sliderSettingKey: parent ? parent.sliderSettingKey : ""

            function loadValue() {
                mySlider.loadValue();
            }

            RowLayout {
                width: parent.width
                spacing: Theme.spacingM

                DankIcon {
                    name: iconName
                    size: 22
                    Layout.alignment: Qt.AlignVCenter
                    opacity: 0.8
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: Theme.spacingXXS
                    StyledText {
                        text: labelText
                        width: parent.width
                        font.weight: Font.Medium
                        color: Theme.surfaceText
                    }
                    StyledText {
                        text: descriptionText
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }
                }

                Rectangle {
                    id: resetBtn
                    width: 32; height: 32
                    radius: Theme.cornerRadius
                    Layout.alignment: Qt.AlignVCenter
                    color: resetMa.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainerHigh
                    border.color: resetMa.containsMouse ? Theme.primary : Theme.outline
                    border.width: 1
                    opacity: mySlider.value !== mySlider.defaultValue ? (resetMa.containsMouse ? 1.0 : 0.9) : 0.0
                    visible: opacity > 0
                    scale: resetMa.pressed ? 0.9 : (resetMa.containsMouse ? 1.05 : 1.0)
                    
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                    DankRipple { 
                        id: resetRip
                        anchors.fill: parent
                        cornerRadius: parent.radius
                        rippleColor: Theme.primary 
                    }

                    DankIcon {
                        id: resetIcon
                        name: "restart_alt"
                        size: 18
                        anchors.centerIn: parent
                        color: resetMa.containsMouse ? Theme.primary : Theme.surfaceVariantText
                        Behavior on color { ColorAnimation { duration: 150 } }

                        SequentialAnimation {
                            running: resetMa.containsMouse
                            loops: Animation.Infinite
                            onStopped: resetIcon.rotation = 0
                            NumberAnimation { target: resetIcon; property: "rotation"; from: 0; to: 8; duration: 200; easing.type: Easing.OutQuad }
                            NumberAnimation { target: resetIcon; property: "rotation"; from: 8; to: -8; duration: 400; easing.type: Easing.InOutQuad }
                            NumberAnimation { target: resetIcon; property: "rotation"; from: -8; to: 0; duration: 200; easing.type: Easing.InQuad }
                        }
                    }

                    MouseArea {
                        id: resetMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            resetAnim.restart();
                            root.saveValue(sliderSettingKey, sliderDefaultValue / 100);
                        }
                        onPressed: (m) => resetRip.trigger(m.x, m.y)
                    }
                }
            }

            NumberAnimation {
                id: resetAnim
                target: mySlider
                property: "value"
                to: mySlider.defaultValue
                duration: 300
                easing.type: Easing.OutCubic
            }

            DankSlider {
                id: mySlider
                property int defaultValue: sliderDefaultValue
                property string settingKey: sliderSettingKey
                width: parent.width
                minimum: 0
                maximum: 100
                step: 1
                unit: "%"
                
                function loadValue() {
                    if (settingKey === "") return;
                    const savedVal = root.loadValue(settingKey, defaultValue / 100);
                    value = Math.round(parseFloat(savedVal) * 100);
                }
                Component.onCompleted: loadValue()
                onSettingKeyChanged: loadValue()
                onSliderValueChanged: newValue => {
                    value = newValue;
                    root.saveValue(settingKey, newValue / 100);
                }
            }
        }
    }

    SettingsCard {
        StyledText {
            width: parent.width
            text: I18n.tr("Interface Settings")
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Font.Medium
            color: Theme.surfaceText
        }

        // --- Backdrop Dim Setting Row ---
        Loader {
            id: dimSettingRow
            width: parent.width
            sourceComponent: sliderSettingComponent
            asynchronous: true
            
            property string iconName: "palette"
            property string labelText: I18n.tr("Backdrop Dim")
            property string descriptionText: I18n.tr("Choose the backdrop overlay dim level for the fullscreen settings modal")
            property int sliderDefaultValue: 20
            property string sliderSettingKey: "backdropDim"

            function loadValue() {
                if (item) item.loadValue();
            }
        }

        // --- UI Transparency Setting Row ---
        Loader {
            id: transSettingRow
            width: parent.width
            sourceComponent: sliderSettingComponent
            asynchronous: true
            
            property string iconName: "opacity"
            property string labelText: I18n.tr("UI Transparency")
            property string descriptionText: I18n.tr("Choose the UI transparency level for the settings modal cards")
            property int sliderDefaultValue: 50
            property string sliderSettingKey: "uiTransparency"

            function loadValue() {
                if (item) item.loadValue();
            }
        }
    }

    SettingsCard {
        StyledText {
            width: parent.width
            text: I18n.tr("Commands & Shortcuts")
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Font.Medium
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

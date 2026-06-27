import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import qs.Common
import qs.Widgets

Item {
    id: card
    property string iconName
    property string label
    property string shortcut
    property bool disabled: false
    property bool isActive: false
    property bool isFirst: false
    property bool isLast: false
    property bool hovered: mouseArea.containsMouse && !disabled

    signal clicked()

    height: 44

    Shape {
        id: cardBg
        anchors.fill: parent
        property real innerRadius: 6
        property real outerRadius: 12
        
        property real tlr: card.isActive ? (height / 2) - 0.5 : (card.isFirst ? outerRadius : innerRadius)
        property real trr: card.isActive ? (height / 2) - 0.5 : (card.isFirst ? outerRadius : innerRadius)
        property real blr: card.isActive ? (height / 2) - 0.5 : (card.isLast ? outerRadius : innerRadius)
        property real brr: card.isActive ? (height / 2) - 0.5 : (card.isLast ? outerRadius : innerRadius)

        property real tlrAnim: tlr; Behavior on tlrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
        property real trrAnim: trr; Behavior on trrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
        property real blrAnim: blr; Behavior on blrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }
        property real brrAnim: brr; Behavior on brrAnim { NumberAnimation { duration: 600; easing.type: Easing.OutExpo } }

        property color paintColor: card.disabled ? "transparent" : (card.isActive
            ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.18)
            : card.hovered
                ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.1)
                : Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.04))
        Behavior on paintColor { ColorAnimation { duration: 150 } }
        
        property color paintBorder: card.disabled ? Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.05) : (card.isActive
            ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.6)
            : card.hovered
                ? Qt.rgba(Theme.primary.r, Theme.primary.g, Theme.primary.b, 0.4)
                : Qt.rgba(Theme.secondary.r, Theme.secondary.g, Theme.secondary.b, 0.15))
        Behavior on paintBorder { ColorAnimation { duration: 150 } }

        ShapePath {
            fillColor: cardBg.paintColor
            strokeColor: cardBg.paintBorder
            strokeWidth: 1
            startX: 0.5 + cardBg.tlrAnim; startY: 0.5

            PathLine { x: cardBg.width - 0.5 - cardBg.trrAnim; y: 0.5 }
            PathArc { x: cardBg.width - 0.5; y: 0.5 + cardBg.trrAnim; radiusX: cardBg.trrAnim; radiusY: cardBg.trrAnim; direction: PathArc.Clockwise }
            
            PathLine { x: cardBg.width - 0.5; y: cardBg.height - 0.5 - cardBg.brrAnim }
            PathArc { x: cardBg.width - 0.5 - cardBg.brrAnim; y: cardBg.height - 0.5; radiusX: cardBg.brrAnim; radiusY: cardBg.brrAnim; direction: PathArc.Clockwise }
            
            PathLine { x: 0.5 + cardBg.blrAnim; y: cardBg.height - 0.5 }
            PathArc { x: 0.5; y: cardBg.height - 0.5 - cardBg.blrAnim; radiusX: cardBg.blrAnim; radiusY: cardBg.blrAnim; direction: PathArc.Clockwise }
            
            PathLine { x: 0.5; y: 0.5 + cardBg.tlrAnim }
            PathArc { x: 0.5 + cardBg.tlrAnim; y: 0.5; radiusX: cardBg.tlrAnim; radiusY: cardBg.tlrAnim; direction: PathArc.Clockwise }
        }
    }

    DankRipple { id: pRip; anchors.fill: parent; cornerRadius: cardBg.tlrAnim; rippleColor: Theme.primary }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: Theme.spacingS

        DankIcon {
            name: card.iconName
            size: 18
            color: card.disabled ? Theme.withAlpha(Theme.surfaceText, 0.4) : (card.isActive ? Theme.primary : Theme.surfaceVariantText)
            Layout.alignment: Qt.AlignVCenter
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        StyledText {
            text: card.label
            font.pixelSize: Theme.fontSizeSmall
            font.weight: card.isActive ? Font.Bold : Font.Normal
            color: card.disabled ? Theme.withAlpha(Theme.surfaceText, 0.4) : (card.isActive ? Theme.primary : Theme.surfaceText)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        DankIcon { 
            name: "check_circle"; size: 16; color: Theme.primary
            scale: card.isActive ? 1.0 : 0.0
            opacity: card.isActive ? 1.0 : 0.0
            visible: card.isActive
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        Rectangle {
            width: shortcutText.implicitWidth + Theme.spacingM
            height: shortcutText.implicitHeight + Theme.spacingS - 2
            radius: Theme.cornerRadius / 2
            color: card.hovered ? Theme.withAlpha(Theme.primary, 0.25) : Theme.withAlpha(Theme.surfaceVariant, 0.4)
            border.width: 1
            border.color: card.hovered ? Theme.withAlpha(Theme.primary, 0.4) : Theme.withAlpha(Theme.surfaceVariant, 0.2)
            Layout.alignment: Qt.AlignVCenter
            visible: card.shortcut !== "" && !card.isActive

            Behavior on color { ColorAnimation { duration: 150 } }

            StyledText {
                id: shortcutText
                text: card.shortcut
                font.pixelSize: Theme.fontSizeSmall - 1
                font.weight: Font.DemiBold
                color: card.hovered ? Theme.primary : Theme.surfaceText
                opacity: 0.8
                anchors.centerIn: parent
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: !card.disabled
        cursorShape: card.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        onClicked: {
            if (!card.disabled) {
                card.clicked();
            }
        }
        onPressed: (m) => pRip.trigger(m.x, m.y)
    }
}

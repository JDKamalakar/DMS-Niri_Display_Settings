import QtQuick
import "../displayMirror" as DM

Item {
    Component.onCompleted: {
        console.log(DM.MirrorState.hasActiveMirrors)
    }
}

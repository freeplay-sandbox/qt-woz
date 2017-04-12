import QtQuick 2.2

Object {
        id:draggableObject
        opacity: 0.8
        property bool dragged: false
        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: parent
            onPressed: parent.dragged = true
        }
}

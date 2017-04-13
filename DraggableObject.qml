import QtQuick 2.2
import Ros 1.0

Object {
        id:draggableObject
        opacity: 0.8
        property bool dragged: false
        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: parent
            onPressed: parent.dragged = true
            onReleased: {
                publisher.publish()
            }
        }
        RosPosePublisher {
            id: publisher
            pixelscale: zoo.pixel2meter

            target: parent
            frame: parent.name
            origin: mapOrigin.name

        }
}

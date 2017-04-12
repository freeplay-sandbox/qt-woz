import QtQuick 2.2

import Ros 1.0

Item {
        id:object
        width: 2*parent.height * zoo.physicalCubeSize / zoo.physicalMapWidth
        height: width

        objectName: "interactive"

        property string name: ""
        property string image: "res/cube.svg"

        property double bbratio: 1 // set later (cf below) once paintedWidth is known
        property alias origin: imageOrigin

        Image {
            id: image
            fillMode: Image.PreserveAspectFit
            anchors.fill: parent
            source: parent.image

            Item {
                // this item sticks to the 'visual' origin of the object, taking into account
                // possible margins appearing when resizing
                id: imageOrigin
                rotation: parent.rotation
                x: parent.x + (parent.width - parent.paintedWidth)/2
                y: parent.y + (parent.height - parent.paintedHeight)/2
            }
            onPaintedWidthChanged: {
                bbratio= image.paintedWidth/image.sourceSize.width;
            }

        }

//   PinchArea {
//           anchors.fill: parent
//           pinch.target: parent
//           pinch.minimumRotation: -360
//           pinch.maximumRotation: 360
//           //pinch.minimumScale: 1
//           //pinch.maximumScale: 1
//           pinch.dragAxis: Pinch.XAndYAxis

//           MouseArea {
//                   anchors.fill: parent
//                   drag.target: cube
//                   scrollGestureEnabled: false
//           }
//   }

    Item {
        id: objectCenter
        anchors.centerIn: parent
        rotation: parent.rotation
        x: parent.x
        y: parent.y
        TFListener {
            id:tf
            frame: parent.parent.name
            origin: mapOrigin
            parentframe: mapOrigin.name
            pixelscale: zoo.pixel2meter
            onPositionChanged:{

                console.log("width" + parent.parent.width);
                parent.parent.x= x - parent.parent.width/2
                parent.parent.y= y - parent.parent.height/2
                parent.parent.rotation= rotation
            }
        }
    }

    function isIn(tx, ty) {
        return (tx > x) && (tx < x + width) && (ty > y) && (ty < y + height);
    }

}

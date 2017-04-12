import QtQuick 2.2

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

    function isIn(tx, ty) {
        return (tx > x) && (tx < x + width) && (ty > y) && (ty < y + height);
    }

}

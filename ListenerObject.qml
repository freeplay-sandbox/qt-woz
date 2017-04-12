import QtQuick 2.2

import Ros 1.0

Object {
        id:listenerObject

        TFListener {
            id:tf
            frame: parent.name
            origin: mapOrigin
            parentframe: mapOrigin.name
            pixelscale: zoo.pixel2meter
            onPositionChanged:{
                parent.x= x - parent.width/2
                parent.y= y - parent.height/2
                parent.rotation= rotation
            }
        }
}

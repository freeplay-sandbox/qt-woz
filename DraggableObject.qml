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
                if(dist(dragger, listener)<10){
                }
                else{
                    actionPublisher.makeMove(listener, dragger, parent.name)
                }
            }
        }
        function dist(a,b){
            return Math.pow(a.x-b.x,2)+Math.pow(a.y-b.y,2)
        }
}

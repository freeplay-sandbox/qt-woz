import QtQuick 2.2
import Ros 1.0

Object {
        id:draggableObject
        opacity: 0.8
        property bool dragged: false
        property bool wasSelected: false
        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: parent
            onPressed: {
                resetIfProposing()
                wasSelected = character.selected
                character.select()
                dragged = true
            }
            onReleased: {
                if(dist(dragger, listener)<5000){
                    resetGhost()
                    character.selected = !wasSelected
                }
                else{
                    startArrow()
                    actionPublisher.makeMove(listener, dragger, parent.name)
                }
            }
        }
        function dist(a,b){
            return Math.pow(a.x-b.x,2)+Math.pow(a.y-b.y,2)
        }
}

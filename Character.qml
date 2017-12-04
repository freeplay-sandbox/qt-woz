import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import Ros 1.0

Item {
    id: character
    property double scale: 1.0
    property double bbScale: 1.0
    width: 2 * scale * parent.parent.height * zoo.physicalCubeSize / zoo.physicalMapWidth
    x: 0
    y: 0
    rotation: 0
    property double life: 1

    property string name: ""
    property string image: "res/cube.svg"
    property int epsilon: 20
    property bool selected: false
    property bool focused: false
    visible: false

    ListenerObject {
        id: listener
        name: parent.name
        image: parent.image
        property double scale: 1.0
        property double bbScale: 1.0
        width: parent.width

        onXChanged: testDifference()
        onYChanged: testDifference()
        onRotationChanged: testDifference()
    }

    onLifeChanged: {
        if (life > 0)
            visible = true
        else
            visible = false
    }

    onVisibleChanged: {
        if (visible == false)
            selected=false
    }

    Lifebar {
        id: lifeSlider
        ratio: life
        enabled:false

        anchors.horizontalCenter: listener.horizontalCenter
        anchors.verticalCenter: listener.verticalCenter
    }

    Rectangle{
        id: circle
        width: 1.1*Math.max(parent.width,parent.height)
        height: width
        color: "transparent"
        border.color: "cyan"
        border.width: 5
        radius: width
        anchors.horizontalCenter: listener.horizontalCenter
        anchors.verticalCenter: listener.verticalCenter
        visible: selected
    }

    AnimatedArrow {
        id: arrow
        origin: listener
        end: dragger
        duration: 1000
        color: "red"
    }

    DraggableObject {
        id: dragger
        name: parent.name
        image: parent.image
        //origin: listener
        property double scale: 1.0
        property double bbScale: 1.0

        width: parent.width
      /*    onDraggedChanged: {
          if(dragged){
                arrow.visible = true
            }
            else
                arrow.visible = false
        }*/
    }

    function resetGhost(){
        dragger.dragged = false
        arrow.visible = false
        testDifference()
    }

    function testDifference(){
        arrow.visible = false
        if (dragger.dragged){
            if (Math.abs(listener.x-dragger.x)< epsilon && Math.abs(listener.y-dragger.y) < epsilon)
                dragger.dragged = false
        }
        else{
            dragger.x =listener.x
            dragger.y =listener.y
            dragger.rotation =listener.rotation
        }
    }

    function setDraggerPose(x,y,z){
        dragger.dragged = true
        var angle = listener.rotation * 2 * Math.PI / 360
        dragger.x = listener.x + x*Math.cos(angle) - y*Math.sin(angle)
        dragger.y = listener.y + x*Math.sin(angle) + y*Math.cos(angle)

        startArrow()
        actionPublisher.prepareMove(listener, dragger, name)
        var toReturn=[]
        toReturn.push(dragger.x)
        toReturn.push(dragger.y)
        return toReturn
    }

    function click(){
        selected = !selected
    }

    function select(){
        selected = true
        arrow.visible = false
    }

    onSelectedChanged: {
        if(selected){
            addSelectedItem(name)
        }
        else{
            removeSelectedItem(name)
            arrow.visible = false
        }
    }
    function hideArrow(){
        arrow.visible = false
    }
    function startArrow(){
        arrow.origin = listener
        arrow.end = dragger
        arrow.start()
        arrowTimer.start()
    }
    Timer{
        id: arrowTimer
        interval: 20;running: false; repeat: false
        onTriggered: {
            arrow.visible = true
        }
    }
    onFocusedChanged: {
        if(focused)
            circle.border.color = "darkorange"
        else
            circle.border.color = "cyan"
    }
}

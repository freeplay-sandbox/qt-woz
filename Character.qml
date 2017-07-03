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
    ListenerObject {
        id: listener

        name: parent.name
        image: parent.image
        property double scale: 1.0
        property double bbScale: 1.0
        width: parent.width

        x: 0.1 * parent.width + Math.random() * 0.8 * parent.width
        y: 0.1 * parent.height + Math.random() * 0.8 * parent.height
        rotation: -30 + Math.random() * 60
        onXChanged: testDifference()
        onYChanged: testDifference()
        onRotationChanged: testDifference()
    }

    ProgressBar {
        id: lifeSlider
        anchors.bottom: listener.top
        anchors.bottomMargin: listener.height/10
        anchors.horizontalCenter: listener.horizontalCenter
        width: listener.width
        value: life
        height: listener.height/10

        style: ProgressBarStyle {
            background: Rectangle {
                radius: 2
                color: "Crimson"
                border.color: "black"
                border.width: 1
                implicitWidth: 200
                implicitHeight: 24
            }
            progress: Rectangle {
                color: "lime"
                border.color: "black"
                implicitWidth: 200
                implicitHeight: 24
            }
        }
    }

    Rectangle{
        id: circle
        width: 1.1*Math.max(parent.width,parent.height)
        height: width
        color: "transparent"
        border.color: "red"
        border.width: 5
        radius: width
        x:listener.x
        y:listener.y
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
        testDifference()
    }

    function testDifference(){
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

        arrow.origin = listener
        arrow.end = dragger
        arrow.start()
        arrow.visible = true
        actionPublisher.prepareMove(listener, dragger, name)
        autoExe.start()
    }

    function click(){
        selected = !selected
    }

    function select(){
        selected = true
    }

    onSelectedChanged: {
        if(selected){
            addSelectedItem(name)
        }
        else{
            removeSelectedItem(name)
        }
    }
    function cancelMove(){
        arrow.visible = false
        resetGhost()
    }
    function hideArrow(){
        arrow.visible = false
    }
}

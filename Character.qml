import QtQuick 2.0
import Ros 1.0

Item {
    id: character
    property double scale: 1.0
    property double bbScale: 1.0
    width: scale * 2 * parent.parent.height * zoo.physicalCubeSize / zoo.physicalMapWidth
    x: 0
    y: 0
    rotation: 0

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
        duration: 2000
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
    }

    RosActionPublisher {
        id: publisher
        pixelscale: zoo.pixel2meter
        target: dragger
        frame: parent.name
        origin: listener
        topic: "sparc/selected_action"
        function updateList(){
            strings.splice(0,strings.length)
            for(var i=0;i<selectedItems.length;i++){
                strings.push(selectedItems[i])
            }
        }
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
        console.log("setting "+name+" to "+x+" "+y+" "+z)
        dragger.dragged = true
        dragger.x = x
        dragger.y = y
        actionToExecute = "move_"+name
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
    function move(){
        publisher.publish()
        arrow.visible = false
    }
}

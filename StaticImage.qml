import QtQuick 2.0
import Ros 1.0

Item {
    id: staticImage
    property double scale: 1.0
    width: scale * 2 * parent.parent.height * zoo.physicalCubeSize / zoo.physicalMapWidth
    x: 0
    y: 0
    rotation: 0

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
    }

    onVisibleChanged: {
        if (visible == false)
            selected=false
    }

    Rectangle{
        id: circle
        width: 1.1*Math.max(parent.width,parent.height)
        height: width
        color: "transparent"
        border.color: "cyan"
        border.width: 5
        radius: width
        x:listener.x
        y:listener.y
        visible: selected
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

    onFocusedChanged: {
        if(focused)
            circle.border.color = "darkorange"
        else
            circle.border.color = "cyan"
    }
}

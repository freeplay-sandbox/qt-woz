import QtQuick 2.2
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import QtQuick.Controls 1.4


import Ros 1.0

Window {

    id: window

    visible: true
    //visibility: Window.FullScreen
    //width: Screen.width
    //height: Screen.height
    width:800
    height: 600

    property int prevWidth:800
    property int prevHeight:600

    onWidthChanged: {
        prevWidth=width;
    }
    onHeightChanged: {
        prevHeight=height;
    }

    color: "white"
    title: qsTr("Zoo GUI")
    Item{
        id: eventDisplay
        anchors.left: parent.left
        height: 2./3*parent.height
        anchors.top: parent.top
        width: parent.width/3

        Component {
            id: eventStyle
            Item {
                width: parent.width; height: 20
                Column {
                    Text { text: name }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: eventList.currentIndex = index
                }
                Component.onCompleted: eventList.positionViewAtEnd()
            }
        }

        ListView {
            id: eventList
            anchors.fill: parent
            model: eventModel
            delegate: eventStyle
            highlight: Rectangle { color: "lightsteelblue"; radius: 5 }
            highlightMoveVelocity:2000
            focus: true
        }

        ListModel {
            id:  eventModel
        }
    }
    Item{
        id: statePanel
        anchors.top:eventDisplay.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: eventDisplay.right

        Component {
            id: stateStyle
            Item{
                id:item
                property bool select: selected
                Label{
                    text:textLabel
                    Rectangle {
                        id: rec; anchors.fill: parent; z:-1; color: "white"; radius: 5
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                selected = true
                            }
                        }
                    }
                }
                onSelectChanged:{
                    if(select)
                        rec.color = "lightsteelblue"
                    else
                        rec.color = "white"
                }
            }
        }

        GridView {
            id: itemList
            anchors.fill: parent
            model: stateModel
            delegate: stateStyle
            cellWidth: width/3.5
            cellHeight: height/10
            //flow: GridView.FlowTopToBottom
            focus: true
        }

        ListModel {
            id:  stateModel
            ListElement{ textLabel: "Zebra"; selected:false}
            ListElement{ textLabel:""}
            ListElement{ textLabel:""}
            ListElement{ textLabel: "Elephant"}
            ListElement{ textLabel:""}
            ListElement{ textLabel:""}
            ListElement{ textLabel: "Leopard"}
            ListElement{ textLabel:""}
            ListElement{ textLabel:""}
            ListElement{ textLabel: "Lion"}
            ListElement{ textLabel:""}
            ListElement{ textLabel:""}
            ListElement{ textLabel: "Giraffe"}
            ListElement{ textLabel:""}
            ListElement{ textLabel:""}
            ListElement{ textLabel: "rhino"}
            ListElement{ textLabel:""}
            ListElement{ textLabel:""}
            ListElement{ textLabel: "Crocodile"}
            ListElement{ textLabel:""}
            ListElement{ textLabel:""}
            ListElement{ textLabel: "Hippo"}
            ListElement{ textLabel:""}
            ListElement{ textLabel:""}
            ListElement{ textLabel: "Toychild1"}
            ListElement{ textLabel:""}
            ListElement{ textLabel:""}
            ListElement{ textLabel: "Toychild4"}
            ListElement{ textLabel:""}
            ListElement{ textLabel:""}

        }

        RosArrayIntSubscriber {
            id: stateSub
            topic: "state"
            onDataChanged: {
                var names = ["zebra","elephant","leopard","lion","giraffe","rhino","crocodile","hippo","toychild1","toychild4"]
                for (var i = 0; i < names.length; i++){
                    var zone = "undefined"
                    switch (data[dimensions[1]*i]){
                    case 0: zone = "black"; break
                    case 1: zone = "white"; break
                    case 2: zone = "purple"; break
                    case 3: zone = "blue"; break
                    case 4: zone = "green"; break
                    case 5: zone = "yellow"; break
                    case 6: zone = "red"; break
                    default: break
                    }
                    var zoneIdx = String(data[dimensions[1]*i+1])
                    stateModel.setProperty(3*i+1,"textLabel", zone)
                    stateModel.setProperty(3*i+2,"textLabel", zoneIdx)
                }


            }
        }
    }

    Grid{
        id:buttonPannel
        anchors.left: eventDisplay.right
        anchors.bottom: parent.bottom
        anchors.top: zoo.bottom
        anchors.right: parent.right
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        columns: 5
        rows:2
        Button{
            text: "Reset Selected States"
            onClicked: resetSelectedStates()
        }
        Button{
            text: "button 2"
        }
        Button{
            text: "button 3"
        }
        Button{
            text: "button 4"
        }
        Button{
            text: "button 5"
        }
        Button{
            text: "button 6"
        }

    }

    Item {
        id: zoo

        anchors.left: eventDisplay.right
        anchors.top: parent.top
        width: 2*parent.width/3
        height: 2*parent.height/3

        Rectangle {
            anchors.fill: parent
            color: "red"
            border.color: "blue"
            border.width: 5
            radius: 10
        }


        //property double physicalMapWidth: 553 //mm (desktop acer monitor)
        property double physicalMapWidth: 600 //mm (sandtray)
        property double physicalCubeSize: 30 //mm
        property double pixel2meter: (physicalMapWidth / 1000) / map.paintedWidth

        property bool showRobotChild: false
        property bool publishRobotChild: false

        Image {
            id: map
            fillMode: Image.PreserveAspectFit
            anchors.fill: parent
            source: "image://rosimage/sandbox/image"
            cache: false
            Timer {
                id: imageLoder
                interval: 1000
                repeat: true
                running: true
                onTriggered: {
                    map.source = "";
                    map.source = "image://rosimage/sandbox/image";
                    interval = 5000
                }
            }

            Item {
                // this item sticks to the 'visual' origin of the map, taking into account
                // possible margins appearing when resizing
                id: mapOrigin
                property string name: "sandtray"
                rotation: map.rotation
                x: map.x + (map.width - map.paintedWidth)/2
                y: map.y + (map.height - map.paintedHeight)/2
            }
        }

        TFListener {
            id: robotArmReach
            x: window.width/2
            y: window.height/2
            z:100

            visible: zoo.showRobotChild

            frame: "arm_reach"
            origin: mapOrigin
            parentframe: mapOrigin.name
            pixelscale: zoo.pixel2meter

            Rectangle {
                anchors.centerIn: parent
                width: 10
                height: width
                radius: width/2
                color: "red"
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.zvalue * 2 / zoo.pixel2meter
                height: width
                radius: width/2
                color: "#55FFAA44"
            }
        }

        Item {
            id: robotFocus
            x: window.width/2
            y: window.height/2
            z:100

            Rectangle {
                anchors.centerIn: parent
                width:30
                height: width
                radius: width/2
                color: "#FF3333"

                Drag.active: robotFocusDragArea.drag.active

                MouseArea {
                    id: robotFocusDragArea
                    anchors.fill: parent
                    drag.target: robotFocus
                }

                visible: zoo.showRobotChild

                TFBroadcaster {
                    active: parent.visible
                    target: parent
                    frame: "robot_focus"

                    origin: mapOrigin
                    parentframe: mapOrigin.name

                    pixelscale: zoo.pixel2meter
                }
            }
        }

        Item {
            id: childFocus
            x: window.width/2
            y: window.height/2
            z:100

            Rectangle {
                anchors.centerIn: parent
                width:30
                height: width
                radius: width/2
                color: "#995500"

                Drag.active: childFocusDragArea.drag.active

                MouseArea {
                    id: childFocusDragArea
                    anchors.fill: parent
                    drag.target: childFocus
                }
                visible: zoo.publishRobotChild

            }
        }

        RosPoseSubscriber {
            id: gazeFocus
            x: window.width/2
            y: window.height/2
            z:100

            visible: false

            topic: "/gazepose_0"
            origin: mapOrigin
            pixelscale: zoo.pixel2meter

            Rectangle {
                anchors.centerIn: parent
                width: 10
                height: width
                radius: width/2
                color: "red"
            }
            Rectangle {
                anchors.centerIn: parent
                width: parent.zvalue * 2 / zoo.pixel2meter
                height: width
                radius: width/2
                color: "transparent"
                border.color: "orange"
            }
        }

        RosPoseSubscriber {
            id: rostouch
            x: childFocus.x
            y: childFocus.y

            topic: "poses"

            Rectangle {
                id:robot_hand
                width: 20
                height: 20
                radius: 10
                color: "red"
                // tracks the position of the robot
                visible: false
            }

            z:100
            property var target: null
            origin: mapOrigin
            pixelscale: zoo.pixel2meter

            onPositionChanged: {
                // the playground is hidden, nothing to do
                if(!zoo.visible) return;
                robot_hand.visible=true;
            }
        }

        RosStringSubscriber {
            id: eventSubsriber
            topic: "events"
            onTextChanged: {
                var str = text;
                addEvent(str);
                if(str.startsWith("releasing_"))
                   releaseRobot(str.replace("releasing_",""));
            }
        }

        Item {
            id: characters
        }

        TFListener {
            id: frameManager
        }

        Timer {
            id: populate
            interval: 1000; running: true; repeat: false
            onTriggered: {
                checkFrames();
            }
        }
    }

    MouseArea {
        width:30
        height:width
        z: 100

        anchors.bottom: parent.bottom
        anchors.left: parent.left

        //Rectangle {
        //    anchors.fill: parent
        //    color: "red"
        //}

        property int clicks: 0

        onClicked: {
            clicks += 1;
            if (clicks === 3) {
                debugToolbar.visible=true;
                clicks = 0;
                timerHideDebug.start();
            }
        }

        Timer {
            id: timerHideDebug
            interval: 5000; running: false; repeat: false
            onTriggered: {
                debugToolbar.visible = false;
            }

        }
    }

    function releaseRobot(item){
        robot_hand.visible = false
        for (var i = 0; i < characters.children.length; i++)
            if(characters.children[i].name === item){
                characters.children[i].resetGhost()
            }
    }

    function checkFrames(){
        var str = frameManager.getAllFrames();
        for (var i = 0; i<str.length;i++){
            var found = false;
            for (var j = 0; j < characters.children.length; j++)
                if(characters.children[j].name === str[i]){
                    found = true;
                    break;
                }
            if(!found){
                var image
                var scale = 1
                if(str[i] === "elephant" || str[i] === "giraffe" || str[i] === "hippo" || str[i] === "rhino")
                    scale = 1.5
                if(str[i] === "toychild1")
                    scale = 0.75
                if(str[i] === "toychild4")
                    scale = 0.7
                if(str[i].startsWith("cube"))
                    image = "/res/cube.svg"
                else
                    image = "/res/"+str[i]+".png"

                var component = Qt.createComponent("Character.qml");
                component.createObject(characters,{"name":str[i],"image":image,"scale":scale})
            }
        }
    }

    function addEvent(str){
        eventModel.append({"name":str})
    }

    function resetSelectedStates(){
        for(var i=0;i<stateModel.count;i++){
            stateModel.setProperty(i,"selected",false)
        }
    }
}

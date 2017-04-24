import QtQuick 2.2
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

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
        robot.x = robot.x * width/prevWidth;
        prevWidth=width;
    }
    onHeightChanged: {
        robot.y = robot.y * height/prevHeight;
        prevHeight=height;

    }

    color: "black"
    title: qsTr("Zoo GUI")

    Item {
        id: zoo

        anchors.fill: parent

        //property double physicalMapWidth: 553 //mm (desktop acer monitor)
        property double physicalMapWidth: 600 //mm (sandtray)
        property double physicalCubeSize: 30 //mm
        property double pixel2meter: (physicalMapWidth / 1000) / map.paintedWidth

        property int nbCubes: 0
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
            //Should be replaced by an ImageListener
            /*
            ImagePublisher {
                id: mapPublisher
                target: parent
                topic: "/sandbox/image"
                frame: mapOrigin.name
                pixelscale: zoo.pixel2meter
            }

            onPaintedGeometryChanged: mapPublisher.publish();
            */
        }

        Item {
            id:robot
            z:100
            rotation: 90+180/Math.PI * (-Math.PI/2 + Math.atan2(-robot.y+robotFocus.y, -robot.x+robotFocus.x))
            Image {
                id: robotImg
                source: "res/nao_head.svg"
                anchors.centerIn: parent
                width: 100
                fillMode: Image.PreserveAspectFit

               //Drag.active: robotDragArea.drag.active

                visible:zoo.publishRobotChild
            }
/*
            TFBroadcaster {
                active: zoo.publishRobotChild
                target: parent
                frame: "odom"

                origin: mapOrigin
                parentframe: mapOrigin.name

                //zoffset: -0.15 // on boxes, next to sandtray
                zoffset: -0.25 // on the ground, next to sandtray

                pixelscale: zoo.pixel2meter
            }

*/


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
        Item {
            id:child
            z:100
            rotation: 90+180/Math.PI * (-Math.PI/2 + Math.atan2(-child.y+childFocus.y, -child.x+childFocus.x))
            Image {
                id: childImg
                source: "res/child_head.svg"
                anchors.centerIn: parent
                width: 100
                fillMode: Image.PreserveAspectFit

                Drag.active: childDragArea.drag.active

                MouseArea {
                    id: childDragArea
                    anchors.fill: parent
                    drag.target: child
                }
                visible: zoo.publishRobotChild
            }
/*
            TFBroadcaster {
                active: zoo.publishRobotChild
                target: parent
                frame: "child"

                origin: mapOrigin
                parentframe: mapOrigin.name

                pixelscale: zoo.pixel2meter
            }

*/
            x: window.width/2 - childImg.width /2
            y: window.height - childImg.height
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
            id: releasing
            topic: "releasing"
            onTextChanged: {
                releaseRobot(text);
            }
        }

        Repeater {
            model: zoo.nbCubes
            Object {
                name: "cube_" + index
                x: 0.1 * parent.width + Math.random() * 0.8 * parent.width
                y: 0.1 * parent.height + Math.random() * 0.8 * parent.height
            }

        }

        Item {
            id: characters
            Character {
                id: zebra
                name: "zebra"
                image: "res/sprite-zebra.png"
            }
            Character {
                id: elephant
                name: "elephant"
                scale: 1.5
                image: "res/sprite-elephant.png"
            }
            Character {
                id: giraffe
                name: "giraffe"
                scale: 1.5
                image: "res/sprite-giraffe.png"
            }
            Character {
                id: hippo
                name: "hippo"
                scale: 1.5
                image: "res/sprite-hippo.png"
            }
            Character {
                id: lion
                name: "lion"
                image: "res/sprite-lion.png"
            }
            Character {
                id: crocodile
                name: "crocodile"
                image: "res/sprite-crocodile.png"
            }
            Character {
                id: rhino
                name: "rhino"
                scale: 1.5
                image: "res/sprite-rhino.png"
            }
            Character {
                id: leopard
                name: "leopard"
                image: "res/sprite-leopard.png"
            }
            Character {
                id: toychild1
                name: "toychild1"
                scale:0.75
                image: "res/child_1.png"
            }
            Character {
                id: toychild4
                name: "toychild4"
                scale:0.7
                image: "res/child_4.png"
            }
        }
    }

    Item {
        id: debugToolbar
        x:0
        y:0
        visible:false

        Rectangle {
            id: fullscreenButton
            x: 50
            y: 50
            width: 180
            height: 30
            Text {
                text:  "Toggle fullscreen"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: (window.visibility === Window.FullScreen) ? window.visibility = Window.Windowed : window.visibility = Window.FullScreen;
            }
        }

        Rectangle {
            id: visualAttentionButton
            x: 250
            y: 50
            width: 250
            height: 30
            Text {
                text:  "Start visual target tracking"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    zoo.visible = false;
                    debugToolbar.visible = false;
                    visualtracking.visible = true;
                    visualtracking.start();
                }
            }
        }
        Rectangle {
            id: debugButton
            x: 50
            y: 100
            width: 180
            height: 30
            Text {
                //text: debugDraw.visible ? "Physics debug: on" : "Physics debug: off"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    debugDraw.visible = !debugDraw.visible;
                }
            }
        }
        Rectangle {
            id: robotButton
            x: 50
            y: 150
            width: 180
            height: 30
            Text {
                text: zoo.showRobotChild ? "Hide robot/child" : "Control robot/child"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    zoo.showRobotChild = !zoo.showRobotChild;
                    if (zoo.showRobotChild) {
                        robot.x=window.width - robotImg.width;
                        robot.y=window.height / 2 - robotImg.height / 2;
                    }
                }
            }
        }
        Rectangle {
            id: robotPublisherButton
            x: 50
            y: 200
            width: 180
            height: 30
            Text {
                text: zoo.publishRobotChild ? "Stop publishing robot/child frames" : "Publish robot/child frames"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {zoo.publishRobotChild = !zoo.publishRobotChild;}
            }
        }
        Rectangle {
            id: gazeButton
            x: 50
            y: 250
            width: 180
            height: 30
            Text {
                text: gazeFocus.visible ? "Hide gaze" : "Show gaze"
                anchors.centerIn: parent
            }
            color: "#DEDEDE"
            border.color: "#999"
            radius: 5
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    gazeFocus.visible = !gazeFocus.visible;
                }
            }
        }
    }


    VisualAttentionCalibration {
        id: visualtracking
        visible: false
    }

    MouseArea {
        width:30
        height:width
        z: 100

        anchors.bottom: parent.bottom
        anchors.right: parent.right

        //Rectangle {
        //    anchors.fill: parent
        //    color: "red"
        //}

        property int clicks: 0

        onClicked: {
            clicks += 1;
            if (clicks === 3) {
                localising.signal();
                zoo.visible = false;
                window.color = "white";
                fiducialmarker.visible = true;
                clicks = 0;
                restore.start();
            }
        }

        Timer {
            id: restore
            interval: 5000; running: false; repeat: false
            onTriggered: {
                fiducialmarker.visible = false;
                window.color = "black"
                zoo.visible = true;
            }

        }
/*
        RosSignal {
            id: localising
            topic: "sandtray_localising"
        }
        */
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

}

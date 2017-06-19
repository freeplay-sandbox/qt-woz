import QtQuick 2.7
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

    RosActionPublisher {
        id: actionPublisher
        pixelscale: zoo.pixel2meter
        target: zoo
        frame: "sandtray"
        origin: zoo
        type: "move"
        topic: "sparc/selected_action"
        function prepareMove(listener, dragger, name){
            origin = listener
            target = dragger
            frame = name
            type = "move"
        }
        function executeAction(){
            publish()
        }
        function makeMove(listener, dragger, name){
            prepareMove(listener, dragger, name)
            executeAction()
        }
    }

    Item {
        id: zoo

        anchors.fill: parent
        property double physicalMapWidth: 600 //mm (sandtray)
        property double physicalCubeSize: 30 //mm
        property double pixel2meter: (physicalMapWidth / 1000) / parent.width

        property bool showRobotChild: false
        property bool publishRobotChild: false

        Image {
            id: map
            fillMode: Image.PreserveAspectFit
            anchors.fill: parent
            source: "image://rosimage/sandbox/image"
            cache: false
            Timer {
                id: imageLoader
                interval: 100
                repeat: true
                running: true
                onTriggered: {
                    map.source = "";
                    map.source = "image://rosimage/sandtray/background/image";
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
            topic: "sandtray/interaction_events"
            onTextChanged: {
                var str = text;
                addEvent(str);
                if(str.startsWith("releasing_"))
                   releaseRobot(str.replace("releasing_",""));
            }
        }

        RosStringPublisher {
            id: eventPublisher
            topic: "sandtray/interaction_events"
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

    function releaseRobot(item){
        robot_hand.visible = false
        resetSelectedItems()
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
                if(!(str[i] === "ball" || str[i] === "boy" || str[i] === "rocket" || str[i]==="alternaterocket" ||
                     str[i] === "elephant" || str[i] === "zebra" || str[i] === "crocodile" || str[i] === "lion" || str[i] === "giraffe" || str[i] === "hippo" || str[i] === "rhino"))
                    continue
                var image
                var scale = 1
                if(str[i] === "elephant" || str[i] === "giraffe" || str[i] === "hippo" || str[i] === "rhino")
                    scale = 1.5
                if(str[i] === "ball")
                    scale = 0.7
                if(str[i] === "caravan")
                    scale = 2.5

                if(str[i].startsWith("cube"))
                    image = "/res/cube.svg"
                else{
                    if(str[i] === "ball" || str[i] === "boy" || str[i] === "girl" || str[i] === "caravan" || str[i] === "rocket" || str[i]==="alternaterocket")
                        image = "/res/"+str[i]+".svg"
                    else
                        image = "/res/"+str[i]+".png"
                }
                if(str[i]==="rocket" || str[i]==="alternaterocket")
                    var component = Qt.createComponent("StaticImage.qml")
                else
                    var component = Qt.createComponent("Character.qml")

                component.createObject(characters,{"name":str[i],"image":image,"scale":scale})
            }
        }
    }
}

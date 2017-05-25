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
    property var selectedItems: []
    property string actionToExecute: ""

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

    StateViewer{
        id: statePanel
        anchors.top:eventDisplay.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: eventDisplay.right
    }

    ActionViewer{
        id: actionViewer
        anchors.bottom: parent.bottom
        anchors.left: statePanel.right
        height: 20
        width:350
    }

    Grid{
        id:buttonPannel
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: parent.height/10
        anchors.right: parent.right
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        columns: 6
        columnSpacing: width/20
        leftPadding: columnSpacing
        rightPadding: columnSpacing
        z: 5
        property int n: 6
        property int cellSize: (width-(n+1)*columnSpacing)/n
        Button{
            width: parent.cellSize
            height: parent.height/2
            text: "Reset Selected States"

            onClicked: resetSelectedStates()
        }
        Button{
            width: parent.cellSize
            height: parent.height/2
            text: "button 2"
        }
        Button{
            width: parent.cellSize
            height: parent.height/2
            text: "button 3"
        }
        Button{
            text: "button 4"
        }
        Rectangle{
            id: buttonNegReward
            width: 1.5 * parent.cellSize / 3
            height: width
            radius: width/2
            color: "red"
            border.color: "black"
            border.width: width / 10
            Label{
                anchors.fill: parent
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                font.pixelSize: 80
                font.bold: true
                text: "-"
            }
            SequentialAnimation {
                id: lightningNeg
                PropertyAnimation{target: buttonNegReward; property: "color"; to: "orange"; duration: 100}
                PropertyAnimation{target: buttonNegReward; property: "color"; to: "red"; duration: 100}
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    //eventPublisher.text = "sup_neg_rew"

                    rewardPublisher.updateList()
                    rewardPublisher.reward = false
                    rewardPublisher.publish()
                    lightningNeg.start()
                }
            }
        }
        Rectangle{
            id: buttonPosReward
            width: 1.5 * parent.cellSize / 3
            height: width
            radius: width/2
            color: "green"
            border.color: "black"
            border.width: width / 10
            Label{
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                font.pixelSize: 60
                font.bold: true
                text: "+"
            }
            SequentialAnimation {
                id: lightningPos
                PropertyAnimation{target: buttonPosReward; property: "color"; to: "lime"; duration: 100}
                PropertyAnimation{target: buttonPosReward; property: "color"; to: "green"; duration: 100}

            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    //eventPublisher.text = "sup_pos_rew"
                    lightningPos.start()
                    rewardPublisher.updateList()
                    rewardPublisher.reward = true
                    rewardPublisher.publish()
                }
            }
        }

    }

    Timer {
        id: autoExe
        interval: 2000; running: false; repeat: false
        onTriggered:{
            var action = actionToExecute.split("_")
            if(action[0] === "move"){
                for (var i = 0; i < characters.children.length; i++)
                    if(characters.children[i].name === action[1]){
                        characters.children[i].move()
                    }
            }
        }
    }


    Item {
        id: zoo

        anchors.fill: parent
       /* anchors.left: eventDisplay.right
        anchors.top: parent.top
        width: 2*parent.width/3
        height: 2*parent.height/3
*/
        //property double physicalMapWidth: 553 //mm (desktop acer monitor)
        property double physicalMapWidth: 600 //mm (sandtray)
        property double physicalCubeSize: 30 //mm
        property double pixel2meter: (physicalMapWidth / 1000) / parent.width

        property bool showRobotChild: false
        property bool publishRobotChild: false

        Image {
            id: map
            fillMode: Image.PreserveAspectFit
            height: parent.height
            width: parent.width * 0.88
            anchors.left: parent.left
            anchors.top: parent.top
            source: "image://rosimage/sandbox/image"
            cache: false
            Timer {
                id: imageLoader
                interval: 100
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
        Rectangle {
            id: stash
            color: "black"
            height: map.height
            width: parent.width - map.width
            anchors.left: map.right
            anchors.top: map.top

            Rectangle {
               height: parent.height
                width: 5
                anchors.left: parent.left
                anchors.top: parent.top
                color: "#555"

            }
        }

        Rectangle{
            id: rewardDisplay
            anchors.fill: parent
            opacity: 0.
            color: "green"
            SequentialAnimation {
                id: showNegReward
                PropertyAnimation{target: rewardDisplay; property: "opacity"; to: .5; duration: 100}
                PropertyAnimation{target: rewardDisplay; property: "opacity"; to: 0; duration: 100}
            }
        }

/*
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
*/
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
/*
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
*/

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
                    if(str[i] === "ball" || str[i] === "boy" || str[i] === "girl" || str[i] === "caravan" || str[i] === "rocket" || str[i]==="alternate_rocket")
                        image = "/res/"+str[i]+".svg"
                    else
                        image = "/res/"+str[i]+".png"
                }
                if(str[i]==="rocket" || str[i]==="alternate_rocket")
                    var component = Qt.createComponent("StaticImage.qml")
                else
                    var component = Qt.createComponent("Character.qml")

                component.createObject(characters,{"name":str[i],"image":image,"scale":scale})
            }
        }
    }

    RosRewardPublisher{
        id: rewardPublisher
        topic: "sparc/sup_reward"
        reward: false
        function updateList(){
            strings.splice(0,strings.length)
            for(var i=0;i<selectedItems.length;i++){
                strings.push(selectedItems[i])
            }
        }
    }

    RosActionSubscriber {
        id: actionSubscriber
        pixelscale: zoo.pixel2meter
        topic: "sparc/proposed_action"

        onActionReceived:{
            for (var i = 0;i<strings.length;i++){
                for (var j = 0; j < characters.children.length; j++){
                    if(characters.children[j].name === strings[i]){
                        characters.children[j].select()
                        continue
                    }
                }
            }

            for (var j = 0; j < characters.children.length; j++){
                if(characters.children[j].name === frame){
                    characters.children[j].setDraggerPose(x,y,z)
                }
                if(strings.indexOf(characters.children[j].name)>-1){
                    characters.children[j].selected = true
                }
            }
        }
    }

    function addEvent(str){
        eventModel.append({"name":str})
    }

    function resetSelectedStates(){
        statePanel.reset()
    }
    function resetSelectedItems(){
        for (var j = 0; j < characters.children.length; j++)
            characters.children[j].selected = false
    }

    function addSelectedItem(name){
        selectedItems.push(name)
    }
    function removeSelectedItem(name){
        var index = selectedItems.indexOf(name)
        if (index>-1){
            selectedItems.splice(index,1)
        }
    }
    function showReward(type){
        if (type === "pos"){
            rewardDisplay.color = "green"
            showNegReward.start()
        }
        if (type === "neg"){
            rewardDisplay.color = "red"
            showNegReward.start()
        }
    }
}

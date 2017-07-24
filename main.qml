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
    property var selectedItems: []

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
            onClicked: {
                showReward("pos")
            }
        }
        Button{
            width: parent.cellSize
            height: parent.height/2
            text: "button 3"
            onClicked: {
                showReward("neg")
            }
        }
        //Cancel button might not be needed (just send negative reward to suggestion)
        Rectangle{
            id: buttonCancel
            width: 1.5 * parent.cellSize / 3
            height: width
            radius: width/2
            color: "red"
            border.color: "black"
            border.width: width / 10
            SequentialAnimation {
                id: lightningCan
                PropertyAnimation{target: buttonCancel; property: "color"; to: "orange"; duration: 100}
                PropertyAnimation{target: buttonCancel; property: "color"; to: "red"; duration: 100}
            }
            Label{
                anchors.fill: parent
                horizontalAlignment: Label.AlignHCenter
                verticalAlignment: Label.AlignVCenter
                font.pixelSize: 20
                font.bold: true
                text: "Cancel"
            }
            MouseArea{
                anchors.fill: parent
                onClicked: {
                    cancelAutoExe()
                }
            }
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
        interval: 3000; running: false; repeat: false
        onTriggered:{actionPublisher.executeAction()}
    }

    RosActionPublisher {
        id: actionPublisher
        pixelscale: zoo.pixel2meter
        target: zoo
        frame: "sandtray"
        origin: zoo
        type: "move"
        topic: "sparc/selected_action"
        function updateList(){
            strings.splice(0,strings.length)
            for(var i=0;i<selectedItems.length;i++){
                strings.push(selectedItems[i])
            }
        }
        function prepareMove(listener, dragger, name){
            updateList()
            origin = listener
            target = dragger
            frame = name
            type = "move"
        }
        function executeAction(){
            if(type == "move")
                for (var i = 0; i < characters.children.length; i++)
                    if(characters.children[i].name === frame){
                        characters.children[i].hideArrow()
                        break
                    }

            publish()
        }
        function makeMove(listener, dragger, name){
            prepareMove(listener, dragger, name)
            executeAction()
        }
    }

    RosActionPublisher {
        id: actionCanceller
        pixelscale: zoo.pixel2meter
        target: zoo
        frame: "sandtray"
        origin: zoo
        topic: "sparc/cancelled_action"
        type: "move"
        function updateList(){
            strings.splice(0,strings.length)
            for(var i=0;i<selectedItems.length;i++){
                strings.push(selectedItems[i])
            }
        }
        function cancelAction(){
            updateList()
            target = actionPublisher.target
            frame = actionPublisher.frame
            origin = actionPublisher.origin
            type = actionPublisher.type
            console.log(target.name)
            console.log(target.x)
            console.log(origin.x)
            publish()
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
            width: parent.width
            anchors.left: parent.left
            anchors.top: parent.top
            source: "image://rosimage/sandtray/background/image"
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
        Rectangle {
            id: stash
            color: "black"
            height: map.height
            width: parent.width *.12
            anchors.right: parent.right
            anchors.top: map.top
            visible: false

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
                var list = str.split("_")
                if(list[0] === "robotreleasing")
                   releaseRobot(list[1]);

                if(list[0] === "characters"){
                    for(var i=1;i<list.length;i++){
                        var component = Qt.createComponent("Character.qml")
                        var param = list[i].split(",")
                        component.createObject(characters,{"name":param[0], "scale":param[1],"image":"/res/"+param[0]+".png"})
                        }
                }

                if(list[0] === "targets"){
                    for(var i=1;i<list.length;i++){
                        var component = Qt.createComponent("StaticImage.qml")
                        var param = list[i].split(",")
                        var type = param[0].split("-")[0]
                        component.createObject(targets,{"name":param[0], "scale":param[1],"image":"/res/"+type+".png","z":-1})
                        }
                }

            }
        }

        RosStringPublisher {
            id: eventPublisher
            topic: "sandtray/interaction_events"
        }

        Item {
            id: characters
            z:1
        }
        Item {
            id: targets
            z:0
        }

        TFListener {
            id: frameManager
        }

        Timer {
            id: populate
            interval: 1000; running: true; repeat: false
            onTriggered: {
                eventPublisher.text = "supervisor_ready"
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
        origin: mapOrigin
        topic: "sparc/proposed_action"

        onActionReceived:{
            if(selectedItems.length != 0)
                return
            if(type == "move"){
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
    }
    RosListFloatSubscriber{
        id: lifeSubscriber
        topic: "sparc/partial_state"
        onListChanged:{
            for (var j = 0; j < characters.children.length; j++)
                characters.children[j].life = list[j]

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
        autoExe.stop()
        selectedItems.push(name)
    }
    function removeSelectedItem(name){
        autoExe.stop()
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
    function cancelAutoExe(){
        autoExe.stop()
        actionCanceller.cancelAction()
        eventPublisher.text = "sup_act_cancel"

        if(actionPublisher.type === "move"){
            for (var i = 0; i < characters.children.length; i++)
                if(characters.children[i].name === actionPublisher.frame){
                    characters.children[i].cancelMove()
                }
        }

        resetSelectedItems()
    }
}

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
    property var initTime: 0
    property string focusedItem: ""
    property string  qlogfilename: ""

    Component.onCompleted: {
        var d = new Date()
        initTime = d.getTime()
        qlogfilename = "foodchain-data/supervisor/" + d.toISOString().split(".")[0] + ".csv"
    }

    function updateFocus() {
        for (var i = 0; i < characters.children.length; i++)
            if(characters.children[i].name === focusedItem)
                characters.children[i].focused = false

        if(selectedItems.length>0)
            focusedItem=selectedItems[selectedItems.length-1]
        else
            focusedItem=""
        console.log(focusedItem)
        for (var i = 0; i < characters.children.length; i++)
            if(characters.children[i].name === focusedItem)
                characters.children[i].focused = true
    }

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
/*
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
*/
    //Cancel button might not be needed (just send negative reward to suggestion)
    Rectangle{
        id: buttonCancel
        width: zoo.width / 20
        height: width
        radius: width/2
        anchors.left: zoo.left
        anchors.bottom: zoo.bottom
        anchors.bottomMargin: zoo.height / 20
        color: "red"
        border.color: "black"
        border.width: width / 10
        z: 5
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
                lightningCan.start()
                cancelAction()
            }
        }
    }

    Rectangle{
        id: buttonWait
        anchors.left: zoo.left
        anchors.bottom: buttonCancel.top
        anchors.bottomMargin: zoo.height / 20
        width: zoo.width / 20
        height: width
        radius: width/2
        z: 5
        color: "orange"
        border.color: "black"
        border.width: width / 10
        SequentialAnimation {
            id: lightningWait
            PropertyAnimation{target: buttonWait; property: "color"; to: "orange"; duration: 100}
            PropertyAnimation{target: buttonWait; property: "color"; to: "gold"; duration: 100}
        }
        Label{
            anchors.fill: parent
            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            font.pixelSize: 20
            font.bold: true
            text: "Wait"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                lightningWait.start()
                waitAction()
            }
        }
    }

    Rectangle{
        id: buttonDoIt
        anchors.left: zoo.left
        anchors.bottom: buttonWait.top
        anchors.bottomMargin: zoo.height / 20
        width: zoo.width / 20
        height: width
        radius: width/2
        z: 5
        color: "limegreen"
        border.color: "black"
        border.width: width / 10
        SequentialAnimation {
            id: lightningDo
            PropertyAnimation{target: buttonDoIt; property: "color"; to: "lime"; duration: 100}
            PropertyAnimation{target: buttonDoIt; property: "color"; to: "limegreen"; duration: 100}
        }
        Label{
            anchors.fill: parent
            horizontalAlignment: Label.AlignHCenter
            verticalAlignment: Label.AlignVCenter
            font.pixelSize: 20
            font.bold: true
            text: "Do it"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                lightningDo.start()
                stopSuggestion()
                actionPublisher.executeAction("doit")
            }
        }
    }
     Grid{
        id:buttonPannel
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: parent.height/10
        anchors.right: parent.right
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
        columns: 8
        rows: 2
        columnSpacing: width/20
        leftPadding: columnSpacing
        rightPadding: columnSpacing
        z: 5
        layoutDirection: Qt.RightToLeft
        property int cellSize: (width-(columns+1)*columnSpacing)/columns
        Button{
            width: parent.cellSize
            height: parent.height/2
            text: "Reset Selected States"
            visible: false
            onClicked: resetSelectedStates()
        }
        Button{
            width: parent.cellSize
            height: parent.height/2
            text: "button 2"
            visible: false
            onClicked: {
                showReward("pos")
            }
        }
        Button{
            width: parent.cellSize
            height: parent.height/2
            text: "button 3"
            visible: false
            onClicked: {
                showReward("neg")
            }
        }
        Button{
            width: parent.cellSize
            height: parent.height/2
            text: "Select"
            visible: true
            onClicked: {
                sparcEventPublisher.text = "select"
            }
        }
        Button{
            width: parent.cellSize
            height: parent.height/2
            text: "Reset"
            visible: true
            onClicked: {
                resetSelectedItems()
                resetGhosts()
                sandtrayEventPublisher.text="reset"
            }
        }
        Button{
            width: parent.cellSize
            height: parent.height/2
            text: "Draw attention"
            visible: true
            onClicked: {
                if(focusedItem === ""){
                    informationText.text="Please have an item focused"
                    showInfoDisplay.start()
                }
                else {
                    actionPublisher.drawAttention()
                }
            }
        }
        Button{
            width: parent.cellSize
            height: parent.height/2
            text: "Congratulations"
            visible: true
            onClicked: {
                actionPublisher.congratulate()
            }
        }
        Button{
            width: parent.cellSize
            height: parent.height/2
            text: "Encouragement"
            visible: true
            onClicked: {
                actionPublisher.encourage()
            }
        }
        Button{
            width: parent.cellSize
            height: parent.height/2
            text: "Remind Rules"
            visible: true
            onClicked: {
                actionPublisher.remindRules()
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
            visible: false
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
                    //sandtrayEventPublisher.text = "sup_neg_rew"

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
            visible: false
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
                    //sandtrayEventPublisher.text = "sup_pos_rew"
                    lightningPos.start()
                    rewardPublisher.updateList()
                    rewardPublisher.reward = true
                    rewardPublisher.publish()
                }
            }
        }

    }

    Rectangle {
        id: infoDisplay
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        width: parent.width/3
        height: parent.height/8
        color: "AliceBlue"
        border.color: "black"
        border.width: width/100
        radius: width / 10
        visible: true
        opacity: 0
        z: 5
        Label {
            id: informationText
            font.pixelSize: 35
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            text: ""
        }
        SequentialAnimation {
            id:showInfoDisplay
            PropertyAnimation{target: infoDisplay; property: "opacity"; to: 1; duration: 100}
            PropertyAnimation{target: infoDisplay; property: "color"; to: "green"; duration: autoExe.interval-500}
            PropertyAnimation{target: infoDisplay; property: "opacity"; to: 0; duration: 1}
            PropertyAnimation{target: infoDisplay; property: "color"; to: "AliceBlue"; duration: 1}
        }
    }

    Timer {
        id: autoExe
        interval: 2000; running: false; repeat: false
        onTriggered:{actionPublisher.executeAction("autoexe")}
    }

    RosActionPublisher {
        id: actionPublisher
        pixelscale: zoo.pixel2meter
        target: zoo
        frame: "sandtray"
        origin: zoo
        type: "mv"
        topic: "sparc/selected_action"
        reward: 1
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
            type = "mv"
        }
        function executeAction(type){
            var tolog = "selected,"
            if(type.startsWith("mv")){
                for (var i = 0; i < characters.children.length; i++)
                    if(characters.children[i].name === frame){
                        characters.children[i].hideArrow()
                        break
                    }
                tolog = tolog+"mv_"+frame+"_"+Math.round(target.x)+"_"+Math.round(target.y)
            }
            else{
                tolog = tolog + type
                if(type == "att")
                    tolog = tolog + "_"+frame
            }
            tolog=tolog+","+reward+","+type
            log(tolog)
            publish()
            reward = 1
            timerResetState.restart()
        }
        function makeMove(listener, dragger, name){
            prepareMove(listener, dragger, name)
            executeAction("select")
        }

        function prepareAttention(item){
            updateList()
            frame = item
            type = "att"
        }

        function prepareOther(typeAction){
            updateList()
            frame = "sandtray"
            type = typeAction
        }

        function drawAttention(){
            if(focusedItem === "")
                return
            prepareAttention(focusedItem)
            executeAction("select")
        }

        function congratulate() {
            prepareOther("congrats")
            executeAction("select")
        }

        function encourage() {
            prepareOther("encour")
            executeAction("select")

        }

        function remindRules() {
            prepareOther("rul")
            executeAction("select")

        }
        function cancelAction(){
            reward = -1
            executeAction("cancel")
        }
        function wait(){
            reward = 0
            executeAction("wait")
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
        property double pixel2meter: (physicalMapWidth / 1000) / map.paintedWidth

        property bool showRobotChild: false
        property bool publishRobotChild: false

        Image {
            id: map
            fillMode: Image.PreserveAspectFit
            height: parent.height
            width: parent.width
            anchors.left: parent.left
            anchors.top: parent.top
            source: "res/map.svg"
            cache: false

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

            visible: true

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
                if(list[0] === "robotrelease")
                   releaseRobot(list[1]);

                if(list[0] === "endround"){
                    stopSuggestion()
                    for (var i = 0; i < characters.children.length; i++)
                        characters.children[i].visible = false
                        for (var i = 0; i < targets.children.length; i++)
                            targets.children[i].visible = false
                }

                if(list[0] === "characters" && !characters.initialised){
                    for(var i=1;i<list.length;i++){
                        var component = Qt.createComponent("Character.qml")
                        var param = list[i].split(",")
                        component.createObject(characters,{"name":param[0], "scale":param[1],"image":"/res/"+param[0]+".png"})
                        }
                    characters.initialised = true
                }

                if(list[0] === "targets"&&!targets.initialised){
                    for(var i=1;i<list.length;i++){
                        var component = Qt.createComponent("StaticImage.qml")
                        var param = list[i].split(",")
                        var type = param[0].split("-")[0]
                        component.createObject(targets,{"name":param[0], "scale":param[1],"image":"/res/"+type+".png","z":-1})
                        }
                    targets.initialised = true
                }
                if(list[0] === "endround"){
                    for (var i = 0; i < characters.children.length; i++){
                        characters.children[i].selected = false
                        characters.children[i].resetGhost()
                    }
                    for (var i = 0; i < targets.children.length; i++){
                        targets.children[i].selected = false
                    }
                }
                if(list[0] === "animaldead"){
                    for (var i = 0; i < characters.children.length; i++){
                        if (characters.children[i].name === list[1])
                            characters.children[i].selected=false
                    }
                }
                if(list[0] === "record"){
                    var d = new Date()
                    initTime = d.getTime()
                    qlogfilename = "foodchain-data/supervisor/" + d.toISOString().split(".")[0] + ".csv"
                }
            }
        }

        RosStringPublisher {
            id: sandtrayEventPublisher
            topic: "sandtray/interaction_events"
        }

        RosStringPublisher {
            id: sparcEventPublisher
            topic: "sparc/event"
        }

        Item {
            id: characters
            z:1
            property bool initialised: false
        }
        Item {
            id: targets
            z:0
            property bool initialised: false
        }

        TFListener {
            id: frameManager
        }

        Timer {
            id: populate
            interval: 1000; running: true; repeat: false
            onTriggered: {
                sandtrayEventPublisher.text = "supervisor_ready"
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
        origin: zoo
        topic: "sparc/proposed_action"

        onActionReceived:{
            if(selectedItems.length != 0)
                return

            var tolog ="proposed,"

            for (var i = 0;i<strings.length;i++){
                for (var j = 0; j < characters.children.length; j++){
                    if(characters.children[j].name === strings[i]){
                        characters.children[j].select()
                        continue
                    }
                }
                for (var j = 0; j < targets.children.length; j++){
                    if(targets.children[j].name === strings[i]){
                        targets.children[j].select()
                        continue
                    }
                }
            }
            if(type.startsWith("mv")){
                var newPose
                for (var j = 0; j < characters.children.length; j++){
                    if(characters.children[j].name === frame){
                        newPose = characters.children[j].setDraggerPose(x,y,z)
                    }
                    if(strings.indexOf(characters.children[j].name)>-1){
                        characters.children[j].selected = true
                    }
                }
                var direction = " to "
                if(type.startsWith("mvc"))
                    direction = " close to "
                if(type.startsWith("mva"))
                    direction = " away from "
                informationText.text="Move "+ type.split("_")[1] + direction + type.split("_")[2]+"."
                showInfoDisplay.start()
                tolog = tolog+"mv_"+frame+"_"+Math.round(newPose[0])+"_"+Math.round(newPose[1])
            }
            else if(type == "att"){
                informationText.text="Drawing attention to "+ frame +"."
                focusedItem = frame
                showInfoDisplay.start()
                actionPublisher.prepareAttention(frame)
                tolog = tolog+"att_"+frame
            }
            else{
                tolog = tolog + type
                if(type == "congrats"){
                    informationText.text="Congratulations."
                    showInfoDisplay.start()
                    actionPublisher.prepareOther("congrats")
                }
                if(type == "encour"){
                    informationText.text="Encouragement."
                    showInfoDisplay.start()
                    actionPublisher.prepareOther("encour")
                }
                if(type == "rul"){
                    informationText.text="Remind rules."
                    showInfoDisplay.start()
                    actionPublisher.prepareOther("rul")
                }
            }
            tolog += ","+reward
            log(tolog)
            autoExe.start()
        }

    }
    RosListFloatSubscriber{
        id: lifeSubscriber
        topic: "sparc/life"
        onListChanged:{
            for (var j = 0; j < targets.children.length; j++){
                if (list[j] == 0)
                    targets.children[j].visible = false
                else
                    targets.children[j].visible = true
            }
            for (var j = 0; j < characters.children.length; j++){
                characters.children[j].life = list[j+targets.children.length]
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
        timerResetState.stop()
        for (var j = 0; j < characters.children.length; j++)
            characters.children[j].selected = false
        for (var j = 0; j < targets.children.length; j++)
            targets.children[j].selected = false
    }

    function resetGhosts(){
        for (var j = 0; j < characters.children.length; j++)
            characters.children[j].resetGhost()
    }

    function addSelectedItem(name){
        timerResetState.stop()
        stopSuggestion()
        selectedItems.push(name)
        updateFocus()
    }
    function removeSelectedItem(name){
        timerResetState.stop()
        stopSuggestion()
        var index = selectedItems.indexOf(name)
        if (index>-1){
            selectedItems.splice(index,1)
        }
        updateFocus()
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
    function cancelAction(){
        stopSuggestion()
        actionPublisher.cancelAction()
        sandtrayEventPublisher.text = "sup_act_cancel"
        resetSelectedItems()
        resetGhosts()
    }
    function waitAction(){
        stopSuggestion()
        actionPublisher.wait()
        sandtrayEventPublisher.text = "sup_act_wait"
        resetSelectedItems()
        resetGhosts()
    }
    function stopSuggestion(){
        autoExe.stop()
        infoDisplay.opacity = 0
    }
    function log(string){
        var d = new Date()
        var log = [d.getTime()-initTime, string]
        fileio.write(window.qlogfilename, log.join(","));
    }
    Timer{
        id: timerResetState
        interval: 2000
        repeat: false
        running: false
        onTriggered: resetSelectedItems()
    }
}

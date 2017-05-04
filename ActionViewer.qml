import QtQuick 2.0
import QtQuick.Controls 1.4

import Ros 1.0

Item {
    id: actionViewer

    Component {
        id: actionStyle
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
                            selected = !selected
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
        model: actionModel
        delegate: actionStyle
        cellWidth: width/10.5
        cellHeight: height
        //flow: GridView.FlowTopToBottom
        focus: true
    }


    ListModel {
        id:  actionModel
        ListElement{ textLabel:""; selected:false}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
    }

    function reset(){
        for(var i=0;i<actionModel.count;i++){
            actionModel.setProperty(i,"selected",false)
        }
    }

    RosListIntSubscriber{
        id: actionListener
        topic: "actions"
        onListChanged:{
            var str = getSpatialStringFromId(list[1]+7)
            actionModel.setProperty(0,"textLabel", "mov")
            actionModel.setProperty(1,"textLabel", str)
            for(var i=0;i<4;i++){
                actionModel.setProperty(2*i+2,"textLabel", getSpatialStringFromId(list[2*i+2]))
                actionModel.setProperty(2*i+3,"textLabel", String(list[2*i+3]))
            }
        }
    }

    function getSpatialStringFromId(id){
        var str = "und"
        switch (id){
            case 0: str = "bla"; break
            case 1: str = "whi"; break
            case 2: str = "pur"; break
            case 3: str = "blu"; break
            case 4: str = "gre"; break
            case 5: str = "yel"; break
            case 6: str = "red"; break
            case 7: str = "zeb"; break
            case 8: str = "ele"; break
            case 9: str = "leo"; break
            case 10: str = "lio"; break
            case 11: str = "gir"; break
            case 12: str = "rhi"; break
            case 13: str = "cro"; break
            case 14: str = "hip"; break
            case 15: str = "to1"; break
            case 16: str = "to4"; break
            default: break
        }
        return str
    }
}

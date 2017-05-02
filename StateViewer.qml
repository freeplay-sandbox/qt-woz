import QtQuick 2.0
import QtQuick.Controls 1.4
import Ros 1.0

Item{
    id: statePanel

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
        model: stateModel
        delegate: stateStyle
        cellWidth: width/9.5
        cellHeight: height/10
        //flow: GridView.FlowTopToBottom
        focus: true
    }

    ListModel {
        id:  stateModel
        ListElement{ textLabel: "Zeb"; selected:false}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel: "Ele"}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel: "Leo"}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel: "Lio"}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel: "Gir"}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel: "rhi"}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel: "Cro"}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel: "Hip"}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel: "To1"}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel: "To4"}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}
        ListElement{ textLabel:""}

    }

    RosArrayIntSubscriber {
        id: stateSub
        topic: "state"
        onDataChanged: {
            var names = ["zebra","elephant","leopard","lion","giraffe","rhino","crocodile","hippo","toychild1","toychild4"]
            for (var i = 0; i < names.length; i++){
                for (var j=0;j<dimensions[1]/2;j++){
                    var str = getSpatialStringFromId(data[dimensions[1]*i+2*j])
                    var idx = String(data[dimensions[1]*i+2*j+1])
                    stateModel.setProperty((dimensions[1]+1)*i+1+2*j,"textLabel", str)
                    stateModel.setProperty((dimensions[1]+1)*i+1+2*j+1,"textLabel", idx)
                }
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
    function reset(){
        for(var i=0;i<stateModel.count;i++){
            stateModel.setProperty(i,"selected",false)
        }
    }
}



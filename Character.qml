import QtQuick 2.0

Object {
    id: character


    property double scale: 1.0
    property double bbScale: 1.0

    x: 0.1 * parent.width + Math.random() * 0.8 * parent.width
    y: 0.1 * parent.height + Math.random() * 0.8 * parent.height
    rotation: -30 + Math.random() * 60

    width: scale * 2 * parent.height * zoo.physicalCubeSize / zoo.physicalMapWidth
}

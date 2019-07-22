import QtQuick 2.12

MultiPointTouchArea {
    id:               parentalGateDialog
    anchors.centerIn: parent
    visible:          false

    readonly property int parentWidth:  parent.width
    readonly property int parentHeight: parent.height

    property string imageFormat:        ""

    signal opened()
    signal closed()

    signal passAndCaptureImage()
    signal passAndCaptureGIF()
    signal cancel()

    onParentWidthChanged: {
        if (parent) {
            if (rotation === 0 || rotation === 180) {
                width  = parent.width;
                height = parent.height;
            } else if (rotation === 90 || rotation === 270) {
                width  = parent.height;
                height = parent.width;
            }
        }
    }

    onParentHeightChanged: {
        if (parent) {
            if (rotation === 0 || rotation === 180) {
                width  = parent.width;
                height = parent.height;
            } else if (rotation === 90 || rotation === 270) {
                width  = parent.height;
                height = parent.width;
            }
        }
    }

    onRotationChanged: {
        if (parent) {
            if (rotation === 0 || rotation === 180) {
                width  = parent.width;
                height = parent.height;
            } else if (rotation === 90 || rotation === 270) {
                width  = parent.height;
                height = parent.width;
            }
        }
    }

    function open(image_format) {
        visible     = true;
        imageFormat = image_format;

        opened();
    }

    function close() {
        visible = false;

        cancel();
        closed();
    }

    Image {
        id:               dialogImage
        anchors.centerIn: parent
        source:           "qrc:/resources/images/dialog/parental_gate_dialog.png"

        MultiPointTouchArea {
            anchors.fill:       parent
            minimumTouchPoints: 2

            touchPoints: [
                TouchPoint { id: touchPoint1 },
                TouchPoint { id: touchPoint2 }
            ]

            onReleased: {
                if (Math.sqrt(Math.pow(touchPoint1.x - touchPoint1.startX, 2) + Math.pow(touchPoint1.y - touchPoint1.startY, 2)) > Math.min(width, height) / 2 &&
                    Math.sqrt(Math.pow(touchPoint2.x - touchPoint2.startX, 2) + Math.pow(touchPoint2.y - touchPoint2.startY, 2)) > Math.min(width, height) / 2) {
                    parentalGateDialog.visible = false;

                    if (imageFormat === "IMAGE") {
                        parentalGateDialog.passAndCaptureImage();
                    } else {
                        parentalGateDialog.passAndCaptureGIF();
                    }

                    parentalGateDialog.closed();
                }
            }

            Text {
                anchors.fill:         parent
                anchors.margins:      16
                anchors.bottomMargin: 40
                text:                 qsTr("Slide with two fingers over this dialog to continue")
                color:                "black"
                font.pointSize:       24
                font.family:          "Helvetica"
                horizontalAlignment:  Text.AlignHCenter
                verticalAlignment:    Text.AlignVCenter
                wrapMode:             Text.Wrap
                fontSizeMode:         Text.Fit
                minimumPointSize:     8
            }
        }
    }

    Image {
        id:                       cancelButtonImage
        anchors.horizontalCenter: dialogImage.horizontalCenter
        anchors.verticalCenter:   dialogImage.bottom
        width:                    64
        height:                   64
        z:                        1
        source:                   "qrc:/resources/images/dialog/cancel.png"

        MouseArea {
            anchors.fill: parent

            onClicked: {
                parentalGateDialog.visible = false;

                parentalGateDialog.cancel();
                parentalGateDialog.closed();
            }
        }
    }
}

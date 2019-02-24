import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Particles 2.12
import QtMultimedia 5.12

import "Dialog"
import "Tree"

Item {
    id: treePage

    property bool appInForeground:           Qt.application.state === Qt.ApplicationActive
    property bool pageActive:                StackView.status === StackView.Active
    property bool interstitialActive:        AdMobHelper.interstitialActive
    property bool lastInterstitialActive:    false

    property int bannerViewHeight:           AdMobHelper.bannerViewHeight
    property int currentBackgroundNum:       1
    property int maxBackgroundNum:           3
    property int maxBackgroundNumWithSnow:   2
    property int currentTreeNum:             1
    property int maxTreeNum:                 3
    property int maxToyNum:                  37
    property int maxTwinkleNum:              7
    property int upperTreePointXConfig:      0   // Coordinates relative to the center of source image
    property int upperTreePointYConfig:     -240 // in source image original resolution
    property int lowerLeftTreePointXConfig: -170
    property int lowerLeftTreePointYConfig:  220
    property int lowerRightTreePointXConfig: 170
    property int lowerRightTreePointYConfig: 220
    property int upperTreePointX:            upperTreePointXConfig
    property int upperTreePointY:            upperTreePointYConfig
    property int lowerLeftTreePointX:        lowerLeftTreePointXConfig
    property int lowerLeftTreePointY:        lowerLeftTreePointYConfig
    property int lowerRightTreePointX:       lowerRightTreePointXConfig
    property int lowerRightTreePointY:       lowerRightTreePointYConfig

    property string interstitialCaptureFmt: ""

    property var newToy:                   null

    onAppInForegroundChanged: {
        if (appInForeground && pageActive) {
            var background_num = parseInt(mainWindow.getSetting("BackgroundNum", "1"), 10);
            var tree_num       = parseInt(mainWindow.getSetting("TreeNum",       "1"), 10);

            if (background_num <= maxBackgroundNum) {
                currentBackgroundNum = background_num;
            }
            if (tree_num <= maxTreeNum) {
                currentTreeNum = tree_num;
            }

            helpOnStartupTimer.restart();
        }
    }

    onPageActiveChanged: {
        if (appInForeground && pageActive) {
            var background_num = parseInt(mainWindow.getSetting("BackgroundNum", "1"), 10);
            var tree_num       = parseInt(mainWindow.getSetting("TreeNum",       "1"), 10);

            if (background_num <= maxBackgroundNum) {
                currentBackgroundNum = background_num;
            }
            if (tree_num <= maxTreeNum) {
                currentTreeNum = tree_num;
            }

            helpOnStartupTimer.restart();
        }
    }

    onInterstitialActiveChanged: {
        if (!interstitialActive && lastInterstitialActive) {
            if (interstitialCaptureFmt === "IMAGE") {
                captureImage();
            } else {
                captureGIFTimer.start();
            }
        }

        lastInterstitialActive = interstitialActive;
    }

    function validateToy(center_x, center_y) {
        var x0 = center_x;
        var x1 = upperTreePointX;
        var x2 = lowerLeftTreePointX;
        var x3 = lowerRightTreePointX;

        var y0 = center_y;
        var y1 = upperTreePointY;
        var y2 = lowerLeftTreePointY;
        var y3 = lowerRightTreePointY;

        var mul1 = (x1 - x0) * (y2 - y1) - (x2 - x1) * (y1 - y0);
        var mul2 = (x2 - x0) * (y3 - y2) - (x3 - x2) * (y2 - y0);
        var mul3 = (x3 - x0) * (y1 - y3) - (x1 - x3) * (y3 - y0);

        if ((mul1 > 0 && mul2 > 0 && mul3 > 0) || (mul1 < 0 && mul2 < 0 && mul3 < 0)) {
            return true;
        } else {
            return false;
        }
    }

    function resetParticleSystems() {
        particleSystem1.reset();
        particleSystem2.reset();
        particleSystem3.reset();
        particleSystem4.reset();
    }

    function captureImage() {
        waitRectangle.visible = true;

        if (!backgroundImage.grabToImage(function (result) {
            result.saveToFile(ShareHelper.imageFilePath);

            ShareHelper.showShareToView(ShareHelper.imageFilePath);

            waitRectangle.visible = false;
        })) {
            console.log("grabToImage() failed");

            waitRectangle.visible = false;
        }
    }

    function shareToViewCompleted() {
        StoreHelper.requestReview();
    }

    Audio {
        volume:   1.0
        muted:    !treePage.appInForeground || !treePage.pageActive || treePage.interstitialActive
        source:   "qrc:/resources/sound/tree/music.mp3"
        autoPlay: true
        loops:    Audio.Infinite

        onError: {
            console.log(errorString);
        }
    }

    Rectangle {
        id:           backgroundRectangle
        anchors.fill: parent
        color:        "black"

        Image {
            id:               backgroundImage
            anchors.centerIn: parent
            width:            Math.floor(calculateWidth (sourceSize.width, sourceSize.height, parent.width, parent.height))
            height:           Math.floor(calculateHeight(sourceSize.width, sourceSize.height, parent.width, parent.height))
            source:           "qrc:/resources/images/tree/background_%1.png".arg(treePage.currentBackgroundNum)
            fillMode:         Image.PreserveAspectCrop

            onPaintedWidthChanged: {
                if (sourceSize.width > 0 && sourceSize.height > 0) {
                    treePage.upperTreePointX = (sourceSize.width  / 2 + treePage.upperTreePointXConfig) * (paintedWidth  / sourceSize.width);
                    treePage.upperTreePointY = (sourceSize.height / 2 + treePage.upperTreePointYConfig) * (paintedHeight / sourceSize.height);

                    treePage.lowerLeftTreePointX = (sourceSize.width  / 2 + treePage.lowerLeftTreePointXConfig) * (paintedWidth  / sourceSize.width);
                    treePage.lowerLeftTreePointY = (sourceSize.height / 2 + treePage.lowerLeftTreePointYConfig) * (paintedHeight / sourceSize.height);

                    treePage.lowerRightTreePointX = (sourceSize.width  / 2 + treePage.lowerRightTreePointXConfig) * (paintedWidth  / sourceSize.width);
                    treePage.lowerRightTreePointY = (sourceSize.height / 2 + treePage.lowerRightTreePointYConfig) * (paintedHeight / sourceSize.height);
                }
            }

            onPaintedHeightChanged: {
                if (sourceSize.width > 0 && sourceSize.height > 0) {
                    treePage.upperTreePointX = (sourceSize.width  / 2 + treePage.upperTreePointXConfig) * (paintedWidth  / sourceSize.width);
                    treePage.upperTreePointY = (sourceSize.height / 2 + treePage.upperTreePointYConfig) * (paintedHeight / sourceSize.height);

                    treePage.lowerLeftTreePointX = (sourceSize.width  / 2 + treePage.lowerLeftTreePointXConfig) * (paintedWidth  / sourceSize.width);
                    treePage.lowerLeftTreePointY = (sourceSize.height / 2 + treePage.lowerLeftTreePointYConfig) * (paintedHeight / sourceSize.height);

                    treePage.lowerRightTreePointX = (sourceSize.width  / 2 + treePage.lowerRightTreePointXConfig) * (paintedWidth  / sourceSize.width);
                    treePage.lowerRightTreePointY = (sourceSize.height / 2 + treePage.lowerRightTreePointYConfig) * (paintedHeight / sourceSize.height);
                }
            }

            function calculateWidth(src_width, src_height, dst_width, dst_height) {
                if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                    if (dst_width / dst_height < src_width / src_height) {
                        return src_width * dst_height / src_height;
                    } else {
                        return dst_width;
                    }
                } else {
                    return 0;
                }
            }

            function calculateHeight(src_width, src_height, dst_width, dst_height) {
                if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                    if (dst_width / dst_height < src_width / src_height) {
                        return dst_height;
                    } else {
                        return src_height * dst_width / src_width;
                    }
                } else {
                    return 0;
                }
            }

            Image {
                id:               treeImageBg
                anchors.centerIn: parent
                width:            Math.floor(calculateWidth (sourceSize.width, sourceSize.height, parent.width, parent.height))
                height:           Math.floor(calculateHeight(sourceSize.width, sourceSize.height, parent.width, parent.height))
                z:                1
                source:           "qrc:/resources/images/tree/tree_%1_bg.png".arg(treePage.currentTreeNum)
                fillMode:         Image.PreserveAspectCrop

                function calculateWidth(src_width, src_height, dst_width, dst_height) {
                    if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                        if (dst_width / dst_height < src_width / src_height) {
                            return src_width * dst_height / src_height;
                        } else {
                            return dst_width;
                        }
                    } else {
                        return 0;
                    }
                }

                function calculateHeight(src_width, src_height, dst_width, dst_height) {
                    if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                        if (dst_width / dst_height < src_width / src_height) {
                            return dst_height;
                        } else {
                            return src_height * dst_width / src_width;
                        }
                    } else {
                        return 0;
                    }
                }
            }

            Image {
                id:               treeImageFg
                anchors.centerIn: parent
                width:            Math.floor(calculateWidth (sourceSize.width, sourceSize.height, parent.width, parent.height))
                height:           Math.floor(calculateHeight(sourceSize.width, sourceSize.height, parent.width, parent.height))
                z:                3
                source:           "qrc:/resources/images/tree/tree_%1_fg.png".arg(treePage.currentTreeNum)
                fillMode:         Image.PreserveAspectCrop

                function calculateWidth(src_width, src_height, dst_width, dst_height) {
                    if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                        if (dst_width / dst_height < src_width / src_height) {
                            return src_width * dst_height / src_height;
                        } else {
                            return dst_width;
                        }
                    } else {
                        return 0;
                    }
                }

                function calculateHeight(src_width, src_height, dst_width, dst_height) {
                    if (src_width > 0 && src_height > 0 && dst_width > 0 && dst_height > 0) {
                        if (dst_width / dst_height < src_width / src_height) {
                            return dst_height;
                        } else {
                            return src_height * dst_width / src_width;
                        }
                    } else {
                        return 0;
                    }
                }
            }
        }

        ParticleSystem {
            id:      particleSystem1
            running: treePage.appInForeground && treePage.pageActive &&
                     treePage.currentBackgroundNum <= treePage.maxBackgroundNumWithSnow
        }

        Emitter {
            anchors.fill: parent
            system:       particleSystem1
            lifeSpan:     1000

            velocity: AngleDirection {
                angle:              90
                angleVariation:     30
                magnitude:          40
                magnitudeVariation: 20
            }

            ImageParticle {
                z:       5
                opacity: 0.75
                system:  particleSystem1
                source:  "qrc:/resources/images/tree/snowflake_1.png"
            }
        }

        ParticleSystem {
            id:      particleSystem2
            running: treePage.appInForeground && treePage.pageActive &&
                     treePage.currentBackgroundNum <= treePage.maxBackgroundNumWithSnow
        }

        Emitter {
            anchors.fill: parent
            system:       particleSystem2
            lifeSpan:     1000

            velocity: AngleDirection {
                angle:              90
                angleVariation:     30
                magnitude:          40
                magnitudeVariation: 20
            }

            ImageParticle {
                z:       5
                opacity: 0.75
                system:  particleSystem2
                source:  "qrc:/resources/images/tree/snowflake_2.png"
            }
        }

        ParticleSystem {
            id:      particleSystem3
            running: treePage.appInForeground && treePage.pageActive &&
                     treePage.currentBackgroundNum <= treePage.maxBackgroundNumWithSnow
        }

        Emitter {
            anchors.fill: parent
            system:       particleSystem3
            lifeSpan:     1000

            velocity: AngleDirection {
                angle:              90
                angleVariation:     30
                magnitude:          40
                magnitudeVariation: 20
            }

            ImageParticle {
                z:       5
                opacity: 0.75
                system:  particleSystem3
                source:  "qrc:/resources/images/tree/snowflake_3.png"
            }
        }

        ParticleSystem {
            id:      particleSystem4
            running: treePage.appInForeground && treePage.pageActive &&
                     treePage.currentBackgroundNum <= treePage.maxBackgroundNumWithSnow
        }

        Emitter {
            anchors.fill: parent
            system:       particleSystem4
            lifeSpan:     1000

            velocity: AngleDirection {
                angle:              90
                angleVariation:     30
                magnitude:          40
                magnitudeVariation: 20
            }

            ImageParticle {
                z:       5
                opacity: 0.75
                system:  particleSystem4
                source:  "qrc:/resources/images/tree/snowflake_4.png"
            }
        }

        Image {
            id:                 helpButtonImage
            anchors.top:        parent.top
            anchors.left:       parent.left
            anchors.topMargin:  Math.max(treePage.bannerViewHeight + 8, 34)
            anchors.leftMargin: 8
            width:              32
            height:             32
            z:                  15
            source:             "qrc:/resources/images/tree/button_help.png"

            MouseArea {
                id:           helpButtonMouseArea
                anchors.fill: parent

                onClicked: {
                    helpDialog.open();
                }
            }
        }

        Row {
            id:                       buttonImageRow
            anchors.bottom:           parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin:     30
            z:                        15
            spacing:                  16

            Image {
                id:     settingsButtonImage
                width:  64
                height: 64
                source: "qrc:/resources/images/tree/button_settings.png"

                MouseArea {
                    id:           settingsButtonMouseArea
                    anchors.fill: parent

                    onClicked: {
                        if (settingsListRectangle.visible) {
                            settingsListRectangle.visible = false;
                            settingsButtonImage.source    = "qrc:/resources/images/tree/button_settings.png";
                        } else {
                            settingsListRectangle.visible = true;
                            settingsButtonImage.source    = "qrc:/resources/images/tree/button_settings_pressed.png";
                        }
                    }
                }
            }

            Image {
                id:     captureImageButtonImage
                width:  64
                height: 64
                source: "qrc:/resources/images/tree/button_capture_image.png"

                MouseArea {
                    id:           captureImageButtonMouseArea
                    anchors.fill: parent

                    onClicked: {
                        if (mainWindow.versionForKids) {
                            parentalGateDialog.open("IMAGE");
                        } else {
                            if (mainWindow.fullVersion) {
                                treePage.captureImage();
                            } else {
                                purchaseDialog.open("IMAGE");
                            }
                        }
                    }
                }
            }

            Image {
                id:     captureGIFButtonImage
                width:  64
                height: 64
                source: "qrc:/resources/images/tree/button_capture_gif.png"

                MouseArea {
                    id:           captureGIFButtonMouseArea
                    anchors.fill: parent

                    onClicked: {
                        if (mainWindow.versionForKids) {
                            parentalGateDialog.open("GIF");
                        } else {
                            if (mainWindow.fullVersion) {
                                captureGIFTimer.start();
                            } else {
                                purchaseDialog.open("GIF");
                            }
                        }
                    }
                }
            }

            Image {
                id:     toysButtonImage
                width:  64
                height: 64
                source: "qrc:/resources/images/tree/button_toys.png"

                MouseArea {
                    id:           toysButtonMouseArea
                    anchors.fill: parent

                    onClicked: {
                        if (toysListRectangle.visible) {
                            toysListRectangle.visible = false;
                            toysButtonImage.source    = "qrc:/resources/images/tree/button_toys.png";
                        } else {
                            toysListRectangle.visible = true;
                            toysButtonImage.source    = "qrc:/resources/images/tree/button_toys_pressed.png";
                        }
                    }
                }
            }
        }

        Rectangle {
            id:                     settingsListRectangle
            anchors.verticalCenter: parent.verticalCenter
            anchors.left:           parent.left
            width:                  96
            height:                 Math.min(parent.height * 5 / 8, settingsListView.contentHeight)
            z:                      20
            clip:                   true
            color:                  "black"
            opacity:                0.75
            visible:                false

            ListView {
                id:           settingsListView
                anchors.fill: parent
                orientation:  ListView.Vertical

                model: ListModel {
                    id: settingsListModel
                }

                delegate: Image {
                    id:     settingsItemDelegate
                    width:  settingsListRectangle.width
                    height: sourceSize.width > 0 ? (width / sourceSize.width) * sourceSize.height : 0
                    source: settingType === "background" ? "qrc:/resources/images/tree/background_%1.png".arg(settingNumber) :
                                                           "qrc:/resources/images/tree/tree_%1_bg.png".arg(settingNumber)

                    MouseArea {
                        id:           settingsItemMouseArea
                        anchors.fill: parent

                        onClicked: {
                            if (settingType === "background") {
                                treePage.resetParticleSystems();

                                treePage.currentBackgroundNum = settingNumber;

                                mainWindow.setSetting("BackgroundNum", treePage.currentBackgroundNum.toString(10));
                            } else {
                                treePage.currentTreeNum = settingNumber;

                                mainWindow.setSetting("TreeNum", treePage.currentTreeNum.toString(10));
                            }
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOn
                }
            }
        }

        Rectangle {
            id:                     toysListRectangle
            anchors.verticalCenter: parent.verticalCenter
            anchors.right:          parent.right
            width:                  54
            height:                 Math.min(parent.height * 5 / 8, toysListView.contentHeight)
            z:                      20
            clip:                   true
            color:                  "black"
            opacity:                0.75
            visible:                false

            ListView {
                id:           toysListView
                anchors.fill: parent
                orientation:  ListView.Vertical
                cacheBuffer:  (treePage.maxToyNum + treePage.maxTwinkleNum) * 256 // To prevent strange issue with "untouchable toys"

                model: ListModel {
                    id: toysListModel
                }

                delegate: Image {
                    id:     toysItemDelegate
                    width:  sourceSize.width
                    height: sourceSize.height
                    source: "qrc:/resources/images/tree/toys/%1_%2.png".arg(toyType).arg(toyNumber)

                    MouseArea {
                        id:           toysItemMouseArea
                        anchors.fill: parent

                        property int pressX: 0
                        property int pressY: 0

                        onPressed: {
                            var mapped = mapToItem(backgroundImage, mouseX, mouseY);

                            pressX = mapped.x;
                            pressY = mapped.y;

                            pressAndHoldTimer.start();
                        }

                        onPositionChanged: {
                            var mapped = mapToItem(backgroundImage, mouseX, mouseY);

                            if (treePage.newToy !== null) {
                                treePage.newToy.x = mapped.x - treePage.newToy.width / 2;
                                treePage.newToy.y = mapped.y - treePage.newToy.height;
                            }
                        }

                        onReleased: {
                            preventStealing = false;

                            if (treePage.newToy !== null) {
                                treePage.newToy.reduceToy();

                                if (!treePage.validateToy(treePage.newToy.x + treePage.newToy.width / 2, treePage.newToy.y + treePage.newToy.height / 2)) {
                                    treePage.newToy.destroyToy();
                                }

                                treePage.newToy = null;
                            }

                            pressAndHoldTimer.stop();
                        }

                        Timer {
                            id:       pressAndHoldTimer
                            interval: 500

                            onTriggered: {
                                if (toysItemMouseArea.pressed) {
                                    toysItemMouseArea.preventStealing = true;

                                    var component = Qt.createComponent("Tree/Toy.qml");

                                    if (component.status === Component.Ready) {
                                        treePage.newToy = component.createObject(backgroundImage, {"z": 4, "treePage": treePage, "toyType": toyType, "toyNumber": toyNumber});

                                        treePage.newToy.enlargeToy();

                                        treePage.newToy.x = toysItemMouseArea.pressX - treePage.newToy.width / 2;
                                        treePage.newToy.y = toysItemMouseArea.pressY - treePage.newToy.height;
                                    } else {
                                        console.log(component.errorString());
                                    }
                                }
                            }
                        }
                    }
                }

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AlwaysOff
                }
            }
        }

        Rectangle {
             id:           waitRectangle
             anchors.fill: parent
             z:            25
             color:        "black"
             opacity:      0.75
             visible:      false

             BusyIndicator {
                 anchors.centerIn: parent
                 running:          parent.visible
             }

             MouseArea {
                 anchors.fill: parent
             }
         }
    }

    PurchaseDialog {
        id: purchaseDialog
        z:  30

        onViewAdAndCaptureImage: {
            if (AdMobHelper.interstitialReady) {
                treePage.interstitialCaptureFmt = "IMAGE";

                AdMobHelper.showInterstitial();
            } else {
                treePage.captureImage();
            }
        }

        onViewAdAndCaptureGIF: {
            if (AdMobHelper.interstitialReady) {
                treePage.interstitialCaptureFmt = "GIF";

                AdMobHelper.showInterstitial();
            } else {
                captureGIFTimer.start();
            }
        }

        onPurchaseFullVersion: {
            mainWindow.purchaseFullVersion();
        }

        onRestorePurchases: {
            mainWindow.restorePurchases();
        }
    }

    ParentalGateDialog {
        id: parentalGateDialog
        z:  30

        onPassAndCaptureImage: {
            treePage.captureImage();
        }

        onPassAndCaptureGIF: {
            captureGIFTimer.start();
        }
    }

    HelpDialog {
        id: helpDialog
        z:  30
    }

    Timer {
        id:       helpOnStartupTimer
        interval: 100

        onTriggered: {
            if (mainWindow.getSetting("ShowHelpOnStartup", "true") === "true") {
                helpDialog.open();
            }

            mainWindow.setSetting("ShowHelpOnStartup", "false");
        }
    }

    Timer {
        id:               captureGIFTimer
        interval:         200
        repeat:           true
        triggeredOnStart: true

        property bool lastRunning: false

        property int frameNumber:  0
        property int framesCount:  5

        onRunningChanged: {
            if (running && !lastRunning) {
                waitRectangle.visible = true;

                frameNumber = 0;
            } else if (!running && lastRunning) {
                if (frameNumber >= framesCount) {
                    if (GIFCreator.createGIF(framesCount, interval / 10)) {
                        ShareHelper.showShareToView(GIFCreator.gifFilePath);
                    } else {
                        console.log("createGIF() failed");
                    }
                }

                waitRectangle.visible = false;
            }

            lastRunning = running;
        }

        onTriggered: {
            if (frameNumber < framesCount) {
                var frame_number = frameNumber;

                if (!backgroundImage.grabToImage(function (result) {
                    result.saveToFile(GIFCreator.imageFilePathMask.arg(frame_number));
                })) {
                    console.log("grabToImage() failed for frame %1".arg(frame_number));
                }

                frameNumber = frameNumber + 1;
            } else {
                stop();
            }
        }
    }

    Component.onCompleted: {
        ShareHelper.shareToViewCompleted.connect(shareToViewCompleted);

        settingsListModel.clear();

        for (var i = 1; i <= treePage.maxBackgroundNum; i++) {
            settingsListModel.append({"settingType": "background", "settingNumber": i});
        }

        for (var j = 1; j <= treePage.maxTreeNum; j++) {
            settingsListModel.append({"settingType": "tree", "settingNumber": j});
        }

        toysListModel.clear();

        for (var k = 1; k <= treePage.maxToyNum; k++) {
            toysListModel.append({"toyType": "toy", "toyNumber": k});
        }

        for (var n = 1; n <= treePage.maxTwinkleNum; n++) {
            toysListModel.append({"toyType": "twinkle", "toyNumber": n});
        }
    }
}

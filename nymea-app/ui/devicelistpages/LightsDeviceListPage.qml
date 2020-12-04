/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
*
* Copyright 2013 - 2020, nymea GmbH
* Contact: contact@nymea.io
*
* This file is part of nymea.
* This project including source code and documentation is protected by
* copyright law, and remains the property of nymea GmbH. All rights, including
* reproduction, publication, editing and translation, are reserved. The use of
* this project is subject to the terms of a license agreement to be concluded
* with nymea GmbH in accordance with the terms of use of nymea GmbH, available
* under https://nymea.io/license
*
* GNU General Public License Usage
* Alternatively, this project may be redistributed and/or modified under the
* terms of the GNU General Public License as published by the Free Software
* Foundation, GNU version 3. This project is distributed in the hope that it
* will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along with
* this project. If not, see <https://www.gnu.org/licenses/>.
*
* For any further details and any questions please contact us under
* contact@nymea.io or see our FAQ/Licensing Information on
* https://nymea.io/license/faq
*
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import QtQuick 2.5
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0
import Nymea 1.0
import "../components"
import "../utils"

DeviceListPageBase {
    id: root

    header: NymeaHeader {
        text: qsTr("Lights")
        onBackPressed: pageStack.pop()

        HeaderButton {
            imageSource: "../images/system-shutdown.svg"
            onClicked: {
                var allOff = true;
                for (var i = 0; i < devicesProxy.count; i++) {
                    var device = devicesProxy.get(i);
                    if (device.states.getState(device.deviceClass.stateTypes.findByName("power").id).value === true) {
                        allOff = false;
                        break;
                    }
                }

                for (var i = 0; i < devicesProxy.count; i++) {
                    var device = devicesProxy.get(i);
                    var deviceClass = engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId);
                    var actionType = deviceClass.actionTypes.findByName("power");

                    var params = [];
                    var param1 = {};
                    param1["paramTypeId"] = actionType.paramTypes.get(0).id;
                    param1["value"] = allOff ? true : false;
                    params.push(param1)
                    engine.deviceManager.executeAction(device.id, actionType.id, params)
                }
            }
        }
    }

    Flickable {
        anchors.fill: parent
        contentHeight: contentGrid.implicitHeight
        topMargin: app.margins / 2

        GridLayout {
            id: contentGrid
            width: parent.width - app.margins
            anchors.horizontalCenter: parent.horizontalCenter
            columns: Math.ceil(width / 600)
            rowSpacing: 0
            columnSpacing: 0
            Repeater {
                model: root.thingsProxy

                delegate: BigTile {
                    id: itemDelegate
                    Layout.preferredWidth: contentGrid.width / contentGrid.columns
                    thing: root.thingsProxy.getThing(model.id)
                    showHeader: false
                    topPadding: 0
                    bottomPadding: 0
                    leftPadding: 0
                    rightPadding: 0

                    property State connectedState: thing.stateByName("connected")
                    property State powerState: thing.stateByName("power")
                    property State brightnessState: thing.stateByName("brightness")
                    property State colorState: thing.stateByName("color")

                    property bool tileColored: enabled && colorState && powerState.value === true
                    property bool colorInverted: tileColored && NymeaUtils.isDark(app.foregroundColor) === NymeaUtils.isDark(colorState.value)
                    property bool isConnected: connectedState && connectedState.value === true


                    onClicked: {
                        if (isConnected) {
                            root.enterPage(index)
                        } else {
                            itemDelegate.wobble()
                        }
                    }

                    ActionQueue {
                        id: actionQueue
                        thing: itemDelegate.thing
                        stateType: thing.thingClass.stateTypes.findByName("brightness")
                    }

                    contentItem: Rectangle {
                        color: enabled && itemDelegate.powerState.value === true && itemDelegate.colorState ? itemDelegate.colorState.value : "#00000000"
                        implicitHeight: contentColumn.implicitHeight
                        Behavior on implicitHeight { NumberAnimation { duration: 100 } }
                        radius: 6
                        enabled: itemDelegate.connectedState == null || connectedState.value === true

                        ColumnLayout {
                            id: contentColumn
                            anchors { left: parent.left; right: parent.right }
                            spacing: 0

                            RowLayout {
                                Layout.leftMargin: app.margins; Layout.rightMargin: app.margins
                                spacing: app.margins

                                ColorIcon {
                                    id: lightIcon
                                    Layout.preferredHeight: app.iconSize
                                    Layout.preferredWidth: app.iconSize
                                    name: itemDelegate.powerState.value === true ? "../images/light-on.svg" : "../images/light-off.svg"
                                    color: itemDelegate.powerState.value === true ? app.accentColor : keyColor
                                    Binding {
                                        target: lightIcon
                                        property: "color"
                                        value: itemDelegate.colorInverted ? app.backgroundColor : app.foregroundColor
                                        when: itemDelegate.tileColored
                                    }
                                }

                                Label {
                                    id: nameLabel
                                    Layout.fillWidth: true
                                    text: itemDelegate.thing.name
                                    elide: Text.ElideRight

                                    Binding {
                                        target: nameLabel
                                        property: "color"
                                        value: itemDelegate.colorInverted ? app.backgroundColor : app.foregroundColor
                                        when: itemDelegate.tileColored
                                    }
                                }

                                ThingStatusIcons {
                                    thing: itemDelegate.thing
                                }

                                Switch {
                                    id: lightSwitch
                                    checked: itemDelegate.powerState.value === true
                                    onClicked: {
                                        var params = [];
                                        var param1 = {};
                                        param1["paramTypeId"] = itemDelegate.powerState.stateTypeId;
                                        param1["value"] = checked;
                                        params.push(param1)
                                        print("executing for thing:", itemDelegate.thing.id)
                                        engine.deviceManager.executeAction(itemDelegate.thing.id, itemDelegate.powerState.stateTypeId, params)
                                    }

                                    indicator: Item {
                                        id: indicator
                                        implicitWidth: 38
                                        implicitHeight: 32
                                        x: lightSwitch.leftPadding + (lightSwitch.availableWidth - width) / 2
                                        y: lightSwitch.topPadding + (lightSwitch.availableHeight - height) / 2

                                        property Item control
                                        property alias handle: handle

                                        Material.elevation: 1

                                        Rectangle {
                                            id: indicatorBackground
                                            width: parent.width
                                            height: 14
                                            radius: height / 2
                                            y: parent.height / 2 - height / 2
                                            color: lightSwitch.enabled ?
                                                       (lightSwitch.checked ? lightSwitch.Material.switchCheckedTrackColor : lightSwitch.Material.switchUncheckedTrackColor)
                                                     : lightSwitch.Material.switchDisabledTrackColor

                                            Binding {
                                                target: indicatorBackground
                                                property: "color"
                                                value: "#808080"
                                                when: itemDelegate.tileColored
                                            }
                                        }

                                        Rectangle {
                                            id: handle
                                            x: Math.max(0, Math.min(parent.width - width, lightSwitch.visualPosition * parent.width - (width / 2)))
                                            y: (parent.height - height) / 2
                                            width: 20
                                            height: 20
                                            radius: width / 2
                                            color: lightSwitch.enabled ? (lightSwitch.checked ? lightSwitch.Material.switchCheckedHandleColor : lightSwitch.Material.switchUncheckedHandleColor)
                                                                   : lightSwitch.Material.switchDisabledHandleColor


                                            Binding {
                                                target: handle
                                                property: "color"
                                                value: "#f0f0f0"
                                                when: itemDelegate.tileColored
                                            }

                                            Behavior on x {
                                                enabled: !lightSwitch.pressed
                                                SmoothedAnimation {
                                                    duration: 300
                                                }
                                            }
//                                            layer.enabled: indicator.Material.elevation > 0
//                                            layer.effect: ElevationEffect {
//                                                elevation: indicator.Material.elevation
//                                            }
                                        }
                                        DropShadow {
                                            anchors.fill: handle
                                            horizontalOffset: 1
                                            verticalOffset: 1
                                            radius: 4.0
                                            samples: 17
                                            color: "#80000000"
                                            source: handle
                                        }
                                    }
                                }
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 12
                                visible: itemDelegate.powerState.value === true && itemDelegate.brightnessState != null
                                radius: 6
                                color: Qt.tint(app.backgroundColor, Qt.rgba(app.foregroundColor.r, app.foregroundColor.g, app.foregroundColor.b, .1))

                                Rectangle {
                                    height: knob.x + knob.width / 2
                                    width: parent.height
                                    anchors.centerIn: parent
                                    anchors.horizontalCenterOffset: -(parent.width - height) / 2
                                    rotation: -90
                                    gradient: Gradient {
                                        GradientStop { position: 0; color: "transparent" }
                                        GradientStop { position: 1; color: "#55ffffff" }
                                    }
                                }

                                Rectangle {
                                    id: knob
                                    height: 14
                                    width: 14
                                    radius: 8
                                    color: "#f0f0f0"
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: itemDelegate.brightnessState ?
                                           (actionQueue.queuedValue || actionQueue.pendingValue || itemDelegate.brightnessState.value) * (parent.width - width) / 100
                                         : 0
                                }
                                DropShadow {
                                    anchors.fill: knob
                                    horizontalOffset: 1
                                    verticalOffset: 1
                                    radius: 4.0
                                    samples: 17
                                    color: "#80000000"
                                    source: knob
                                }

                                MouseArea {
                                    id: brightnessMouseArea
                                    anchors.fill: parent
                                    preventStealing: true
                                    onMouseXChanged: {
                                        actionQueue.sendValue(Math.max(1, Math.min(100, mouseX / width * 100)))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

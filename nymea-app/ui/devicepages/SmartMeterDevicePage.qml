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
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1
import Nymea 1.0
import "../components"
import "../customviews"

DevicePageBase {
    id: root

    readonly property State totalEnergyConsumedState: root.thing.stateByName("totalEnergyConsumed")
    readonly property StateType totalEnergyConsumedStateType: root.thing.thingClass.stateTypes.findByName("totalEnergyConsumed")
    readonly property State totalEnergyProducedState: root.thing.stateByName("totalEnergyProduced")
    readonly property StateType totalEnergyProducedStateType: root.thing.thingClass.stateTypes.findByName("totalEnergyProduced")

    Flickable {
        anchors.fill: parent
        contentHeight: contentGrid.height
        interactive: contentHeight > height

        GridLayout {
            id: contentGrid
            width: parent.width - app.margins
            anchors.horizontalCenter: parent.horizontalCenter
            columns: 1

            BigTile {
                Layout.preferredWidth: contentGrid.width / contentGrid.columns
                showHeader: false
                contentItem: RowLayout {
                    ColorIcon {
                        Layout.preferredHeight: app.iconSize
                        Layout.preferredWidth: app.iconSize
                        name: app.interfaceToIcon("smartmeterconsumer")
                        color: app.interfaceToColor("smartmeterconsumer")
                    }

                    Label {
                        Layout.fillWidth: true
                        text: root.totalEnergyConsumedState.value.toFixed(2) + " " + root.totalEnergyConsumedStateType.unitString
                        font.pixelSize: app.largeFont
                    }
                    ColorIcon {
                        Layout.preferredHeight: app.iconSize
                        Layout.preferredWidth: app.iconSize
                        name: app.interfaceToIcon("smartmeterproducer")
                        color: app.interfaceToColor("smartmeterproducer")
                    }

                    Label {
                        Layout.fillWidth: true
                        text: root.totalEnergyProducedState.value.toFixed(2) + " " + root.totalEnergyProducedStateType.unitString
                        font.pixelSize: app.largeFont
                    }
                }
            }

            GenericTypeGraph {
                Layout.preferredWidth: contentGrid.width / contentGrid.columns
                device: root.device
                stateType: root.deviceClass.stateTypes.findByName("currentPower")
                color: app.interfaceToColor("smartmeterconsumer")
                iconSource: app.interfaceToIcon("smartmeterconsumer")
                roundTo: 5
            }
        }
    }
}

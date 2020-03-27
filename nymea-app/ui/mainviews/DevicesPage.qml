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

import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Controls.Material 2.1
import QtQuick.Layouts 1.2
import Nymea 1.0
import "../components"

MouseArea {
    id: root
    property alias count: interfacesGridView.count
    property alias model: interfacesGridView.model

    // Prevent scroll events to swipe left/right in case they fall through the grid
    preventStealing: true
    onWheel: wheel.accepted = true

    GridView {
        id: interfacesGridView
        anchors.fill: parent
        anchors.margins: app.margins / 2

        readonly property int minTileWidth: 172
        readonly property int tilesPerRow: root.width / minTileWidth

        cellWidth: width / tilesPerRow
        cellHeight: cellWidth
        delegate: DevicesPageDelegate {
            width: interfacesGridView.cellWidth
            height: interfacesGridView.cellHeight
            iface: Interfaces.findByName(model.name)
        }
    }
}

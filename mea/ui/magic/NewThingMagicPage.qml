import QtQuick 2.4
import QtQuick.Controls 2.1
import "../components"
import Mea 1.0

Page {
    id: root
    property alias text: header.text
    property var device: null
    readonly property var deviceClass: Engine.deviceManager.deviceClasses.getDeviceClass(device.deviceClassId)

    header: GuhHeader {
        id: header
        onBackPressed: pageStack.pop()
    }

    ListModel {
        id: eventModel
        ListElement { interfaceName: "temperaturesensor"; text: qsTr("When it's freezing..."); identifier: "freeze"}
        ListElement { interfaceName: "battery"; text: qsTr("When the device runs out of battery..."); identifier: "lowBattery"}
        ListElement { interfaceName: "weather"; text: qsTr("When it starts raining..."); identifier: "rain" }
        ListElement { interfaceName: "weather"; text: qsTr("When it's freezing..."); identifier: "freeze"}
    }

    ListModel {
        id: actionModel
        ListElement { interfaceName: "light"; text: qsTr("Switch light when..."); identifier: "switchLight"}
        ListElement { interfaceName: "dimmablelight"; text: qsTr("Dim light when..."); identifier: "dimLight"}
        ListElement { interfaceName: "colorlight"; text: qsTr("Set light color when..."); identifier: "colorLight" }
        ListElement { interfaceName: "mediacontroller"; text: qsTr("Pause playback when..."); identifier: "pausePlayback" }
        ListElement { interfaceName: "mediacontroller"; text: qsTr("Resume playback when..."); identifier: "resumePlayback" }
        ListElement { interfaceName: "extendedvolumecontroller"; text: qsTr("Set volume..."); identifier: "setVolume" }
        ListElement { interfaceName: "extendedvolumecontroller"; text: qsTr("Mute when..."); identifier: "mute" }
        ListElement { interfaceName: "extendedvolumecontroller"; text: qsTr("Unmute when..."); identifier: "unmute" }
        ListElement { interfaceName: "notifications"; text: qsTr("Notify me when..."); identifier: "notify" }
    }

    function entrySelected(identifier) {
        switch (identifier) {
        case "freeze":
            var page = pageStack.push(Qt.resolvedUrl("SelectActionPage.qml"), {device: root.device })
            page.complete.connect(function() {
                print("have action:", page.actions.length)
                var rule = {};
                rule["name"] = "Freeze in " + root.device.name
                var stateEvaluator = {};
                var stateDescriptor = {};
                stateDescriptor["deviceId"] = root.device.id;
                stateDescriptor["operator"] = "ValueOperatorLessOrEqual";
                stateDescriptor["stateTypeId"] = root.deviceClass.stateTypes.findByName("temperature").id;
                stateDescriptor["value"] = 0;
                stateEvaluator["stateDescriptor"] = stateDescriptor;

                rule["stateEvaluator"] = stateEvaluator;
                rule["actions"] = page.actions;
                Engine.ruleManager.addRule(rule);
                pageStack.pop(root);

            })
        }
    }

    onDeviceClassChanged: {
        actualModel.clear()
        print("device supports interfaces", deviceClass.interfaces)
        for (var i = 0; i < eventModel.count; i++) {
            print("event is for interface", eventModel.get(i).interfaceName)
            if (deviceClass.interfaces.indexOf(eventModel.get(i).interfaceName) >= 0) {
                actualModel.append(eventModel.get(i))
            }
        }
        print("huh")
        for (var i = 0; i < actionModel.count; i++) {
            print("action is for interface", actionModel.get(i).interfaceName)
            if (deviceClass.interfaces.indexOf(actionModel.get(i).interfaceName) >= 0) {
                actualModel.append(actionModel.get(i))
            }
        }
    }

    ListView {
        anchors.fill: parent
        model: ListModel {
            id: actualModel
        }

        delegate: ItemDelegate {
            width: parent.width
            text: model.text

            onClicked: root.entrySelected(model.identifier)
        }
    }
}

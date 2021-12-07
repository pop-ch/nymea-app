import QtQuick 2.0
import QtCharts 2.3
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.3
import Nymea 1.0

ChartView {
    id: root
    backgroundColor: "transparent"
    margins.left: 0
    margins.right: 0
    margins.bottom: 0
    margins.top: 0

    property var colors: null

    title: qsTr("Consumers history")
    titleColor: Style.foregroundColor

    legend.alignment: Qt.AlignBottom
    legend.labelColor: Style.foregroundColor
    legend.font: Style.extraSmallFont

    property ThingsProxy consumers: null

    Connections {
        target: consumers
        onCountChanged: d.updateConsumers()
    }
    Connections {
        target: engine.tagsManager
        onBusyChanged: d.updateConsumers()
    }

    ThingPowerLogs {
        id: thingPowerLogs
        engine: _engine
        startTime: dateTimeAxis.min
        sampleRate: EnergyLogs.SampleRate15Mins
        thingIds: []
        loadingInhibited: thingIds.length === 0

        onEntriesAdded: {
            var thingValues = ({})
            var timestamp = entries[0].timestamp
            for (var i = 0; i < entries.length; i++) {
                var entry = entries[i]
                var thing = engine.thingManager.things.getThing(entries[i].thingId)
                thingValues[entry.thingId] = entry.currentPower
            }

            // Add them in the order of the chart (same as proxy), summing it up
            var totalValue = 0;
            for (var i = 0; i < consumers.count; i++) {
                var consumer = consumers.get(i);
                var value = thingValues.hasOwnProperty(consumer.id) ? thingValues[consumer.id] : 0
                totalValue += thingValues.hasOwnProperty(consumer.id) ? thingValues[consumer.id] : 0;
                var series = d.thingsSeriesMap[consumer.id];
                series.upperSeries.append(timestamp, totalValue)
            }
        }
    }

    property PowerBalanceLogs powerBalanceLogs: PowerBalanceLogs {
        engine: _engine
        startTime: dateTimeAxis.min
        sampleRate: EnergyLogs.SampleRate15Mins

        onEntryAdded: {
            consumptionSeries.addEntry(entry)

            if (dateTimeAxis.now < entry.timestamp) {
                dateTimeAxis.now = entry.timestamp
                zeroSeries.update(entry.timestamp)
            }
        }
    }

    Timer {
        interval: 60000
        repeat: true
        onTriggered: {
            var now = new Date()
            if (dateTimeAxis.now < now) {
                dateTimeAxis.now = now
                zeroSeries.update(now)
            }
        }
    }

    Connections {
        target: engine.thingManager
        onFetchingDataChanged: d.updateConsumers()
        onThingAdded: {
            if (thing.thingClass.interfaces.indexOf("smartmeterconsumer") >= 0) {
                d.updateConsumers();
            }
        }
    }


    Component.onCompleted: {
        for (var i = 0; i < powerBalanceLogs.count; i++) {
            var entry = powerBalanceLogs.get(i);
            consumptionSeries.addEntry(entry)
        }

        d.updateConsumers();
    }

    QtObject {
        id: d
        property var thingsSeriesMap: ({})

        function updateConsumers() {
            if (engine.thingManager.fetchingData || engine.tagsManager.busy) {
                return;
            }
            thingPowerLogs.loadingInhibited = true;

            for (var thingId in d.thingsSeriesMap) {
                root.removeSeries(d.thingsSeriesMap[thingId])
            }
            d.thingsSeriesMap = ({})

            var consumerThingIds = []
            for (var i = 0; i < consumers.count; i++) {
                var thing = consumers.get(i);

                var baseSeries = zeroSeries;
                if (i > 0) {
                    baseSeries = d.thingsSeriesMap[consumerThingIds[i-1]].upperSeries
//                    print("base for:", thing.name, "is", engine.thingManager.things.getThing(consumerThingIds[i-1]).name)
                }

                var series = root.createSeries(ChartView.SeriesTypeArea, thing.name, dateTimeAxis, valueAxis)
                series.lowerSeries = baseSeries
                series.upperSeries = lineSeriesComponent.createObject(series)
                series.color = root.colors[i % root.colors.length]
                series.borderWidth = 0;
                series.borderColor = series.color

//                print("Adding thingId series", thing.id, thing.name)
                var map = d.thingsSeriesMap
                map[thing.id] = series
                d.thingsSeriesMap = map
                consumerThingIds.push(thing.id)
            }
            thingPowerLogs.thingIds = consumerThingIds;
            thingPowerLogs.loadingInhibited = false;
        }
    }

    Component {
        id: lineSeriesComponent
        LineSeries { }
    }

    ValueAxis {
        id: valueAxis
        min: 0
        max: Math.ceil(powerBalanceLogs.maxValue / 1000) * 1000
        labelFormat: ""
        gridLineColor: Style.tileOverlayColor
        labelsVisible: false
        lineVisible: false
        titleVisible: false
        shadesVisible: false
        //        visible: false

    }

    Item {
        id: labelsLayout
        x: Style.smallMargins
        y: root.plotArea.y
        height: root.plotArea.height
        width: plotArea.x - x
        Repeater {
            model: valueAxis.tickCount
            delegate: Label {
                y: parent.height / (valueAxis.tickCount - 1) * index - font.pixelSize / 2
                width: parent.width - Style.smallMargins
                horizontalAlignment: Text.AlignRight
                text: ((valueAxis.max - (index * valueAxis.max / (valueAxis.tickCount - 1))) / 1000).toFixed(2) + "kW"
                verticalAlignment: Text.AlignTop
                font: Style.extraSmallFont
            }
        }
    }

    DateTimeAxis {
        id: dateTimeAxis
        property date now: new Date()
        min: {
            var date = new Date(now);
            date.setTime(date.getTime() - (1000 * 60 * 60 * 24) + 2000);
            return date;
        }
        max: {
            var date = new Date(now);
            date.setTime(date.getTime() + 2000)
            return date;
        }
        format: "hh:mm"
        labelsFont: Style.extraSmallFont
        gridVisible: false
        minorGridVisible: false
        lineVisible: false
        shadesVisible: false
        labelsColor: Style.foregroundColor
    }

    AreaSeries {
        id: consumptionSeries
        axisX: dateTimeAxis
        axisY: valueAxis
        color: Style.gray
        borderWidth: 0
        borderColor: color
        name: qsTr("Unknown")

        lowerSeries: LineSeries {
            id: zeroSeries
            XYPoint { x: dateTimeAxis.min.getTime(); y: 0 }
            XYPoint { x: dateTimeAxis.max.getTime(); y: 0 }
            function update(timestamp) {
                append(timestamp, 0);
                removePoints(1,1);
            }
        }
        upperSeries: LineSeries {
            id: consumptionUpperSeries
        }

        function addEntry(entry) {
            consumptionUpperSeries.append(entry.timestamp.getTime(), entry.consumption)
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.leftMargin: root.plotArea.x
        anchors.topMargin: root.plotArea.y
        anchors.rightMargin: root.width - root.plotArea.width - root.plotArea.x
        anchors.bottomMargin: root.height - root.plotArea.height - root.plotArea.y

        hoverEnabled: true

        Rectangle {
            height: parent.height
            width: 1
            color: Style.foregroundColor
            x: mouseArea.mouseX
            visible: mouseArea.containsMouse
        }

        Item {
            id: toolTip
            visible: mouseArea.containsMouse

            property int idx: consumptionUpperSeries.count - Math.floor(mouseArea.mouseX * consumptionUpperSeries.count / mouseArea.width)
            property int seriesIndex: consumptionUpperSeries.count - idx

            property int xOnRight: mouseArea.mouseX + Style.smallMargins
            property int xOnLeft: mouseArea.mouseX - Style.smallMargins - width
            x: xOnRight + width < mouseArea.width ? xOnRight : xOnLeft
            property double maxValue: consumptionUpperSeries.at(seriesIndex).y
            y: Math.min(Math.max(mouseArea.height - (maxValue * mouseArea.height / valueAxis.max) - height - Style.margins, 0), mouseArea.height - height)

            width: tooltipLayout.implicitWidth + Style.smallMargins * 2
            height: tooltipLayout.implicitHeight + Style.smallMargins * 2

            property date timestamp: new Date(consumptionUpperSeries.at(seriesIndex).x)

            Behavior on x { NumberAnimation { duration: Style.animationDuration } }
            Behavior on y { NumberAnimation { duration: Style.animationDuration } }
            Behavior on width { NumberAnimation { duration: Style.animationDuration } }
            Behavior on height { NumberAnimation { duration: Style.animationDuration } }

            Rectangle {
                anchors.fill: parent
                color: Style.tileOverlayColor
                opacity: .8
                radius: Style.smallCornerRadius
            }

            ColumnLayout {
                id: tooltipLayout
                anchors {
                    left: parent.left
                    top: parent.top
                    margins: Style.smallMargins
                }
                Label {
                    text: toolTip.timestamp.toLocaleString(Qt.locale(), Locale.ShortFormat)
                    font: Style.smallFont
                }
                RowLayout {
                    Rectangle {
                        width: Style.extraSmallFont.pixelSize
                        height: width
                        color: consumptionSeries.color
                    }
                    Label {
                        property double rawValue: consumptionUpperSeries.at(toolTip.seriesIndex).y
                        property double displayValue: rawValue >= 1000 ? rawValue / 1000 : rawValue
                        property string unit: rawValue >= 1000 ? "kW" : "W"
                        text:  "%1: %2 %3".arg(qsTr("Total")).arg(displayValue.toFixed(2)).arg(unit)
                        font: Style.extraSmallFont
                    }
                }

                Repeater {
                    model: consumers
                    delegate: RowLayout {
                        id: consumerToolTipDelegate
                        Rectangle {
                            width: Style.extraSmallFont.pixelSize
                            height: width
                            color: root.colors[index % root.colors.length]
                        }

                        Label {
                            property ThingPowerLogEntry entry: thingPowerLogs.find(model.id, toolTip.timestamp)
                            property double rawValue: entry ? entry.currentPower : 0
                            property double displayValue: rawValue >= 1000 ? rawValue / 1000 : rawValue
                            property string unit: rawValue >= 1000 ? "kW" : "W"
                            text:  "%1: %2 %3".arg(model.name).arg(displayValue.toFixed(2)).arg(unit)
                            font: Style.extraSmallFont
                        }
                    }
                }
            }
        }
    }
}
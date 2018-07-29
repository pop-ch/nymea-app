/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *                                                                         *
 *  Copyright (C) 2017 Simon Stuerz <simon.stuerz@guh.io>                  *
 *                                                                         *
 *  This file is part of nymea:app.                                      *
 *                                                                         *
 *  nymea:app is free software: you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by   *
 *  the Free Software Foundation, version 3 of the License.                *
 *                                                                         *
 *  nymea:app is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the           *
 *  GNU General Public License for more details.                           *
 *                                                                         *
 *  You should have received a copy of the GNU General Public License      *
 *  along with nymea:app. If not, see <http://www.gnu.org/licenses/>.    *
 *                                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef ENGINE_H
#define ENGINE_H

#include <QObject>

#include "devicemanager.h"
#include "nymeainterface.h"
#include "jsonrpc/jsonrpcclient.h"
#include "wifisetup/bluetoothdiscovery.h"

class RuleManager;
class LogManager;
class TagsManager;
class BasicConfiguration;
class AWSClient;

class Engine : public QObject
{
    Q_OBJECT
    Q_PROPERTY(NymeaConnection* connection READ connection CONSTANT)
    Q_PROPERTY(DeviceManager* deviceManager READ deviceManager CONSTANT)
    Q_PROPERTY(RuleManager* ruleManager READ ruleManager CONSTANT)
    Q_PROPERTY(TagsManager* tagsManager READ tagsManager CONSTANT)
    Q_PROPERTY(JsonRpcClient* jsonRpcClient READ jsonRpcClient CONSTANT)
    Q_PROPERTY(BasicConfiguration* basicConfiguration READ basicConfiguration CONSTANT)
    Q_PROPERTY(BluetoothDiscovery* bluetoothDiscovery READ bluetoothDiscovery CONSTANT)
    Q_PROPERTY(AWSClient* awsClient READ awsClient CONSTANT)

public:
    static Engine *instance();

    bool connected() const;
    QString connectedHost() const;

    NymeaConnection *connection() const;
    DeviceManager *deviceManager() const;
    RuleManager *ruleManager() const;
    TagsManager *tagsManager() const;
    JsonRpcClient *jsonRpcClient() const;
    LogManager *logManager() const;
    BasicConfiguration *basicConfiguration() const;
    BluetoothDiscovery *bluetoothDiscovery() const;
    AWSClient* awsClient() const;

private:
    explicit Engine(QObject *parent = nullptr);
    static Engine *s_instance;

    NymeaConnection *m_connection;
    JsonRpcClient *m_jsonRpcClient;
    DeviceManager *m_deviceManager;
    RuleManager *m_ruleManager;
    LogManager *m_logManager;
    TagsManager *m_tagsManager;
    BasicConfiguration *m_basicConfiguration;
    BluetoothDiscovery *m_bluetoothDiscovery;
    AWSClient *m_aws;

private slots:
    void onConnectedChanged();
    void onDeviceManagerFetchingChanged();

};

#endif // ENGINE_H

/*
 * This file was generated by qdbusxml2cpp version 0.8
 * Command line was: qdbusxml2cpp -c BluezAdapter1 -p bluez_adapter1 -v org.bluez.Adapter1.xml
 *
 * qdbusxml2cpp is Copyright (C) 2015 Digia Plc and/or its subsidiary(-ies).
 *
 * This is an auto-generated file.
 * Do not edit! All changes made to it will be lost.
 */

#ifndef BLUEZ_ADAPTER1_H_1442480417
#define BLUEZ_ADAPTER1_H_1442480417

#include <QtCore/QObject>
#include <QtCore/QByteArray>
#include <QtCore/QList>
#include <QtCore/QMap>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QVariant>
#include <QtDBus/QtDBus>

/*
 * Proxy class for interface org.bluez.Adapter1
 */
class BluezAdapter1: public QDBusAbstractInterface
{
    Q_OBJECT
public:
    static inline const char *staticInterfaceName()
    { return "org.bluez.Adapter1"; }

public:
    BluezAdapter1(const QString &service, const QString &path, const QDBusConnection &connection, QObject *parent = 0);

    ~BluezAdapter1();

public Q_SLOTS: // METHODS
    inline QDBusPendingReply<> RemoveDevice(const QDBusObjectPath &device)
    {
        QList<QVariant> argumentList;
        argumentList << QVariant::fromValue(device);
        return asyncCallWithArgumentList(QStringLiteral("RemoveDevice"), argumentList);
    }

    inline QDBusPendingReply<> StartDiscovery()
    {
        QList<QVariant> argumentList;
        return asyncCallWithArgumentList(QStringLiteral("StartDiscovery"), argumentList);
    }

    inline QDBusPendingReply<> StopDiscovery()
    {
        QList<QVariant> argumentList;
        return asyncCallWithArgumentList(QStringLiteral("StopDiscovery"), argumentList);
    }

Q_SIGNALS: // SIGNALS
};

namespace org {
  namespace bluez {
    typedef ::BluezAdapter1 Adapter1;
  }
}
#endif
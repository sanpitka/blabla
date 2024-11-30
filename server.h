// server.h
#ifndef SERVER_H
#define SERVER_H

#include <QTcpServer>
#include <QTcpSocket>
#include <QList>
#include <QObject>

class Server : public QTcpServer
{
    Q_OBJECT

public:
    explicit Server(QObject *parent = nullptr);

    // Mark sendMessage as Q_INVOKABLE so it's callable from QML
    Q_INVOKABLE void sendMessage(const QString &message);  // Add Q_INVOKABLE here

protected:
    void incomingConnection(qintptr socketDescriptor) override;

private slots:
    void onReadyRead();
    void onDisconnected();

private:
    QList<QTcpSocket *> clients;  // List to store connected clients
};

#endif // SERVER_H

// server.h
#ifndef SERVER_H
#define SERVER_H

#include <QTcpServer>
#include <QTcpSocket>
#include <QList>
#include <QObject>
#include <QDateTime>

class Server : public QTcpServer
{
    Q_OBJECT

public:
    explicit Server(QObject *parent = nullptr);
    Q_INVOKABLE void sendMessage(const QString &message);
    Q_INVOKABLE QString prepareMessage(const QString &userMessage);


protected:
    void incomingConnection(qintptr socketDescriptor) override;

private slots:
    void onReadyRead();
    void onDisconnected();

private:
    QList<QTcpSocket *> clients;  // List to store connected clients

signals:
    void newMessageReceived(const QString &message);  // Signal for sending a message to QML
};

#endif // SERVER_H

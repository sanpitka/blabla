// server.cpp
#include "server.h"
#include <QDebug>
#include <QDateTime>

Server::Server(QObject *parent)
    : QTcpServer(parent) {}

void Server::incomingConnection(qintptr socketDescriptor) {
    auto *clientSocket = new QTcpSocket(this);

    if (clientSocket->setSocketDescriptor(socketDescriptor)) {
        clients.append(clientSocket);
        connect(clientSocket, &QTcpSocket::readyRead, this, &Server::onReadyRead);
        connect(clientSocket, &QTcpSocket::disconnected, this, &Server::onDisconnected);

        qDebug() << "New client connected from: " << clientSocket->peerAddress().toString();
    }
    else {
        delete clientSocket;
    }
}

void Server::onReadyRead() {
    auto *clientSocket = qobject_cast<QTcpSocket *>(sender());
    if (!clientSocket) return;

    const QByteArray data = clientSocket->readAll();
    qDebug() << "Message received: " << data;

    clientSocket->write(data);
}

void Server::onDisconnected() {
    auto *clientSocket = qobject_cast<QTcpSocket *>(sender());
    if (!clientSocket) return;

    qDebug() << "Client disconnected: " << clientSocket->peerAddress().toString();
    clients.removeAll(clientSocket);
    clientSocket->deleteLater();
}

QString Server::prepareMessage(const QString &userMessage) {
    QDateTime now = QDateTime::currentDateTime();
    QString timestamp = now.toString("yyyy-MM-dd HH:mm:ss");
    return QString("You: %1 (%2)").arg(userMessage, timestamp);
}

void Server::sendMessage(const QString &message) {
    qDebug() << "Sending message: " << message;
    for (QTcpSocket *clientSocket : clients) {
        if (clientSocket->state() == QAbstractSocket::ConnectedState) {
            clientSocket->write(message.toUtf8());
        }
    }
}

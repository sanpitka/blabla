// server.cpp
#include "server.h"
#include <QDebug>

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

void Server::sendMessage(const QString &message) {
    qDebug() << "Sending message: " << message;
    for (QTcpSocket *clientSocket : clients) {
        if (clientSocket->state() == QAbstractSocket::ConnectedState) {
            clientSocket->write(message.toUtf8());
        }
    }
}

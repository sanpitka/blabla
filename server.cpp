// server.cpp
#include "server.h"
#include <QDebug>
#include <QDateTime>

Server::Server(QObject *parent)
    : QTcpServer(parent) {}

void Server::setUsername(const QString &username) {
    m_username = username;
    qDebug() << "Username set to: " << m_username;
}

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
    QString timestamp = now.toString("HH:mm:ss");
    return QString("%1 at %2: %3").arg(m_username, timestamp, userMessage);
}

void Server::sendMessage(const QString &userMessage) {
    if (m_username.isEmpty()) {
        qDebug() << "Cannot send message. Username is not set.";
        return;
    }

    QDateTime now = QDateTime::currentDateTime();
    QString timestamp = now.toString("HH:mm:ss");
    QString formattedMessage = QString("%1 at %2: %3").arg(m_username, timestamp, userMessage);

    qDebug() << "Sending message:" << formattedMessage;

    for (QTcpSocket *clientSocket : clients) {
        if (clientSocket->state() == QAbstractSocket::ConnectedState) {
            clientSocket->write(formattedMessage.toUtf8());
        }
    }
}

bool Server::validateLogin(const QString &username) {
    if (username.isEmpty()) {
        qDebug() << "Invalid login: username is empty.";
        return false;
    }
    qDebug() << "Valid login for username:" << username;
    return true;
}

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QObject>
#include "server.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    Server server;
    if (!server.listen(QHostAddress::Any, 1337)) {
        qDebug() << "Server failed to start: " << server.errorString();
        return 1;
    }
    qDebug() << "Server is listening on port" << server.serverPort();

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("Blabla", "Main");

    return app.exec();
}

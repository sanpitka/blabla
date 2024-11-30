#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "server.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    Server server;
    if (!server.listen(QHostAddress::Any, 8080)) {
        qDebug() << "Server failed to start: " << server.errorString();
        return 1;
    }
    qDebug() << "Server is listening on port" << server.serverPort();

    QQmlApplicationEngine engine;

    // Expose 'server' object to QML
    engine.rootContext()->setContextProperty("server", &server);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/Blabla/Main.qml")));

    return app.exec();
}

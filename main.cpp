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

    // Expose the 'server' object to the QML environment
    engine.rootContext()->setContextProperty("server", &server);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    QObject::connect(&server, &Server::newMessageReceived, &engine, [&engine](const QString &message) {
        QQmlContext *context = engine.rootContext();
        context->setContextProperty("newMessage", message);
    });

    engine.load(QUrl(QStringLiteral("qrc:/qt/qml/Blabla/Main.qml")));

    return app.exec();
}

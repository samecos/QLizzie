#include <QCoreApplication>
#include <QGuiApplication>
#include <QIcon>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>

#include "appsettings.h"
#include "enginecontroller.h"
#include "fileio.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QCoreApplication::setOrganizationName(QStringLiteral("QLizzie"));
    QCoreApplication::setApplicationName(QStringLiteral("QLizzie"));
    app.setWindowIcon(QIcon(QStringLiteral(":/resources/qlizzie-logo.png")));

    QQmlApplicationEngine engine;
    AppSettings appSettings;
    FileIo fileIo;
    EngineController engineController;
    engine.rootContext()->setContextProperty(QStringLiteral("appSettings"), &appSettings);
    engine.rootContext()->setContextProperty(QStringLiteral("fileIo"), &fileIo);
    engine.rootContext()->setContextProperty(QStringLiteral("engineController"), &engineController);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("QLizzie", "Main");

    return app.exec();
}

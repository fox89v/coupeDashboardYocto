#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include "datahub.h"
#include "measure.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    engine.addImportPath(QStringLiteral(SA_GRAPHICS_QML_IMPORT_PATH));

    qmlRegisterUncreatableType<Measure>("Sa.Domain", 1, 0, "Measure", QStringLiteral("Created in C++"));
    DataHub hub;
    engine.rootContext()->setContextProperty(QStringLiteral("DataHub"), &hub);
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();
}

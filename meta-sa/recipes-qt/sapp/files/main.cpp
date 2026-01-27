#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include "Sa/Graphics/GraphicsUtils.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    int x = GraphicsUtils::clamp(12, 0, 10);
    qDebug() << x;
    return app.exec();
}

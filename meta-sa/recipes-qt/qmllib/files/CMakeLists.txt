cmake_minimum_required(VERSION 3.21)

find_package(Qt6 REQUIRED COMPONENTS Qml Quick)
qt_standard_project_setup()

set(QT_QML_ENABLE_QMLLINT OFF)

qt_add_qml_module(sa_qml_components
    URI Sa.Graphics
    VERSION 1.0
    QML_FILES
        Sa/Graphics/MyCircularGauge.qml
)

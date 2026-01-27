#pragma once
#include <QObject>
#include <QtQml/qqml.h>

class GraphicsUtils : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON
 public:
  using QObject::QObject;

  Q_INVOKABLE static int clamp(int v, int a, int b);
};

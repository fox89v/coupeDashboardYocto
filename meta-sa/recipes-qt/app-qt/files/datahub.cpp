#include "datahub.h"

#include "measure.h"

#include <QMetaType>

DataHub::DataHub(QObject *parent)
    : QObject(parent)
{
    qRegisterMetaType<Measure *>("Measure*");

    auto *speed = new Measure(0.0, 260.0, this);
    auto *rpm = new Measure(0.0, 8000.0, this);
    auto *fuel = new Measure(0.0, 1.0, this);

    speed->setValue(30.0);
    rpm->setValue(1500.0);
    fuel->setValue(0.6);

    m_measures.insert(QStringLiteral("speed"), QVariant::fromValue(speed));
    m_measures.insert(QStringLiteral("rpm"), QVariant::fromValue(rpm));
    m_measures.insert(QStringLiteral("fuel"), QVariant::fromValue(fuel));
}

QVariantMap DataHub::measures() const
{
    return m_measures;
}

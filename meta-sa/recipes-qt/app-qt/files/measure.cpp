#include "measure.h"

#include <QtGlobal>

Measure::Measure(double minimum, double maximum, QObject *parent)
    : QObject(parent)
    , m_minimum(minimum)
    , m_maximum(maximum)
    , m_value(minimum)
{
}

double Measure::value() const
{
    return m_value;
}

double Measure::normalized() const
{
    const double span = m_maximum - m_minimum;
    if (qFuzzyIsNull(span)) {
        return 0.0;
    }
    return (m_value - m_minimum) / span;
}

void Measure::setValue(double newValue)
{
    const double clamped = qBound(m_minimum, newValue, m_maximum);
    if (qFuzzyCompare(clamped, m_value)) {
        return;
    }

    m_value = clamped;
    emit valueChanged();
}

#ifndef MEASURE_H
#define MEASURE_H

#include <QObject>
#include <QMetaType>

class Measure : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double value READ value WRITE setValue NOTIFY valueChanged)
    Q_PROPERTY(double normalized READ normalized NOTIFY valueChanged)

public:
    explicit Measure(double minimum, double maximum, QObject *parent = nullptr);

    double value() const;
    double normalized() const;

public slots:
    void setValue(double newValue);

signals:
    void valueChanged();

private:
    double m_minimum;
    double m_maximum;
    double m_value;
};

Q_DECLARE_METATYPE(Measure *)

#endif // MEASURE_H

#ifndef DATAHUB_H
#define DATAHUB_H

#include <QObject>
#include <QVariantMap>

class Measure;

class DataHub : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantMap measures READ measures CONSTANT)

public:
    explicit DataHub(QObject *parent = nullptr);

    QVariantMap measures() const;

private:
    QVariantMap m_measures;
};

#endif // DATAHUB_H

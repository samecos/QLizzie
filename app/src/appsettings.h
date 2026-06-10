#pragma once

#include <QObject>
#include <QSettings>
#include <QString>
#include <QVariant>

class AppSettings : public QObject
{
    Q_OBJECT

public:
    explicit AppSettings(QObject *parent = nullptr);

    Q_INVOKABLE QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;
    Q_INVOKABLE void setValue(const QString &key, const QVariant &value);
    Q_INVOKABLE void sync();
    Q_INVOKABLE QString fileName() const;

private:
    QString m_fileName;
    mutable QSettings m_settings;
};

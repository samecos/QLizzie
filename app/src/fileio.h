#pragma once

#include <QObject>
#include <QString>
#include <QUrl>

class FileIo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString lastError READ lastError NOTIFY lastErrorChanged)

public:
    explicit FileIo(QObject *parent = nullptr);

    QString lastError() const;

    Q_INVOKABLE QString readTextFile(const QUrl &url);
    Q_INVOKABLE bool writeTextFile(const QUrl &url, const QString &text);

signals:
    void lastErrorChanged();

private:
    void setLastError(const QString &message);

    QString m_lastError;
};

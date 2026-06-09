#include "appsettings.h"

#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QSettings>

namespace {

QString portableRootPath()
{
    const QString environmentRoot = qEnvironmentVariable("QLIZZIE_PORTABLE_ROOT");
    if (!environmentRoot.trimmed().isEmpty())
        return QDir::cleanPath(environmentRoot);

    const QString appDirPath = QCoreApplication::applicationDirPath();
    const QFileInfo appDirInfo(appDirPath);
    if (appDirInfo.fileName().compare(QStringLiteral("app"), Qt::CaseInsensitive) == 0)
        return QDir(appDirPath).absoluteFilePath(QStringLiteral(".."));

    return appDirPath;
}

} // namespace

AppSettings::AppSettings(QObject *parent)
    : QObject(parent)
    , m_fileName(QDir(portableRootPath()).absoluteFilePath(QStringLiteral("settings.ini")))
{
}

QVariant AppSettings::value(const QString &key, const QVariant &defaultValue) const
{
    QSettings settings(m_fileName, QSettings::IniFormat);
    return settings.value(key, defaultValue);
}

void AppSettings::setValue(const QString &key, const QVariant &value)
{
    QSettings settings(m_fileName, QSettings::IniFormat);
    settings.setValue(key, value);
}

void AppSettings::sync()
{
    QSettings settings(m_fileName, QSettings::IniFormat);
    settings.sync();
}

QString AppSettings::fileName() const
{
    return m_fileName;
}

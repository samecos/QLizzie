#pragma once

#include <QObject>
#include <QVariantList>

class GomokuForbidden final : public QObject
{
    Q_OBJECT

public:
    explicit GomokuForbidden(QObject *parent = nullptr);

    Q_INVOKABLE QVariantList forbiddenPoints(const QVariantList &stones,
                                             int boardSizeX,
                                             int boardSizeY) const;
    Q_INVOKABLE bool isForbiddenMove(const QVariantList &stones,
                                     int boardSizeX,
                                     int boardSizeY,
                                     int x,
                                     int y) const;
};

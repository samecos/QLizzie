#include "gomokuforbidden.h"

#include <QVariantMap>
#include <algorithm>

namespace {

constexpr char Empty = 0;
constexpr char Black = 1;
constexpr char White = 2;
constexpr char Border = 3;

struct Direction
{
    int dx = 0;
    int dy = 0;
};

constexpr Direction Directions[] = {
    {1, 0},
    {0, 1},
    {1, 1},
    {1, -1},
};

class ForbiddenPointFinder
{
public:
    ForbiddenPointFinder(int xSize, int ySize)
        : m_xSize(std::max(1, xSize))
        , m_ySize(std::max(1, ySize))
        , m_board((m_xSize + 2) * (m_ySize + 2), Border)
    {
        clear();
    }

    void clear()
    {
        std::fill(m_board.begin(), m_board.end(), Border);
        for (int y = 1; y <= m_ySize; ++y) {
            for (int x = 1; x <= m_xSize; ++x)
                cell(x, y) = Empty;
        }
    }

    void setStone(int x, int y, char stone)
    {
        if (inBoard(x, y))
            cell(x + 1, y + 1) = stone;
    }

    bool isForbidden(int x, int y)
    {
        if (!inBoard(x, y) || atExternal(x, y) != Empty)
            return false;

        int nearbyBlack = 0;
        const int cx = x + 1;
        const int cy = y + 1;
        if (cx >= 2 && cx <= m_xSize - 1 && cy >= 2 && cy <= m_ySize - 1) {
            static constexpr int offsets[][2] = {
                {2, 2}, {2, 0}, {2, -2}, {0, 2}, {0, -2}, {-2, -2}, {-2, 0}, {-2, 2},
                {1, -1}, {1, 0}, {1, 1}, {0, -1}, {0, 1}, {-1, -1}, {-1, 0}, {-1, 1},
            };
            for (const auto &offset : offsets) {
                if (atInternal(cx + offset[0], cy + offset[1]) == Black)
                    ++nearbyBlack;
            }
        } else {
            for (int ix = std::max(cx - 2, 1); ix <= std::min(cx + 2, m_xSize); ++ix) {
                for (int iy = std::max(cy - 2, 1); iy <= std::min(cy + 2, m_ySize); ++iy) {
                    const int dx = std::abs(ix - cx);
                    const int dy = std::abs(iy - cy);
                    if ((dx + dy) != 3 && atInternal(ix, iy) == Black)
                        ++nearbyBlack;
                }
            }
        }

        if (nearbyBlack < 2)
            return false;
        return isForbiddenNoNearbyCheck(x, y);
    }

private:
    bool inBoard(int x, int y) const
    {
        return x >= 0 && x < m_xSize && y >= 0 && y < m_ySize;
    }

    int index(int ix, int iy) const
    {
        return iy * (m_xSize + 2) + ix;
    }

    char &cell(int ix, int iy)
    {
        return m_board[index(ix, iy)];
    }

    char atInternal(int ix, int iy) const
    {
        if (ix < 0 || ix > m_xSize + 1 || iy < 0 || iy > m_ySize + 1)
            return Border;
        return m_board[index(ix, iy)];
    }

    char atExternal(int x, int y) const
    {
        return atInternal(x + 1, y + 1);
    }

    bool isFive(int x, int y, int color)
    {
        if (!inBoard(x, y) || atExternal(x, y) != Empty)
            return false;

        const char stone = color == Black ? Black : color == White ? White : Empty;
        if (stone == Empty)
            return false;

        setStone(x, y, stone);
        bool result = false;
        for (const Direction &direction : Directions) {
            const int length = lineLengthThroughStone(x, y, stone, direction);
            if ((stone == Black && length == 5) || (stone == White && length >= 5)) {
                result = true;
                break;
            }
        }
        setStone(x, y, Empty);
        return result;
    }

    bool isFive(int x, int y, int color, int directionIndex)
    {
        if (!inBoard(x, y) || atExternal(x, y) != Empty)
            return false;

        const char stone = color == Black ? Black : color == White ? White : Empty;
        if (stone == Empty || directionIndex < 1 || directionIndex > 4)
            return false;

        setStone(x, y, stone);
        const bool result = lineLengthThroughStone(x, y, stone, Directions[directionIndex - 1]) == 5;
        setStone(x, y, Empty);
        return result;
    }

    int lineLengthThroughStone(int x, int y, char stone, Direction direction) const
    {
        int length = 1;
        for (int side : {-1, 1}) {
            int cx = x + direction.dx * side;
            int cy = y + direction.dy * side;
            while (atExternal(cx, cy) == stone) {
                ++length;
                cx += direction.dx * side;
                cy += direction.dy * side;
            }
        }
        return length;
    }

    bool isOverline(int x, int y)
    {
        if (!inBoard(x, y) || atExternal(x, y) != Empty)
            return false;

        setStone(x, y, Black);
        bool overline = false;
        for (const Direction &direction : Directions) {
            const int length = lineLengthThroughStone(x, y, Black, direction);
            if (length == 5) {
                setStone(x, y, Empty);
                return false;
            }
            overline = overline || length >= 6;
        }
        setStone(x, y, Empty);
        return overline;
    }

    bool isFour(int x, int y, int color, int directionIndex)
    {
        if (!inBoard(x, y) || atExternal(x, y) != Empty)
            return false;
        if (isFive(x, y, color))
            return false;
        if (color == Black && isOverline(x, y))
            return false;
        if (directionIndex < 1 || directionIndex > 4)
            return false;

        const char stone = color == Black ? Black : color == White ? White : Empty;
        if (stone == Empty)
            return false;

        const Direction direction = Directions[directionIndex - 1];
        setStone(x, y, stone);
        for (int side : {-1, 1}) {
            int cx = x + direction.dx * side;
            int cy = y + direction.dy * side;
            while (true) {
                const char value = atExternal(cx, cy);
                if (value == stone) {
                    cx += direction.dx * side;
                    cy += direction.dy * side;
                    continue;
                }
                if (value == Empty && isFive(cx, cy, stone, directionIndex)) {
                    setStone(x, y, Empty);
                    return true;
                }
                break;
            }
        }
        setStone(x, y, Empty);
        return false;
    }

    int isOpenFour(int x, int y, int color, int directionIndex)
    {
        if (!inBoard(x, y) || atExternal(x, y) != Empty)
            return 0;
        if (isFive(x, y, color))
            return 0;
        if (color == Black && isOverline(x, y))
            return 0;
        if (directionIndex < 1 || directionIndex > 4)
            return 0;

        const char stone = color == Black ? Black : color == White ? White : Empty;
        if (stone == Empty)
            return 0;

        const Direction direction = Directions[directionIndex - 1];
        int lineLength = 1;
        setStone(x, y, stone);

        int cx = x - direction.dx;
        int cy = y - direction.dy;
        while (true) {
            const char value = atExternal(cx, cy);
            if (value == stone) {
                cx -= direction.dx;
                cy -= direction.dy;
                ++lineLength;
                continue;
            }
            if (value == Empty) {
                if (!isFive(cx, cy, stone, directionIndex)) {
                    setStone(x, y, Empty);
                    return 0;
                }
                break;
            }
            setStone(x, y, Empty);
            return 0;
        }

        cx = x + direction.dx;
        cy = y + direction.dy;
        while (true) {
            const char value = atExternal(cx, cy);
            if (value == stone) {
                cx += direction.dx;
                cy += direction.dy;
                ++lineLength;
                continue;
            }
            if (value == Empty) {
                if (isFive(cx, cy, stone, directionIndex)) {
                    setStone(x, y, Empty);
                    return lineLength == 4 ? 1 : 2;
                }
                break;
            }
            break;
        }

        setStone(x, y, Empty);
        return 0;
    }

    bool isDoubleFour(int x, int y)
    {
        if (!inBoard(x, y) || atExternal(x, y) != Empty)
            return false;
        if (isFive(x, y, Black))
            return false;

        int fours = 0;
        for (int directionIndex = 1; directionIndex <= 4; ++directionIndex) {
            if (isOpenFour(x, y, Black, directionIndex) == 2)
                fours += 2;
            else if (isFour(x, y, Black, directionIndex))
                ++fours;
        }
        return fours >= 2;
    }

    bool isOpenThree(int x, int y, int color, int directionIndex)
    {
        if (!inBoard(x, y) || atExternal(x, y) != Empty)
            return false;
        if (isFive(x, y, color))
            return false;
        if (color == Black && isOverline(x, y))
            return false;
        if (directionIndex < 1 || directionIndex > 4)
            return false;

        const char stone = color == Black ? Black : color == White ? White : Empty;
        if (stone == Empty)
            return false;

        const Direction direction = Directions[directionIndex - 1];
        setStone(x, y, stone);
        for (int side : {-1, 1}) {
            int cx = x + direction.dx * side;
            int cy = y + direction.dy * side;
            while (true) {
                const char value = atExternal(cx, cy);
                if (value == stone) {
                    cx += direction.dx * side;
                    cy += direction.dy * side;
                    continue;
                }
                if (value == Empty) {
                    if (isOpenFour(cx, cy, color, directionIndex) == 1
                        && !isDoubleFour(cx, cy)
                        && !isDoubleThree(cx, cy)) {
                        setStone(x, y, Empty);
                        return true;
                    }
                    break;
                }
                break;
            }
        }
        setStone(x, y, Empty);
        return false;
    }

    bool isDoubleThree(int x, int y)
    {
        if (!inBoard(x, y) || atExternal(x, y) != Empty)
            return false;
        if (isFive(x, y, Black))
            return false;

        int threes = 0;
        for (int directionIndex = 1; directionIndex <= 4; ++directionIndex) {
            if (isOpenThree(x, y, Black, directionIndex))
                ++threes;
        }
        return threes >= 2;
    }

    bool isForbiddenNoNearbyCheck(int x, int y)
    {
        return isDoubleThree(x, y) || isDoubleFour(x, y) || isOverline(x, y);
    }

    int m_xSize = 1;
    int m_ySize = 1;
    QVector<char> m_board;
};

void loadStones(ForbiddenPointFinder &finder, const QVariantList &stones, int boardSizeX, int boardSizeY)
{
    for (const QVariant &value : stones) {
        const QVariantMap map = value.toMap();
        const int x = map.value(QStringLiteral("x")).toInt();
        const int y = map.value(QStringLiteral("y")).toInt();
        const int player = map.value(QStringLiteral("player")).toInt();
        if (x < 0 || x >= boardSizeX || y < 0 || y >= boardSizeY)
            continue;
        if (player == 1)
            finder.setStone(x, y, Black);
        else if (player == 2)
            finder.setStone(x, y, White);
    }
}

} // namespace

GomokuForbidden::GomokuForbidden(QObject *parent)
    : QObject(parent)
{
}

QVariantList GomokuForbidden::forbiddenPoints(const QVariantList &stones,
                                              int boardSizeX,
                                              int boardSizeY) const
{
    QVariantList points;
    if (boardSizeX <= 0 || boardSizeY <= 0)
        return points;

    ForbiddenPointFinder finder(boardSizeX, boardSizeY);
    loadStones(finder, stones, boardSizeX, boardSizeY);
    for (int y = 0; y < boardSizeY; ++y) {
        for (int x = 0; x < boardSizeX; ++x) {
            if (!finder.isForbidden(x, y))
                continue;
            QVariantMap point;
            point.insert(QStringLiteral("x"), x);
            point.insert(QStringLiteral("y"), y);
            point.insert(QStringLiteral("key"), QString::number(x) + QStringLiteral(",") + QString::number(y));
            points.push_back(point);
        }
    }
    return points;
}

bool GomokuForbidden::isForbiddenMove(const QVariantList &stones,
                                      int boardSizeX,
                                      int boardSizeY,
                                      int x,
                                      int y) const
{
    if (boardSizeX <= 0 || boardSizeY <= 0 || x < 0 || y < 0 || x >= boardSizeX || y >= boardSizeY)
        return false;

    ForbiddenPointFinder finder(boardSizeX, boardSizeY);
    loadStones(finder, stones, boardSizeX, boardSizeY);
    return finder.isForbidden(x, y);
}

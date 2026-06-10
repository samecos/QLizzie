.pragma library

var RULE_GO = 0
var RULE_GOMOKU = 1
var RULE_HEX = 2

var GOMOKU_RULE_CON5 = 0
var GOMOKU_RULE_STDCON5 = 1
var GOMOKU_RULE_FREESTYLE = 2
var GOMOKU_RULE_STANDARD = 3
var GOMOKU_RULE_CON7 = 4
var GOMOKU_RULE_DIRECT_CON5 = 5

var NEIGHBOR_OFFSETS = [
    { "dx": 1, "dy": 0 },
    { "dx": -1, "dy": 0 },
    { "dx": 0, "dy": 1 },
    { "dx": 0, "dy": -1 }
]

var HEX_NEIGHBOR_OFFSETS = [
    { "dx": 1, "dy": 0 },
    { "dx": -1, "dy": 0 },
    { "dx": 0, "dy": 1 },
    { "dx": 0, "dy": -1 },
    { "dx": 1, "dy": -1 },
    { "dx": -1, "dy": 1 }
]

var GOMOKU_DIRECTIONS = [
    { "dx": 1, "dy": 0 },
    { "dx": 0, "dy": 1 },
    { "dx": 1, "dy": 1 },
    { "dx": 1, "dy": -1 }
]

function keyFor(x, y) {
    return x + "," + y
}

function pointInBoard(dims, x, y) {
    return x >= 0 && x < dims.x && y >= 0 && y < dims.y
}

function stoneMapDataAt(map, x, y) {
    var value = map[keyFor(x, y)]
    return value === undefined ? null : value
}

function stoneMapPlayerAt(map, x, y) {
    var value = stoneMapDataAt(map, x, y)
    return value ? value.player : 0
}

function cloneStoneMap(map) {
    var nextMap = ({})
    for (var key in map) {
        var value = map[key]
        nextMap[key] = {
            "x": value.x,
            "y": value.y,
            "key": value.key,
            "player": value.player,
            "moveNumber": value.moveNumber,
            "nodeId": value.nodeId
        }
    }
    return nextMap
}

function copyStoneItem(stone) {
    return {
        "x": stone.x,
        "y": stone.y,
        "key": stone.key,
        "player": stone.player,
        "moveNumber": stone.moveNumber,
        "nodeId": stone.nodeId
    }
}

function collectGroupInMap(map, dims, x, y, visited) {
    var start = stoneMapDataAt(map, x, y)
    if (!start)
        return []

    var group = []
    var stack = [start]
    var player = start.player
    while (stack.length > 0) {
        var stone = stack.pop()
        if (visited[stone.key])
            continue

        visited[stone.key] = true
        group.push(stone)
        for (var i = 0; i < NEIGHBOR_OFFSETS.length; ++i) {
            var offset = NEIGHBOR_OFFSETS[i]
            var nx = stone.x + offset.dx
            var ny = stone.y + offset.dy
            if (!pointInBoard(dims, nx, ny))
                continue

            var neighbor = stoneMapDataAt(map, nx, ny)
            if (neighbor && neighbor.player === player && !visited[neighbor.key])
                stack.push(neighbor)
        }
    }
    return group
}

function groupHasLibertyInMap(map, dims, group) {
    for (var i = 0; i < group.length; ++i) {
        var stone = group[i]
        for (var n = 0; n < NEIGHBOR_OFFSETS.length; ++n) {
            var offset = NEIGHBOR_OFFSETS[n]
            var nx = stone.x + offset.dx
            var ny = stone.y + offset.dy
            if (pointInBoard(dims, nx, ny) && stoneMapPlayerAt(map, nx, ny) === 0)
                return true
        }
    }
    return false
}

function groupLibertyCountInMap(map, dims, group) {
    var liberties = ({})
    var count = 0
    for (var i = 0; i < group.length; ++i) {
        var stone = group[i]
        for (var n = 0; n < NEIGHBOR_OFFSETS.length; ++n) {
            var offset = NEIGHBOR_OFFSETS[n]
            var nx = stone.x + offset.dx
            var ny = stone.y + offset.dy
            if (!pointInBoard(dims, nx, ny) || stoneMapPlayerAt(map, nx, ny) !== 0)
                continue

            var libertyKey = keyFor(nx, ny)
            if (!liberties[libertyKey]) {
                liberties[libertyKey] = true
                count += 1
            }
        }
    }
    return count
}

function removeGroupFromMap(map, group) {
    for (var i = 0; i < group.length; ++i)
        delete map[group[i].key]
}

function goMoveResult(ok, captured, reason, capturedStones, ownGroupSize, ownLibertyCount) {
    return {
        "ok": ok,
        "captured": captured,
        "reason": reason,
        "capturedStones": capturedStones || [],
        "ownGroupSize": ownGroupSize || 0,
        "ownLibertyCount": ownLibertyCount || 0
    }
}

function simulateGoMoveOnMap(map, dims, stoneItem, collectKoInfo) {
    if (map[stoneItem.key] !== undefined)
        return goMoveResult(false, 0, "occupied")

    map[stoneItem.key] = stoneItem

    var captured = 0
    var capturedStones = []
    var opponent = stoneItem.player === 1 ? 2 : 1
    var checked = ({})
    for (var i = 0; i < NEIGHBOR_OFFSETS.length; ++i) {
        var offset = NEIGHBOR_OFFSETS[i]
        var nx = stoneItem.x + offset.dx
        var ny = stoneItem.y + offset.dy
        var neighbor = pointInBoard(dims, nx, ny) ? stoneMapDataAt(map, nx, ny) : null
        if (!neighbor || neighbor.player !== opponent || checked[neighbor.key])
            continue

        var group = collectGroupInMap(map, dims, nx, ny, ({}))
        for (var g = 0; g < group.length; ++g)
            checked[group[g].key] = true
        if (!groupHasLibertyInMap(map, dims, group)) {
            captured += group.length
            if (collectKoInfo) {
                for (var c = 0; c < group.length; ++c)
                    capturedStones.push(copyStoneItem(group[c]))
            }
            removeGroupFromMap(map, group)
        }
    }

    var ownGroup = collectGroupInMap(map, dims, stoneItem.x, stoneItem.y, ({}))
    if (!groupHasLibertyInMap(map, dims, ownGroup)) {
        delete map[stoneItem.key]
        for (var r = 0; r < capturedStones.length; ++r)
            map[capturedStones[r].key] = capturedStones[r]
        return goMoveResult(false, captured, "suicide", capturedStones, ownGroup.length, 0)
    }

    var ownLibertyCount = collectKoInfo ? groupLibertyCountInMap(map, dims, ownGroup) : 0
    return goMoveResult(true, captured, "", capturedStones, ownGroup.length, ownLibertyCount)
}

function pointLegalInMap(map, dims, x, y, player, activeKoLocKey, ruleMode) {
    if (!pointInBoard(dims, x, y) || stoneMapPlayerAt(map, x, y) !== 0)
        return false

    if (ruleMode !== RULE_GO)
        return true

    var pointKey = keyFor(x, y)
    if (activeKoLocKey !== "" && pointKey === activeKoLocKey)
        return false

    var item = {
        "x": x,
        "y": y,
        "key": pointKey,
        "player": player,
        "moveNumber": 0,
        "nodeId": -1
    }
    return simulateGoMoveOnMap(cloneStoneMap(map), dims, item, false).ok
}

function buildPointLegalityMap(map, dims, player, activeKoLocKey, ruleMode) {
    var result = ({})
    for (var y = 0; y < dims.y; ++y) {
        for (var x = 0; x < dims.x; ++x)
            result[keyFor(x, y)] = pointLegalInMap(map, dims, x, y, player, activeKoLocKey, ruleMode)
    }
    return result
}

function emptyKoLoc() {
    return { "key": "", "x": -1, "y": -1 }
}

function koLocFromGoMoveResult(ruleMode, result) {
    if (ruleMode !== RULE_GO || !result || !result.ok
            || result.captured !== 1
            || result.capturedStones.length !== 1
            || result.ownGroupSize !== 1
            || result.ownLibertyCount !== 1)
        return emptyKoLoc()

    var captured = result.capturedStones[0]
    return { "key": captured.key, "x": captured.x, "y": captured.y }
}

function gomokuRuleTargetLength(gomokuRuleMode) {
    if (gomokuRuleMode === GOMOKU_RULE_FREESTYLE || gomokuRuleMode === GOMOKU_RULE_STANDARD)
        return 6
    if (gomokuRuleMode === GOMOKU_RULE_CON7)
        return 7
    return 5
}

function gomokuRuleExactLength(gomokuRuleMode) {
    return gomokuRuleMode === GOMOKU_RULE_STDCON5 || gomokuRuleMode === GOMOKU_RULE_STANDARD
}

function gomokuRuleUsesDirection(gomokuRuleMode, direction) {
    if (gomokuRuleMode !== GOMOKU_RULE_DIRECT_CON5)
        return true
    return (Math.abs(direction.dx) + Math.abs(direction.dy)) === 1
}

function gomokuRunWins(length, gomokuRuleMode) {
    var target = gomokuRuleTargetLength(gomokuRuleMode)
    if (gomokuRuleExactLength(gomokuRuleMode))
        return length === target
    return length >= target
}

function buildGomokuWinRuns(map, dims, ruleMode, gomokuRuleMode) {
    if (ruleMode !== RULE_GOMOKU)
        return []

    var lines = []
    for (var key in map) {
        var stone = map[key]
        for (var d = 0; d < GOMOKU_DIRECTIONS.length; ++d) {
            var direction = GOMOKU_DIRECTIONS[d]
            if (!gomokuRuleUsesDirection(gomokuRuleMode, direction))
                continue

            var px = stone.x - direction.dx
            var py = stone.y - direction.dy
            if (pointInBoard(dims, px, py) && stoneMapPlayerAt(map, px, py) === stone.player)
                continue

            var run = []
            var x = stone.x
            var y = stone.y
            while (pointInBoard(dims, x, y) && stoneMapPlayerAt(map, x, y) === stone.player) {
                run.push(stoneMapDataAt(map, x, y))
                x += direction.dx
                y += direction.dy
            }

            if (!gomokuRunWins(run.length, gomokuRuleMode))
                continue

            var start = run[0]
            var end = run[run.length - 1]
            lines.push({
                "dx": direction.dx,
                "dy": direction.dy,
                "startX": start.x,
                "startY": start.y,
                "endX": end.x,
                "endY": end.y,
                "player": stone.player
            })
        }
    }
    return lines
}

function hexPlayerReachedGoal(player, dims, stone) {
    if (player === 1)
        return stone.y === dims.y - 1
    return stone.x === dims.x - 1
}

function reconstructHexPath(map, parentByKey, endKey) {
    var keys = []
    var key = endKey
    while (key !== "") {
        keys.push(key)
        key = parentByKey[key] || ""
    }
    keys.reverse()

    var path = []
    for (var i = 0; i < keys.length; ++i) {
        var stone = map[keys[i]]
        if (stone)
            path.push(copyStoneItem(stone))
    }
    return path
}

function buildHexWinPathForPlayer(map, dims, player) {
    var queue = []
    var visited = ({})
    var parentByKey = ({})

    if (player === 1) {
        for (var x = 0; x < dims.x; ++x) {
            var blackStart = stoneMapDataAt(map, x, 0)
            if (!blackStart || blackStart.player !== player)
                continue
            queue.push(blackStart)
            visited[blackStart.key] = true
            parentByKey[blackStart.key] = ""
        }
    } else {
        for (var y = 0; y < dims.y; ++y) {
            var whiteStart = stoneMapDataAt(map, 0, y)
            if (!whiteStart || whiteStart.player !== player)
                continue
            queue.push(whiteStart)
            visited[whiteStart.key] = true
            parentByKey[whiteStart.key] = ""
        }
    }

    var head = 0
    while (head < queue.length) {
        var stone = queue[head++]
        if (hexPlayerReachedGoal(player, dims, stone))
            return reconstructHexPath(map, parentByKey, stone.key)

        for (var n = 0; n < HEX_NEIGHBOR_OFFSETS.length; ++n) {
            var offset = HEX_NEIGHBOR_OFFSETS[n]
            var nx = stone.x + offset.dx
            var ny = stone.y + offset.dy
            if (!pointInBoard(dims, nx, ny))
                continue

            var neighbor = stoneMapDataAt(map, nx, ny)
            if (!neighbor || neighbor.player !== player || visited[neighbor.key])
                continue

            visited[neighbor.key] = true
            parentByKey[neighbor.key] = stone.key
            queue.push(neighbor)
        }
    }
    return []
}

function buildHexWinPath(map, dims, ruleMode) {
    if (ruleMode !== RULE_HEX)
        return { "player": 0, "path": [] }

    var blackPath = buildHexWinPathForPlayer(map, dims, 1)
    if (blackPath.length > 0)
        return { "player": 1, "path": blackPath }

    var whitePath = buildHexWinPathForPlayer(map, dims, 2)
    if (whitePath.length > 0)
        return { "player": 2, "path": whitePath }

    return { "player": 0, "path": [] }
}

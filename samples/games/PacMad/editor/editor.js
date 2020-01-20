// JavaScript Document
const
    tools = {
        DOTS : 0,
        EMPTY : 1,
        VOID : 2,
        PILL : 3,
        SPAWNER : 4,
        WARP : 5,
        START : 6,
        EXIT : 7,
        "SHIFT UP" : 8,
        "SHIFT DOWN" : 9,
        DELETE : 10,
        UNDO : 11,
    },
    emptyBoard = {
        start : {x: 10, y: 1},
        exit : {x: 10, y: 0},
        ai : [1,2,3,4],
        spawnerDelay: 5,
        pillLength: 10,
        remain: 0,
        colors: [0x8C,0x84,0x82],
        dots: [],
        empty: [],
        void: [],
        pills: [],
        spawners: [],
        warps: [],
    },
    MAX_SPAWNERS = 10,
    COLOR_PACMAD = 0x1c,
    TILE_VOID = 0,
    TILE_DOT = 1,
    TILE_EMPTY = 2,
    TILE_PILL = 3,
    TILE_SPAWNER = 4,
    TILE_WARP_LEFT = 8,
    BOARD_HEIGHT = 99;

let board = $.extend(true, {}, emptyBoard),
    outputsize = 0,
    undoHistory = [],
    currentTool,
    paintRect,
    rect = {},
    cells = [];
    source = "";
    sourceChanged = false;

function isNumber (n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
}

function saveUndoState () {
    undoHistory.push(JSON.stringify(board));
}

function restoreUndoState () {
    if (undoHistory.length > 0) {
        board = JSON.parse(undoHistory.pop());
        refreshBoard();
    }
}

function refreshBoard () {
    paintBoard();
    renderCode();
}

function resetBoard (hard) {
    if (hard || confirm('It will reset all board data and undo history!\n\nAre you sure?')) {
        board = $.extend(true, {}, emptyBoard);

        paintRect = false;
        cells = [];
        undoHistory = [];
        refreshBoard();
        saveUndoState();
    }
}

function createToolbox () {
    for (tool in tools) {
        if (tools[tool] == 8 ) {
            $('#toolbox').append($('<hr>').addClass('tool_hr'));
            $('#toolbox').append('Board:<br>');
        }
        if (tools[tool] == 10) $('#toolbox').append($('<hr>').addClass('tool_hr'));
        var tooldiv = $('<button></button>').addClass('tool').attr('id', 'tool_' + tools[tool]);
        let j = tools[tool];
        tooldiv.html(tool.toLowerCase());
        tooldiv.bind('mousedown', function () {
            selectTool(j)
        });
        $('#toolbox').append(tooldiv);
    }
}

function selectTool (i) {
    if (i == tools.UNDO) {
        restoreUndoState();
        return true;
    }
    if (i == tools["SHIFT UP"]) {
        shiftBoard(-1);
        return true;
    }
    if (i == tools["SHIFT DOWN"]) {
        shiftBoard(1);
        return true;
    }
    if (i == tools.UNDO) {
        restoreUndoState();
        return true;
    }
    $('.tool').removeClass('tool_selected');
    $('#tool_' + i).addClass('tool_selected');
    currentTool = i;
    $('#currentTool').html(tools[i]);

}

function moveY(valY,delta) {
    valY = parseInt(valY) + parseInt(delta);
    return Math.min(Math.max(parseInt(valY), 0), BOARD_HEIGHT);
}

function shiftBoard(delta) {
    board.start.y = moveY(board.start.y, delta);
    board.exit.y = moveY(board.exit.y, delta);
    const propY = ['y','y1','y2'];
    for (let blockname in board) {
        let block = board[blockname];
        if (blockname == 'warps')
            for (let item in block) block[item] = moveY(block[item], delta);
        if ($.isArray(block))
            for (let item of block)
                for (let prop of propY)
                    if (item[prop] !== undefined) item[prop] = moveY(item[prop], delta);
    }
    refreshBoard();
}

function parseCode (force) {
    saveUndoState();
    let newBoard = board = $.extend(true, {}, emptyBoard);
    if (force===true || confirm('are you sure?')) {
        let txt = $('#outbox').val();
        let txtblocks = txt.split('TILE_');

        // parse header
        let block1 = txtblocks[0].split('\n');
        let posb = [];
        for (let line of block1) {
            let aline = line.trim().split(/,| /);
            if (aline[0] == 'dta') posb.push(aline);
        }
        if (posb.length != 8)  {
            alert('header parse error !!!\n');
            return false;
        }

        newBoard.start = {x: parseInt(posb[0][1]), y: parseInt(posb[0][2])};
        newBoard.exit = {x: parseInt(posb[1][1]), y: parseInt(posb[1][2])};
        newBoard.ai[0] = parseInt(posb[2][1]);
        newBoard.ai[1] = parseInt(posb[2][2]);
        newBoard.ai[2] = parseInt(posb[2][3]);
        newBoard.ai[3] = parseInt(posb[2][4]);
        newBoard.spawnerDelay = parseInt(posb[3][1]);
        newBoard.pillLength = parseInt(posb[4][1]);
        newBoard.remain = parseInt(posb[5][1].substring(2));
        newBoard.colors[0] = parseInt(posb[6][1].substring(1),16);
        newBoard.colors[1] = parseInt(posb[6][2].substring(1),16);
        newBoard.colors[2] = parseInt(posb[6][5].substring(1),16);

        // parse blocks

        for (let i = 1; i < txtblocks.length; i++) {
            let block = txtblocks[i].split('\n');
            let data = [];
            let header = block[0].split(',');
            for (let line of block) {
                let aline = line.trim().split(/,| /);
                if ((aline.length > 1) && (aline[0] == 'dta') && isNumber(aline[1])) data.push(aline);
            }
            switch (header[0]) {
            case 'DOT':
                newBoard.dots = dataAssign(data, 4);
                break;
            case 'EMPTY':
                newBoard.empty = dataAssign(data, 4);
                break;
            case 'VOID':
                newBoard.void = dataAssign(data, 4);
                break;
            case 'SPAWNER':
                newBoard.spawners = dataAssign(data, 2);
                break;
            case 'WARP_LEFT':
                newBoard.warps = dataAssign(data, 1);
                break;
            case 'PILL':
                newBoard.pills = dataAssign(data, 2);
                break;
            }
        }
    }
    board = $.extend({}, newBoard);
    refreshBoard();
}

function dataAssign (inArray, dataCount) {
    var outArray = [];
    for (let line of inArray) {
        if (dataCount == 1) outArray.push(Number(line[1]));
        if (dataCount == 2) outArray.push({x: parseInt(line[1]), y: parseInt(line[2])});
        if (dataCount == 4) outArray.push({
            x1: parseInt(line[1]), y1: parseInt(line[2]), w: parseInt(line[3]), h: parseInt(line[4]),
            x2: Number(line[1]) + Number(line[3]) - 1, y2: Number(line[2]) + Number(line[4]) - 1
        });
    }
    return outArray;
}

function promptForRender() {
    if (confirm('Source code has been changed!\n\n Do you wish to reparse data?\n\n\nIf you messed up things unwisely, you should be able to undo your action.')) {
        parseCode(true);
    }
}


function leaveSource() {
    if (sourceChanged && (source != $("#outbox").val())) promptForRender();
}

function sourceEntry() {
    sourceChanged = true;
}

function inputChange(e) {
    var caller =e.target.id;
    saveUndoState();
    switch (caller) {
        case 'ai0':
        case 'ai1':
        case 'ai2':
        case 'ai3':
            var ai = parseInt(e.target.value);
            var idx = Number(caller.substr(caller.length -1));
            if (isNaN(ai) || (ai<1 || ai>9)) {
                alert('Invalid value or out of range!\n\n1:dummy - 9:ninja');
                board.ai[idx] = emptyBoard.ai;
            } else {
                board.ai[idx] = ai
            }
            break;
        case 'delaytime':
            var spawnerDelay = parseInt(e.target.value);
            if (isNaN(spawnerDelay) || (spawnerDelay<1 || spawnerDelay>255)) {
                alert('Invalid value or out of range!\n\n1-255 seconds');
                board.spawnerDelay = emptyBoard.spawnerDelay;
            } else {
                board.spawnerDelay = spawnerDelay
            }
            break;
        case 'pilltime':
            var pillLength = parseInt(e.target.value);
            if (isNaN(pillLength) || (pillLength<1 || pillLength>255)) {
                alert('Invalid value or out of range!\n\n1-255 seconds');
                board.pillLength = emptyBoard.pillLength;
            } else {
                board.pillLength = pillLength
            }
            break;
        case 'remain':
            var remain = parseInt(e.target.value);
            if (isNaN(remain)) {
                alert('Invalid value!');
                board.remain = emptyBoard.remain;
            } else {
                board.remain = remain
            }
            break;
        case 'color0':
        case 'color1':
        case 'color2':
            var cnum = parseInt(caller[5])
            var cval = parseInt(e.target.value,16);
            if (isNaN(cval)) {
                alert('Invalid value!\nHEX only!');
                board.colors[cnum] = emptyBoard.colors[cnum];
            } else {
                board.colors[cnum] = cval
            }
            break;
    }
    renderCode();

}


function initEditor () {
    $('#reset').bind('mousedown', function () {
        resetBoard(false);
    });
    $('#parse').bind('mousedown', parseCode);
    $('#test').bind('mousedown', makeXex);
    $('#outbox').bind('blur', leaveSource);
    $('.toolinput').on('change', inputChange);
    $('#outbox').bind('input propertychange', sourceEntry);


    createToolbox();
    selectTool(0);
    createBoard();
    resetBoard(true);
}

function deleteItem (x, y) {
    let cell = getCell(x, y);
    let arr = [];
    if (cell) {
        saveUndoState();
        switch (cell.tile) {
        case tools.DOTS:
            arr = board.dots;
            break;
        case tools.EMPTY:
            arr = board.empty;
            break;
        case tools.VOID:
            arr = board.void;
            break;
        case tools.SPAWNER:
            arr = board.spawners;
            break;
        case tools.WARP:
            arr = board.warps;
            break;
        case tools.PILL:
            arr = board.pills;
            break;
        }
        arr.splice(cell.idx, 1);
        refreshBoard();
    }
}

function cellClick (x, y, e) {
    e = e || window.event;
    if ('which' in e && e.which == 3) { // right click - break drawing rectangle
        if (paintRect) {
            paintRect = false;
            $('.tile').removeClass('rectangle');
        }
    } else { // left click
        if (currentTool == tools.DELETE) {
            deleteItem(x, y)
        } else if (paintRect == true && x > 0 && x < 20) {
            endRectangle(x, y);
        } else if ((currentTool == tools.EMPTY || currentTool == tools.DOTS || currentTool == tools.VOID) && (x > 0 && x < 20)) {
            startRectangle(x, y);
        } else if (((x > 0 && x < 20) &&
            ((currentTool == tools.PILL) || (currentTool == tools.SPAWNER) || (currentTool == tools.START) || (currentTool == tools.EXIT))) ||
            ((x == 0 || x == 20) && (currentTool == tools.WARP))) {
            placeObject(x, y);
        } else if ((x > 0 && x < 20) && currentTool == tools.WARP) alert('Place warps on edges of board');
    }
}

function sortRectangle (rectangle) {
    let r = {};
    if (rectangle.x1 <= rectangle.x2) {
        r.x1 = rectangle.x1;
        r.x2 = rectangle.x2;
    } else {
        r.x2 = rectangle.x1;
        r.x1 = rectangle.x2;
    }
    if (rectangle.y1 <= rectangle.y2) {
        r.y1 = rectangle.y1;
        r.y2 = rectangle.y2;
    } else {
        r.y2 = rectangle.y1;
        r.y1 = rectangle.y2;
    }
    r.w = 1 + r.x2 - r.x1;
    r.h = 1 + r.y2 - r.y1;
    return r;
}

function setCell (x, y, t) {
    cells[Number(x) + Number(y) * 21] = t;
}

function getCell (x, y) {
    return cells[Number(x) + Number(y) * 21];
}

function setCellsOnRectangle (urect, cell) {
    let r = sortRectangle(urect);
    for (x = r.x1; x <= r.x2; x++) {
        setCell(x, r.y1, cell);
        setCell(x, r.y2, cell);
    }
    for (y = r.y1; y <= r.y2; y++) {
        setCell(r.x1, y, cell);
        setCell(r.x2, y, cell);
    }
}

function putClassOnRectangle (urect, tileClass) {
    let r = sortRectangle(urect);
    let cells = [];
    for (let x = r.x1; x <= r.x2; x++) {
        cells = $('#cell_' + x + '_' + r.y1 + ', #cell_' + x + '_' + r.y2);
        if (tileClass != 'rectangle') cells.removeClass('tile_dot tile_empty tile_void');
        cells.addClass(tileClass);
    }
    for (let y = r.y1; y <= r.y2; y++) {
        cells = $('#cell_' + r.x1 + '_' + y + ', #cell_' + r.x2 + '_' + y);
        if (tileClass != 'rectangle') cells.removeClass('tile_dot tile_empty tile_void');
        cells.addClass(tileClass);
    }
}

function paintRectangle () {
    $('.tile').removeClass('rectangle');
    putClassOnRectangle(rect, 'rectangle');
}

function placeRectangle (rect) {
    saveUndoState();
    let r = sortRectangle(rect);
    switch (currentTool) {
    case tools.DOTS:
        tileClass = 'tile_dot';
        board.dots.push(r);
        break;
    case tools.EMPTY:
        tileClass = 'tile_empty';
        board.empty.push(r);
        break;
    case tools.VOID:
        tileClass = 'tile_void';
        board.void.push(r);
        break;
    default:
    }
    refreshBoard();
}

function startRectangle (x, y) {
    rect.x1 = x;
    rect.y1 = y;
    paintRect = true;
    paintRectangle();
}

function endRectangle (x, y) {
    rect.x2 = x;
    rect.y2 = y;
    paintRect = false;
    $('.tile').removeClass('rectangle');
    placeRectangle(rect);
}

function cellOccupied (x, y) {
    const tile = $('#cell_' + x + '_' + y);
    return (tile.hasClass('tile_pill') ||
        tile.hasClass('tile_spawner') ||
        tile.hasClass('tile_exit') ||
        tile.hasClass('tile_start') ||
        tile.hasClass('tile_warp')
    )
}

function placeObject (x, y) {
    if (cellOccupied(x, y)) return false;
    saveUndoState();
    switch (currentTool) {
    case tools.PILL:
        board.pills.push({x, y});
        break;
    case tools.SPAWNER:
        if (board.spawners.length < MAX_SPAWNERS) {
            board.spawners.push({x, y});
        } else {
            alert('maximum number of spawners ('+MAX_SPAWNERS+') reached')
        }
        break;
    case tools.START:
        board.start = {x, y};
        break;
    case tools.WARP:
        board.warps.push(y);
        break;
    case tools.EXIT:
        board.exit = {x, y};
        break;
    }
    refreshBoard();
}

function paintBoard () {
    cells = [];
    paintDots();
    paintEmpty();
    paintVoid();
    paintPills();
    paintSpawners();
    paintWarps();
    paintStartExit();
}

function paintDots () {
    $('.tile').removeClass('tile_dot');
    for (let [idx, tile] of board.dots.entries()) {
        putClassOnRectangle(tile, 'tile_dot');
        setCellsOnRectangle(tile, {
            tile: tools.DOTS,
            idx
        });
    }
}

function paintEmpty () {
    $('.tile').removeClass('tile_empty');
    for (let [idx, tile] of board.empty.entries()) {
        putClassOnRectangle(tile, 'tile_empty');
        setCellsOnRectangle(tile, {
            tile: tools.EMPTY,
            idx
        });
    }
}

function paintVoid () {
    $('.tile').removeClass('tile_void');
    for (let [idx, tile] of board.void.entries()) {
        putClassOnRectangle(tile, 'tile_void');
        setCellsOnRectangle(tile, {
            tile: tools.VOID,
            idx
        });
    }
}

function paintPills () {
    $('.tile').removeClass('tile_pill');
    for (let [idx, tile] of board.pills.entries()) {
        $('#cell_' + tile.x + '_' + tile.y).addClass('tile_pill');
        setCell(tile.x, tile.y, {
            tile: tools.PILL,
            idx
        });
    }
}

function paintSpawners () {
    $('.tile').removeClass('tile_spawner');
    for (let [idx, tile] of board.spawners.entries()) {
        $('#cell_' + tile.x + '_' + tile.y).addClass('tile_spawner');
        setCell(tile.x, tile.y, {
            tile: tools.SPAWNER,
            idx
        });
    }
}

function paintWarps () {
    $('.tile').removeClass('tile_warp tile_warpL tile_warpR');
    for (let [idx, tile] of board.warps.entries()) {
        $('#cell_0_' + tile).addClass('tile_warp tile_warpL');
        $('#cell_20_' + tile).addClass('tile_warp tile_warpR');
        setCell(0, tile, {
            tile: tools.WARP,
            idx
        });
        setCell(20, tile, {
            tile: tools.WARP,
            idx
        });
    }
}

function paintStartExit () {
    $('.tile').removeClass('tile_start').removeClass('tile_exit')
    $('#cell_' + board.start.x + '_' + board.start.y).addClass('tile_start');
    $('#cell_' + board.exit.x + '_' + board.exit.y).addClass('tile_exit');
}

function renderCode () {
    outputsize = 0;
    let outtxt = '';
    let dtaident = '    ';
    outtxt += '.local level_x\n';
    outtxt += dtaident + 'dta ' + board.start.x + ',' + board.start.y + ' ; starting pos - x,y\n';
    outtxt += dtaident + 'dta ' + board.exit.x + ',' + board.exit.y + ' ; exit pos - x,y\n';
    outtxt += dtaident + 'dta ' + board.ai[0] + ',' + board.ai[1] + ',' + board.ai[2] + ',' + board.ai[3] + ' ; ghost AI levels (1 dumb - 9 ninja)\n';
    $("#ai0").val(board.ai[0]);
    $("#ai1").val(board.ai[1]);
    $("#ai2").val(board.ai[2]);
    $("#ai3").val(board.ai[3]);
    outtxt += dtaident + 'dta ' + board.spawnerDelay + '    ; ghost spawner delay in seconds\n';
    $("#delaytime").val(board.spawnerDelay);
    outtxt += dtaident + 'dta ' + board.pillLength + '   ; pill mode length in seconds\n';
    $("#pilltime").val(board.pillLength);
    outtxt += dtaident + 'dta a('+ board.remain +') ; how much dots can remain to open exit\n';
    $("#remain").val(board.remain);
    outtxt += dtaident + 'dta $' + board.colors[0].toString(16) + ',$' + board.colors[1].toString(16) +
                ',$00,COLOR_PACMAD,$' + board.colors[2].toString(16) + ' ; colors\n\n';
    palette.colorSet(0,board.colors[0]);
    $("#color0").val(board.colors[0].toString(16));
    palette.colorSet(1,board.colors[1]);
    $("#color1").val(board.colors[1].toString(16));
    palette.colorSet(2,board.colors[2]);
    $("#color2").val(board.colors[2].toString(16));

    outputsize += 13;

    if (board.dots.length) {
        outtxt += '; dots\n'
        outtxt += dtaident + 'dta TILE_DOT,[dots_end-(* + 1)]/4\n'
        outputsize += 2;
        for (dot of board.dots) {
            outtxt += dtaident + 'dta ' + dot.x1 + ',' + dot.y1 + ',' + dot.w + ',' + dot.h + ' \n';
            outputsize += 4;
        }
        outtxt += 'dots_end\n\n'
    }

    if (board.empty.length) {
        outtxt += '; empty\n'
        outtxt += dtaident + 'dta TILE_EMPTY,[empty_end-(* + 1)]/4\n'
        outputsize += 2;
        for (dot of board.empty) {
            outtxt += dtaident + 'dta ' + dot.x1 + ',' + dot.y1 + ',' + dot.w + ',' + dot.h + ' \n';
            outputsize += 4;
        }
        outtxt += 'empty_end\n\n'
    }

    if (board.void.length) {
        outtxt += '; void\n'
        outtxt += dtaident + 'dta TILE_VOID,[void_end-(* + 1)]/4\n'
        outputsize += 2;
        for (dot of board.void) {
            outtxt += dtaident + 'dta ' + dot.x1 + ',' + dot.y1 + ',' + dot.w + ',' + dot.h + ' \n';
            outputsize += 4;
        }
        outtxt += 'void_end\n\n'
    }

    if (board.pills.length) {
        outtxt += '; pills\n';
        outtxt += dtaident + 'dta TILE_PILL,[pills_end-(*+1)]/2\n';
        outputsize += 2;
        for (pill of board.pills) {
            outtxt += dtaident + 'dta ' + pill.x + ',' + pill.y + ' \n';
            outputsize += 2;
        }
        outtxt += 'pills_end\n\n'
    }

    if (board.spawners.length) {
        outtxt += '; spawners\n';
        outtxt += dtaident + 'dta TILE_SPAWNER,[spawners_end-(*+1)]/2\n';
        outputsize += 2;
        for (spawner of board.spawners) {
            outtxt += dtaident + 'dta ' + spawner.x + ',' + spawner.y + ' \n';
            outputsize += 2;
        }
        outtxt += 'spawners_end\n\n';
    }

    if (board.warps.length) {
        outtxt += '; warps\n';
        outtxt += dtaident + 'dta TILE_WARP_LEFT,warps_end-(* + 1)\n';
        outputsize += 2;
        for (warp of board.warps) {
            outtxt += dtaident + 'dta ' + warp + ' \n';
            outputsize += 1;
        }
        outtxt += 'warps_end\n\n';
    }

    outputsize += 1;
    outtxt += dtaident + 'dta $ff\n.endl ; level size: ' + outputsize + ' bytes\n';
    $('#outbox').val(outtxt);
    source = outtxt;
    sourceChanged = false;
}

function cellOver (x, y) {
    rect.x2 = x;
    rect.y2 = y;
    if (paintRect) {
        paintRectangle();
    }
}

function getRawLevelData() {
    var rawData = [];
    rawData.push(board.start.x,board.start.y,board.exit.x,board.exit.y);
    rawData.push(board.ai[0],board.ai[1],board.ai[2],board.ai[3],board.spawnerDelay,board.pillLength);
    rawData.push(board.remain%0x100,Math.floor(board.remain/0x100));
    rawData.push(board.colors[0],board.colors[1],0,COLOR_PACMAD,board.colors[2]);

    if (board.dots.length) {
        rawData.push(TILE_DOT,board.dots.length);
        for (dot of board.dots) rawData.push(dot.x1,dot.y1,dot.w,dot.h);
    }
    if (board.empty.length) {
        rawData.push(TILE_EMPTY,board.empty.length);
        for (dot of board.empty) rawData.push(dot.x1,dot.y1,dot.w,dot.h);
    }
    if (board.void.length) {
        rawData.push(TILE_VOID,board.void.length);
        for (dot of board.void) rawData.push(dot.x1,dot.y1,dot.w,dot.h);
    }
    if (board.pills.length) {
        rawData.push(TILE_PILL,board.pills.length);
        for (pill of board.pills) rawData.push(pill.x,pill.y);
    }
    if (board.spawners.length) {
        rawData.push(TILE_SPAWNER,board.spawners.length);
        for (spawner of board.spawners) rawData.push(spawner.x,spawner.y);
    }
    if (board.warps.length) {
        rawData.push(TILE_WARP_LEFT,board.warps.length);
        for (warp of board.warps) rawData.push(warp);
    }
    rawData.push(0xff);

    return rawData;

}

function createBoard () {
    for (r = 0; r <= BOARD_HEIGHT; r++) {
        let row = $('<div></div>').attr('id', 'row_' + r).addClass('row');
        for (c = 0; c <= 20; c++) {
            let x = c;
            let y = r;
            let cell = $('<div></div>').attr('id', 'cell_' + c + '_' + r).addClass('tile');
            if (c == 0 || c == 20) cell.addClass('tile_edge').html(r);
            cell.bind('contextmenu', function (e) {
                e.preventDefault();
            });
            cell.bind('mousedown', function (e) {
                cellClick(x, y, e);
            });
            cell.bind('mouseover', function () {
                cellOver(x, y);
            });
            row.append(cell);
        }
        $('#board').append(row);
    }
}

function isMakeable() {
    if (board.dots.length == 0 && board.empty.length == 0) {
        alert('Place some roads for Pac, before playing ;)');
        return false;
    };
    if (board.spawners.length == 0) {
        alert('Place at least one spawner for ghosts.\nNo ghosts - no fun ;)');
        return false;
    };


    return true;
}

function makeXex() {
    if (isMakeable()) {
        var oReq = new XMLHttpRequest();
        oReq.open("GET", "/PacMadEditor/pacmad.xex", true);
        oReq.overrideMimeType('application\/octet-stream');
        oReq.responseType = "arraybuffer";

        oReq.onload = function (oEvent) {
          var arrayBuffer = oReq.response; // Note: not oReq.responseText
          if (arrayBuffer) {
            var byteArray = new Uint8Array(arrayBuffer);
              var newXex = ParseXex(byteArray);
              var blob = new Blob([newXex], {type: "application/xex"});
              var link = $('#link')[0];
              link.href = window.URL.createObjectURL(blob);
              link.download = "pacmad_test.xex";
              link.click();
          }
        };

        oReq.onerror = function (e) {
            alert('error:\n'+e);
        }
        oReq.send(null);
    }
}

const LEVEL_ORIGIN = 0x9000,
      LEVEL_SIZE = 0x42;

function ParseXex(byteArray) {
    var marker = new Uint8Array([LEVEL_ORIGIN % 0x100,Math.floor(LEVEL_ORIGIN / 0x100),LEVEL_SIZE-1,Math.floor(LEVEL_ORIGIN / 0x100)]);
    var levelStart = byteArray.findIndex(function(el,idx,arr){
      if (idx>arr.length-4) return false;
      if (el!=marker[0]) return false;
      if (arr[idx+1]!=marker[1]) return false;
      if (arr[idx+2]!=marker[2]) return false;
      if (arr[idx+3]!=marker[3]) return false;
      return true;
    });
    console.log(levelStart);
    var filebegin = byteArray.slice(0,levelStart);
    var fileend = byteArray.slice(levelStart + LEVEL_SIZE + 4);
    var levelsHeader = byteArray.slice(levelStart, levelStart + 8);
    var level = new Uint8Array(getRawLevelData());
    var levelEnd = LEVEL_ORIGIN + 3 + level.length;
    levelsHeader[2] = levelEnd % 0x100;
    levelsHeader[3] = Math.floor(levelEnd / 0x100);
    return new Blob([filebegin,levelsHeader,level,fileend]);
}


Number.prototype.clamp = function (min, max) {
    return Math.min(Math.max(this, min), max);
};

var palette = {
    getRGB: function (cval) {

        var cr = (cval >> 4) & 15;
        var lm = cval & 15;
        var crlv = cr ? 50 : 0;

        var phase;
        phase = ((cr - 1) * 25.7 - 15) * (2 * 3.14159 / 360); // NTSC ((cr-1)*25 - 58) * (2 * 3.14159 / 360);

        var y = 255 * (lm + 1) / 16;
        var i = crlv * Math.cos(phase);
        var q = crlv * Math.sin(phase);

        var r = y + 0.956 * i + 0.621 * q;
        var g = y - 0.272 * i - 0.647 * q;
        var b = y - 1.107 * i + 1.704 * q;

        var rr = (Math.round(r)).clamp(0, 255);
        var gg = (Math.round(g)).clamp(0, 255);
        var bb = (Math.round(b)).clamp(0, 255);

        return "rgb(" + rr + "," + gg + "," + bb + ")";
    },
    colorSet: function (cnum, cval) {
        var rgb = this.getRGB(cval);
        $("#color"+cnum).css('background-color',rgb).css('color',((cval % 16)<8)?'white':'black');
    },
};

$(function () {
    initEditor();
});

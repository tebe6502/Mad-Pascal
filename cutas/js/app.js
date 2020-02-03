
const binFile = {
    opened: false,
    name: '',
    data: []
};

const defaultOptions = {
    version: '0.99',
    storageName: 'cutasStore097',
    fileSizeLimit: 64,
    hexWidth: 20,
    bmpWidth: 40,
    bmpScale: 2,
    consoleFontSize: 16,
    bytesPerLine: 16,
    lastTemplate: 0
}
const dontSave = ['version', 'storageName'];

let options = {};
const undos = [];
const redos = [];

const selection = {
    isSelected: false,
    start: null,
    end: null,
    first: null,
    firstSelected: false,
    firstSelectedRow: false
}

const reversedBytes = [
    0x00, 0x80, 0x40, 0xC0, 0x20, 0xA0, 0x60, 0xE0, 0x10, 0x90, 0x50, 0xD0, 0x30, 0xB0, 0x70, 0xF0,
    0x08, 0x88, 0x48, 0xC8, 0x28, 0xA8, 0x68, 0xE8, 0x18, 0x98, 0x58, 0xD8, 0x38, 0xB8, 0x78, 0xF8,
    0x04, 0x84, 0x44, 0xC4, 0x24, 0xA4, 0x64, 0xE4, 0x14, 0x94, 0x54, 0xD4, 0x34, 0xB4, 0x74, 0xF4,
    0x0C, 0x8C, 0x4C, 0xCC, 0x2C, 0xAC, 0x6C, 0xEC, 0x1C, 0x9C, 0x5C, 0xDC, 0x3C, 0xBC, 0x7C, 0xFC,
    0x02, 0x82, 0x42, 0xC2, 0x22, 0xA2, 0x62, 0xE2, 0x12, 0x92, 0x52, 0xD2, 0x32, 0xB2, 0x72, 0xF2,
    0x0A, 0x8A, 0x4A, 0xCA, 0x2A, 0xAA, 0x6A, 0xEA, 0x1A, 0x9A, 0x5A, 0xDA, 0x3A, 0xBA, 0x7A, 0xFA,
    0x06, 0x86, 0x46, 0xC6, 0x26, 0xA6, 0x66, 0xE6, 0x16, 0x96, 0x56, 0xD6, 0x36, 0xB6, 0x76, 0xF6,
    0x0E, 0x8E, 0x4E, 0xCE, 0x2E, 0xAE, 0x6E, 0xEE, 0x1E, 0x9E, 0x5E, 0xDE, 0x3E, 0xBE, 0x7E, 0xFE,
    0x01, 0x81, 0x41, 0xC1, 0x21, 0xA1, 0x61, 0xE1, 0x11, 0x91, 0x51, 0xD1, 0x31, 0xB1, 0x71, 0xF1,
    0x09, 0x89, 0x49, 0xC9, 0x29, 0xA9, 0x69, 0xE9, 0x19, 0x99, 0x59, 0xD9, 0x39, 0xB9, 0x79, 0xF9,
    0x05, 0x85, 0x45, 0xC5, 0x25, 0xA5, 0x65, 0xE5, 0x15, 0x95, 0x55, 0xD5, 0x35, 0xB5, 0x75, 0xF5,
    0x0D, 0x8D, 0x4D, 0xCD, 0x2D, 0xAD, 0x6D, 0xED, 0x1D, 0x9D, 0x5D, 0xDD, 0x3D, 0xBD, 0x7D, 0xFD,
    0x03, 0x83, 0x43, 0xC3, 0x23, 0xA3, 0x63, 0xE3, 0x13, 0x93, 0x53, 0xD3, 0x33, 0xB3, 0x73, 0xF3,
    0x0B, 0x8B, 0x4B, 0xCB, 0x2B, 0xAB, 0x6B, 0xEB, 0x1B, 0x9B, 0x5B, 0xDB, 0x3B, 0xBB, 0x7B, 0xFB,
    0x07, 0x87, 0x47, 0xC7, 0x27, 0xA7, 0x67, 0xE7, 0x17, 0x97, 0x57, 0xD7, 0x37, 0xB7, 0x77, 0xF7,
    0x0F, 0x8F, 0x4F, 0xCF, 0x2F, 0xAF, 0x6F, 0xEF, 0x1F, 0x9F, 0x5F, 0xDF, 0x3F, 0xBF, 0x7F, 0xFF,
];

function decimalToHex(d, padding) {
    var hex = Number(d).toString(16);
    padding = typeof (padding) === "undefined" || padding === null ? padding = 2 : padding;

    while (hex.length < padding) {
        hex = "0" + hex;
    }

    return hex;
}

const getSize = () => {
    return `size: ${binFile.data.length} ($${decimalToHex(binFile.data.length)}) bytes`
};


const userIntParse = (udata) => {
    if (_.isNull(udata)) return null;
    udata = _.trim(udata);
    let sign = 1;
    if (_.startsWith(udata, '-')) {
        sign = -1;
        udata = udata.slice(1);
    }
    if (_.startsWith(udata, '$')) {
        udata = parseInt(_.trim(udata, '$'), 16);
    } else {
        udata = parseInt(udata, 10);
    }
    if (!_.isNaN(udata)) {
        if (sign === -1) {
            udata = binFile.data.length - udata;
        }
        return udata;
    } else {
        return NaN;
    }
}

const promptInt = (txt, defaulttxt) => {
    let uint;
    do {
        const uval = prompt(txt, defaulttxt);
        uint = userIntParse(uval);
        if (_.isNaN(uint)) alert(`*** ERROR: can not parse integer value from ${uval}`);
    } while (_.isNaN(uint))
    return uint;
}





// *************************************************  CONSOLE DISPLAY

const setTheme = (theme) => {
    $('#consol').css('font-size', theme.consoleFontSize);
}

const cscroll = () => {
    $('#consol')[0].scrollTop = $('#consol')[0].scrollHeight;
}

const cout = (txt) => {
    const consol = document.getElementById('consol')
    consol.appendChild(document.createTextNode(`${txt}`));
    consol.appendChild(document.createElement("br"));
    cscroll();
}
const cappend = (item) => {
    $('#consol').append(item);
}

const cclear = () => {
    $('#consol').empty();
    removeSelection();
    cout(`*** CutAs v.${options.version} - simple binary data manipulation tool.`);
    cout(`*** author: bocianu@gmail.com`);
}

const removeSelection = () => {
    $("div.new_cell.hex_cell_selected").removeClass('hex_cell_selected');
    selection.isSelected = false;
    selection.firstSelected = false;
    selection.firstSelectedRow = false;
}

const showSelection = () => {
    if (selection.firstSelected) {
        $(`#cell_${selection.first}.new_cell`).addClass('hex_cell_selected');
    };
    if (selection.firstSelectedRow || selection.isSelected) {
        for (let addr = selection.start; addr <= selection.end; addr++) {
            document.getElementById(`cell_${addr}`).classList.add('hex_cell_selected');
            //console.log(cell);
            //$(`#cell_${addr}.new_cell`).addClass('hex_cell_selected');
        }
    }
}

const updateSelection = () => {
    if (selection.isSelected || selection.firstSelectedRow) {
        for (let addr = selection.start; addr <= selection.end; addr++) {
            $(`#cell_${addr}.new_cell`).html(decimalToHex(binFile.data[addr]));
        }
    } else {
        for (let addr = 0; addr < binFile.data.length; addr++) {
            $(`#cell_${addr}.new_cell`).html(decimalToHex(binFile.data[addr]));
        }
    }
}

const cellClicked = (e) => {
    const addr = Number(e.target.attributes.hexoffset.value);
    //alert(addr);
    if (selection.isSelected) removeSelection();
    if (selection.firstSelectedRow) {
        if (addr >= selection.end) {
            selection.end = addr;
        }
        if (addr <= selection.start) {
            selection.start = addr;
        }
        selection.isSelected = true;
    }
    if (selection.firstSelected) {
        if (addr >= selection.first) {
            selection.start = selection.first;
            selection.end = addr;
        } else {
            selection.start = addr;
            selection.end = selection.first;
        }
        selection.isSelected = true;
    } else {
        selection.first = addr;
        selection.firstSelected = true;
        selection.firstSelectedRow = false;
    }
    e.stopPropagation();
    //console.log(selection);
    showSelection();
}

const rowClicked = (e) => {
    //console.log(e);
    let start = Number(e.target.attributes.start.value);
    let end = Number(e.target.attributes.end.value);

    if (selection.isSelected) removeSelection();

    if (selection.firstSelectedRow) {
        if (end < selection.end) {
            end = selection.end;
        }
        if (start > selection.start) {
            start = selection.start;
        }
        selection.isSelected = true;
    }

    selection.end = end;
    selection.start = start;

    if (selection.firstSelected) {
        if (selection.first < start) {
            selection.start = selection.first;
        }
        if (selection.first > end) {
            selection.end = selection.first;
        }
        selection.isSelected = true;
    }

    selection.firstSelectedRow = true;
    selection.firstSelected = false;

    e.stopPropagation();
    //console.log(selection);
    showSelection();
}


const disarmCells = () => {
    removeSelection();
    $("div.new_cell").off().removeClass('new_cell').removeAttr('id');
}

let called = 0;

const showHexCells = () => {
    //var t0 = performance.now();
    if (binFile.data.length == 0) return null;
    cout(`*** File hex view:`);
    const data = binFile.data;
    let row = 0;
    const consol = document.getElementById('consol') 
    disarmCells();
    while (data.length > (row * options.hexWidth)) {
        const start = row * options.hexWidth;
        const head = document.createElement("div"); 
        head.className = 'hex_cell hex_prefix_cell new_cell';
        head.innerHTML = `$${decimalToHex(start, 4)}:`;
        head.setAttribute('start', start);
        head.setAttribute('end', Math.min(start + options.hexWidth - 1, binFile.data.length - 1));
        head.setAttribute('title', `row: ${decimalToHex(start, 4)}`);
        const line = document.createElement("div"); 
        line.className = 'hex_line';
        line.appendChild(head);
        let addr = start;
        _.each(_.slice(data, start, start + options.hexWidth), (v, k) => {
            const cell = document.createElement("div");
            cell.className = 'hex_cell hex_value new_cell';
            //$("<div/>").addClass('hex_cell hex_value new_cell')
            cell.setAttribute('id', `cell_${addr}`);
            cell.setAttribute('hexoffset', addr);
            cell.setAttribute('title', `address: ${decimalToHex(addr, 4)}`);
            cell.innerHTML = `${decimalToHex(v)}`;
            addr++;
            line.appendChild(cell);
        }); 
        consol.appendChild(line);        

        
        row++;
    };
    $("div.hex_value.new_cell").click(cellClicked);
    $("div.hex_prefix_cell.new_cell").click(rowClicked);
    cout('*** End of data.');
    //var t1 = performance.now();
    //cout("Took " + (t1 - t0) + " milliseconds.")
}

const showBMP = () => {
    if (binFile.data.length == 0) return null;
    cout('*** Bitmap wiew:');
    const width = options.bmpWidth * 8 * options.bmpScale;
    const height = Math.ceil(binFile.data.length / options.bmpWidth) * options.bmpScale;
    const bmp = $('<canvas/>', { 'class': 'bmp_view' }).width(width).height(height);
    const ctx = bmp[0].getContext("2d");
    ctx.canvas.width = width;
    ctx.canvas.height = height;
    let x, y, bit;
    let byteOffset = 0;
    ctx.fillStyle = "#0b0";
    for (y = 0; y < height; y++) {
        for (x = 0; x < options.bmpWidth; x++) {
            const bbyte = binFile.data[byteOffset];
            let bx = 0;
            for (bit = 7; bit >= 0; bit--) {
                const mask = 1 << bit;
                if ((bbyte & mask) != 0) {
                    ctx.fillRect(x * 8 * options.bmpScale + bx, y * options.bmpScale, options.bmpScale, options.bmpScale);
                }
                bx += options.bmpScale;
            }
            byteOffset++;
            if (byteOffset > binFile.data.length) break;
        }
    }
    $('#consol').append(bmp, '<br>');
    $('#consol')[0].scrollTop = $('#consol')[0].scrollHeight;
}

const showText = () => {
    if (binFile.data.length == 0) return null;
    cout(`*** File text view:`);
    if (binFile.data.length > 0) {
        var txt = new TextDecoder("iso-8859-2").decode(binFile.data);
        cout(txt.replace(/\n/g, '<br>'));
    }
}

const showInfo = () => {
    cout(`*** File information:`);
    cout(`File name: ${binFile.name}`);
    cout(`File ${getSize()}`);
}




//******************************************* FILE OPERATIONS

const dropFile = function (file) {
    var reader = new FileReader();
    reader.onload = function () {
        var arrayBuffer = reader.result;
        //console.log(input.files[0]);
        if (file.size > (options.fileSizeLimit * 1024)) {
            cout(`*** ERROR: File too big! Size limit exceeded. File size: ${file[0].size} B - limit: ${options.fileSizeLimit} kB`);
            return false;
        }
        binFile.name = file.name;
        binFile.opened = true;
        binFile.data = new Uint8Array(arrayBuffer);
        _.remove(undos, _.stubTrue);
        cout(`*** File ${binFile.name} opened, ${getSize()}`);
    };
    reader.readAsArrayBuffer(file);
    
}


const openFile = function (event) {
    var input = event.target;

    var reader = new FileReader();
    reader.onload = function () {
        var arrayBuffer = reader.result;
        //console.log(input.files[0]);
        if (input.files[0].size > (options.fileSizeLimit * 1024)) {
            cout(`*** ERROR: File too big! Size limit exceeded. File size: ${input.files[0].size} B - limit: ${options.fileSizeLimit} kB`);
            return false;
        }
        binFile.name = input.files[0].name;
        binFile.opened = true;
        binFile.data = new Uint8Array(arrayBuffer);
        _.remove(undos, _.stubTrue);
        cout(`*** File ${binFile.name} opened, ${getSize()}`);
        input.value = '';
    };
    if (input.files.length > 0) {
        reader.readAsArrayBuffer(input.files[0]);
    }
};

const appendFile = function (event) {
    if (binFile.data.length == 0) {
        cout(`*** ERROR: Cannot append to empty file, use Open File instead!`);
        return null;
    }
    var input = event.target;
    var reader = new FileReader();
    reader.onload = function () {
        var arrayBuffer = reader.result;
        const newSize = input.files[0].size + getSize();
        if (newSize > (options.fileSizeLimit * 1024)) {
            cout(`*** ERROR: File becomes too big! Size limit exceeded. File size: ${newSize} B - limit: ${options.fileSizeLimit} kB`);
            return false;
        }
        const undo = { name: `file: ${input.files[0].name} merge`, data: binFile.data.slice() };
        undos.push(undo);
        const appendData = new Uint8Array(arrayBuffer);
        const newData = new Uint8Array(binFile.data.length + appendData.length);
        newData.set(binFile.data);
        newData.set(appendData, binFile.data.length);
        binFile.data = newData;
        cout(`*** File ${binFile.name} merged, new ${getSize()}`);
        input.value = '';
    };
    if (input.files.length > 0) {
        reader.readAsArrayBuffer(input.files[0]);
    }
};

const saveFile = () => {

    if (binFile.opened) {
        const name = prompt('set filename of saved file:', binFile.name);

        if (binFile.data.length > 0) {
            var a = document.createElement('a');
            document.body.appendChild(a);
            var file = new Blob([new Uint8Array(binFile.data)]);
            a.href = URL.createObjectURL(file);
            if (name) {
                a.download = name;
                a.click();
                setTimeout(() => { $(a).remove(); }, 100);
            }
        }
    } else return null
}



// ******************************************* DATA SLICING

const sliceData = (dstart = null, dstop = null) => {

    if (binFile.data.length == 0) return null;
    if (selection.isSelected) {
        dstart = selection.start;
        dstop = selection.end;
    };
    if (!_.isNumber(dstart)) {
        dstart = promptInt('first byte address:', 0);
        if (_.isNull(dstart)) {
            return null;
        }
    }
    if (!_.isNumber(dstop)) {
        dstop = promptInt('last byte address:', binFile.data.length - 1);
        if (_.isNull(dstop)) {
            return null;
        }
    }
    if (!_.isNull(dstart) && !_.isNull(dstop)) {
        if (!_.inRange(dstart, 0, binFile.data.length)) {
            cout('*** ERROR - starting address out of range');
            return null;
        }
        if (!_.inRange(dstop, 0, binFile.data.length)) {
            cout('*** ERROR - ending address out of range');
            return null;
        }
        binFile.data = _.slice(binFile.data, dstart, dstop + 1);
        cout(`*** File sliced from ${dstart} to ${dstop}, new ${getSize()}`);
        disarmCells();
        return 1;
    }
    return null;
}

const cutOffData = (dstart = null, dstop = null) => {
    if (binFile.data.length == 0) return null;
    if (selection.isSelected) {
        dstart = selection.start;
        dstop = selection.end;
    };
    if (!_.isNumber(dstart)) {
        dstart = promptInt('first byte address:', 0);
        if (_.isNull(dstart)) {
            return null;
        }
    }
    if (!_.isNumber(dstop)) {
        dstop = promptInt('last byte address:', binFile.data.length - 1);
        if (_.isNull(dstop)) {
            return null;
        }
    }
    if (!_.isNull(dstart) && !_.isNull(dstop)) {
        if (!_.inRange(dstart, 0, binFile.data.length)) {
            cout('*** ERROR - starting address out of range');
            return null;
        }
        if (!_.inRange(dstop, 0, binFile.data.length)) {
            cout('*** ERROR - ending address out of range');
            return null;
        }
        binFile.data = _.concat(_.slice(binFile.data, 0, dstart), _.slice(binFile.data, dstop + 1));
        cout(`*** File cuted off from ${dstart} to ${dstop}, new ${getSize()}`);
        disarmCells();
        return 1;
    }
    return null;
}

const splitData = (dsize = null) => {
    if (binFile.data.length == 0) return null;
    if (selection.isSelected) {
        dsize = selection.end - selection.start + 1;
    };
    if (!_.isNumber(dsize)) {
        dsize = promptInt('chunk size in bytes:', 0);
        if (_.isNull(dsize)) return null;
    }
    if (!_.isNull(dsize)) {
        if (dsize <= 0) return null;
        const fcount = Math.ceil(binFile.data.length / dsize);
        if (fcount > 9) {
            const sure = confirm(`It will produce ${fcount} files!\nAre you sure you want to proceed??`);
            if (!sure) return null;
        }
        const fname = prompt('set name for saved files:', binFile.name.split('.')[0]);
        if (_.isNull(fname)) return null;
        let fnum = 0;
        while (fnum < fcount) {
            const foffset = fnum * dsize;
            const chunk = _.slice(binFile.data, foffset, foffset + dsize);
            const cname = `${fname}.${_.padStart(fnum, 3, '0')}`;
            saveFile(chunk, cname);
            cout(`* File ${cname} saved, size ${chunk.length}`);
            fnum++;
        }
        cout(`*** File splited into ${fcount} parts`);
        return 1;
    } else {
        cout(`*** Split aborted`);
    }
    return null;
}

// ******************************************* DATA MODIFIERS


const dataNegate = () => {
    if (binFile.data.length == 0) return null;
    if (selection.isSelected || selection.firstSelectedRow) {
        binFile.data = new Uint8Array(_.map(binFile.data, (v, i) => _.inRange(i, selection.start, selection.end + 1) ? ~v : v));
        cout('*** Selected range negated');
    } else {
        binFile.data = new Uint8Array(_.map(binFile.data, (v) => ~v));
        cout('*** All data negated');
    }
    updateSelection();
    return 1;
}

const dataXOR = () => {
    if (binFile.data.length == 0) return null;
    const uval = promptInt('value to XOR the data with:', 0);
    if (_.isNull(uval)) return null;
    if (selection.isSelected || selection.firstSelectedRow) {
        binFile.data = new Uint8Array(_.map(binFile.data, (v, i) => _.inRange(i, selection.start, selection.end + 1) ? uval ^ v : v));
        cout(`*** Selected range XORed with ${uval}`);
    } else {
        binFile.data = new Uint8Array(_.map(binFile.data, (v) => uval ^ v));
        cout(`*** All data XORed with ${uval}`);
    }
    updateSelection();
    return 1;
}

const dataOR = () => {
    if (binFile.data.length == 0) return null;
    const uval = promptInt('value to OR your data with:', 0);
    if (_.isNull(uval)) return null;
    if (selection.isSelected || selection.firstSelectedRow) {
        binFile.data = new Uint8Array(_.map(binFile.data, (v, i) => _.inRange(i, selection.start, selection.end + 1) ? uval | v : v));
        cout(`*** Selected range XORed with ${uval}`);
    } else {
        binFile.data = new Uint8Array(_.map(binFile.data, (v) => uval | v));
        cout(`*** All data ORed with ${uval}`);
    }
    updateSelection();
    return 1;
}

const dataAND = () => {
    if (binFile.data.length == 0) return null;
    const uval = promptInt('value to AND your data with:', 0);
    if (_.isNull(uval)) return null;
    if (selection.isSelected || selection.firstSelectedRow) {
        binFile.data = new Uint8Array(_.map(binFile.data, (v, i) => _.inRange(i, selection.start, selection.end + 1) ? uval & v : v));
        cout(`*** Selected range XORed with ${uval}`);
    } else {
        binFile.data = new Uint8Array(_.map(binFile.data, (v) => uval & v));
        cout(`*** All data ANDed with ${uval}`);
    }
    updateSelection();
    return 1;
}

const dataOffset = () => {
    if (binFile.data.length == 0) return null;
    const uval = promptInt('value to offset your data with:', 0);
    if (_.isNull(uval)) return null;
    if (selection.isSelected || selection.firstSelectedRow) {
        binFile.data = new Uint8Array(_.map(binFile.data, (v, i) => _.inRange(i, selection.start, selection.end + 1) ? uval + v : v));
        cout(`*** Selected range XORed with ${uval}`);
    } else {
        binFile.data = new Uint8Array(_.map(binFile.data, (v) => uval + v));
        cout(`*** All data ofsetted by ${uval}`);
    }
    updateSelection();
    return 1;
}

const dataReverse = () => {
    if (binFile.data.length == 0) return null;
    if (selection.isSelected || selection.firstSelectedRow) {
        binFile.data = new Uint8Array(_.map(binFile.data, (v, i) => _.inRange(i, selection.start, selection.end + 1) ? reversedBytes[v] : v));
        cout(`*** Selected range XORed with ${uval}`);
    } else {
        binFile.data = new Uint8Array(_.map(binFile.data, v => reversedBytes[v]));
        cout(`*** All bytes reverted`);
    }
    updateSelection();
    return 1;
}


const packRLE = () => {
    let oldSize = binFile.data.length;
    if (oldSize == 0) return null;
    let x = 0;
    let old = 0;
    let compressedData = [];
    const saveRle = (a, c) => {
        compressedData.push((c - 1) << 1);
        compressedData.push(a);
    }
    const saveStr = (x) => {
        const tmp = [];
        let i = 0;
        while ((x < oldSize) && (i <= 127)) {
            let a = binFile.data[x];
            tmp.push(a);
            if ((x < oldSize - 2) && (a == binFile.data[x + 1]) && (a == binFile.data[x + 2])) {
                tmp.pop();
                break;
            }
            x += 1;
            i += 1;
        }
        i -= 1;
        a = (i << 1) | 1;
        compressedData.push(a);
        compressedData = compressedData.concat(tmp);
        return x;
    };

    while (x < oldSize) {
        old = x;
        let a = binFile.data[x];
        let c = 1;
        x += 1;
        while ((x < oldSize) && (a == binFile.data[x])) {
            c += 1;
            x += 1;
            if (c == 127) break;
        }
        if (c > 2) saveRle(a, c)
        else x = saveStr(old);
    }
    compressedData.push(0);
    //console.log(compressedData);
    binFile.data = new Uint8Array(compressedData);
    cout(`*** Data compressed, old size: ${oldSize} ($${decimalToHex(oldSize, 4)}), new size: ${binFile.data.length} ($${decimalToHex(binFile.data.length, 4)})`);
    cout(`*** Saved: ${oldSize - binFile.data.length} bytes`);
    return 1;
}




// *********************************** OPTIONS

const refreshOptions = () => {
    $('#hex_width').val(options.hexWidth);
    $('#bmp_width').val(options.bmpWidth);
    $('#bmp_scale').val(options.bmpScale);
    $('#font_size').val(options.consoleFontSize);
    $('#size_limit').val(options.fileSizeLimit);
}

const valIntInput = (inputId) => {
    uint = userIntParse($(`#${inputId}`).val());
    if (_.isNaN(uint)) {
        $(`#${inputId}`).addClass('warn').focus();
        return false;
    };
    $(`#${inputId}`).val(uint);
    return true;
}

const validateOptions = () => {
    $('.dialog_text_input').removeClass('warn');
    if (!valIntInput('hex_width')) return false;
    if (!valIntInput('bmp_width')) return false;
    if (!valIntInput('size_limit')) return false;
    if (!valIntInput('font_size')) return false;

    return true;
}

const toggleOptions = () => {
    if ($('#options_dialog').is(':visible')) {
        $('#options_dialog').slideUp();
    } else {
        refreshOptions();
        $('#options_dialog').slideDown();
    }
}

const storeOptions = () => {
    localStorage.setItem(defaultOptions.storageName, JSON.stringify(_.omit(options, dontSave)));
}

const loadOptions = () => {
    if (!localStorage.getItem(defaultOptions.storageName)) {
        options = _.assignIn({}, defaultOptions);
        storeOptions();
    } else {
        options = _.assignIn({}, defaultOptions, JSON.parse(localStorage.getItem(defaultOptions.storageName)));
    }
}

const updateOptions = () => {
    _.assignIn(options, {
        hexWidth: Number($('#hex_width').val()),
        bmpWidth: Number($('#bmp_width').val()),
        bmpScale: Number($('#bmp_scale').val()),
        consoleFontSize: Number($('#font_size').val()),
        fileSizeLimit: Number($('#size_limit').val()),
        bytesPerLine: Number($('#bytes_per_line').val()),
        lastTemplate: Number($('#export_template').val()),
    });
    storeOptions();
}


const saveOptions = () => {
    if (validateOptions()) {
        updateOptions();
        toggleOptions();
        setTheme(options);
        cout(`*** Options updated`);
    }
}

// *********************************** EXPORT

const refreshExports = () => {
    $('#bytes_per_line').val(options.bytesPerLine);
    $('#export_template').empty();
    for (let templateIdx in exportTemplates) {
        const template = exportTemplates[templateIdx];
        const option = $('<option/>').val(templateIdx).html(template.name);
        $('#export_template').append(option);
    };
    $('#export_template').val(options.lastTemplate);
    //
}

const validateExport = () => valIntInput('bytes_per_line');

const updateAfterEdit = () => {
    if (validateExport()) {
        updateOptions();
    }
}

const toggleExport = () => {
    if ($('#export_dialog').is(':visible')) {
        $('#export_dialog').slideUp();
    } else {
        refreshExports();
        $('#export_dialog').slideDown();
    }
}

const exportData = () => {
    if (binFile.data.length == 0) return null;
    const deselect = () => {
        if (document.selection) document.selection.empty();
        else if (window.getSelection)
            window.getSelection().removeAllRanges();
    }
    updateOptions();
    toggleExport();
    cout(`*** Start of exported data:`);
    const body = parseTemplate($('#export_template').val());
    const block = $(`<pre>${body}</pre>`);
    $('#consol').append(block);
    deselect();
    if (document.selection) {
        var range = document.body.createTextRange();
        range.moveToElementText(block[0]);
        range.select();
    }
    else if (window.getSelection) {
        var range = document.createRange();
        range.selectNode(block[0]);
        window.getSelection().addRange(range);
    }
    document.execCommand('copy');
    deselect();
    cout(`*** End of exported data`);
    cout(`*** Text copied to clipboard, paste it anywhere else`);
}


const parseTemplateVars = (template, size) => {
    return template
        .replace(/#size#/g, size)
        .replace(/#max#/g, size - 1);
}

const parseTemplate = (templateIdx) => {
    const template = exportTemplates[templateIdx];
    let templateLines = '';
    const linesCount = Math.ceil(binFile.data.length / options.bytesPerLine);
    for (let line = 0; line < linesCount; line++) {
        let lineBody = '';
        if (template.line.numbers) {
            lineBody += `${template.line.numbers.start + template.line.numbers.step * line} `;
        }
        const dataOffset = line * options.bytesPerLine;
        const lineData = _.join(_.map(_.slice(binFile.data, dataOffset, dataOffset + options.bytesPerLine),
            b => `${template.byte.prefix}${template.byte.hex ? decimalToHex(b, 2) : b}${template.byte.postfix}`
        ), template.byte.separator);
        const linePostfix = (line == linesCount - 1) ? template.line.lastpostfix || template.line.postfix : template.line.postfix;
        lineBody += `${template.line.prefix}${lineData}${linePostfix}`;
        templateLines += lineBody;
    }
    return parseTemplateVars(`${template.block.prefix}${templateLines}${template.block.postfix}`, binFile.data.length);
}


// *********************************** UNDO

const saveUndo = (name, modifier) => {
    return () => {
        const undo = { name: name, data: binFile.data.slice() };
        const result = modifier();
        if (!_.isNull(result)) {
            _.remove(redos, _.stubTrue);
            undos.push(undo);
        }
    }
}

const undo = () => {
    if (undos.length > 0) {
        const undo = undos.pop();
        const redo = { name: undo.name, data: binFile.data.slice() };
        redos.push(redo);
        binFile.data = undo.data.slice();
        disarmCells();
        cout(`*** Undo - ${undo.name} reverted`);
    } else {
        cout(`*** No Undo`);
    }
}

const redo = () => {
    if (redos.length > 0) {
        const redo = redos.pop();
        const undo = { name: redo.name, data: binFile.data.slice() };
        undos.push(undo);
        binFile.data = redo.data.slice();
        disarmCells();
        cout(`*** Redo - ${undo.name} restored`);
    } else {
        cout(`*** Can't Redo`);
    }
}


// ************************************************  ON START INIT 

$(document).ready(function () {
    loadOptions();
    const app = gui(options, dropFile);
    setTheme(options);
    refreshExports();
    refreshOptions();
    $('title').append(` v.${options.version}`);
    cclear();
    app.addMenuFileOpen('Open File', openFile, 'filemenu', 'Opens new binary file');
    app.addMenuFileOpen('Append', appendFile, 'filemenu', 'Append other binary file to current data');
    app.addMenuItem('Save File', saveFile, 'filemenu', 'Saves current data into new file');
    app.addMenuItem('Export', toggleExport, 'filemenu', 'Exports current data in popular programming languages formats');
    app.addSeparator('filemenu');
    app.addMenuItem('Undo', undo, 'filemenu', 'Undo last operation');
    app.addMenuItem('Redo', redo, 'filemenu', 'Redo last operation');

    app.addSeparator('filemenu');
    app.addMenuItem('pack RLE', saveUndo('RLE compression', packRLE), 'filemenu', 'Packs current data using RLE algorithm');
    app.addSeparator('filemenu');
    app.addMenuItem('Options', toggleOptions, 'filemenu');

    app.addMenuItem('Split', splitData, 'datamenu', 'Splits current data into n data chunks with specified size').addClass('icon icon_split');
    app.addMenuItem('Slice', saveUndo('data slice', sliceData), 'datamenu', 'Keeps only slice of current data from->to specified offset').addClass('icon icon_slice');
    app.addMenuItem('Cut Off', saveUndo('data cut off', cutOffData), 'datamenu', 'Cuts off (removes) specified range of bytes form current data').addClass('icon icon_cutoff');
    app.addSeparator('datamenu');
    app.addMenuItem('Negate', saveUndo('data negation', dataNegate), 'datamenu', 'Negates all bytes of current data');
    app.addMenuItem('XOR', saveUndo('data XOR operation', dataXOR), 'datamenu', 'Performs binary XOR with provided value on all bytes of current data');
    app.addMenuItem('OR', saveUndo('data OR operation', dataOR), 'datamenu', 'Performs binary OR with provided value on all bytes of current data');
    app.addMenuItem('AND', saveUndo('data AND operation', dataAND), 'datamenu', 'Performs binary AND with provided value on all bytes of current data');
    app.addMenuItem('Offset', saveUndo('data offseting', dataOffset), 'datamenu', 'Adds provided offset value to all bytes of current data');
    app.addMenuItem('Reverse', saveUndo('revert bytes', dataReverse), 'datamenu', 'Reverts order of bits in every byte of current data');
    app.addMenuItem('Show Info', showInfo, 'viewmenu', 'Shows brief info about current data set');
    app.addMenuItem('Show Hex', showHexCells, 'viewmenu', 'Shows hexadecimal dump of current data set');
    app.addMenuItem('Show Text', showText, 'viewmenu', 'Shows current data set as an text data');
    app.addMenuItem('Show Bitmap', showBMP, 'viewmenu', 'Shows current data set as bitmap');
    app.addSeparator('viewmenu');
    app.addMenuItem('Clear View', cclear, 'viewmenu', 'Clears terminal window');
    app.fitSize();
    /*
        binFile.data = new Uint8Array([
            0x00, 0x1f, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xf8, 0x00, 0x00, 0x1f, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xf8, 0x00,
            0x3f, 0x9f, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xf3, 0xf9, 0xfc, 0x3f, 0x9f, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf3, 0xf9, 0xfc,
            0x3f, 0x9f, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xf3, 0xf9, 0xfc, 0x38, 0x01, 0xce, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x73, 0x80, 0x1c,
            0x3b, 0x9d, 0xce, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0x73, 0xb9, 0xdc, 0x3b, 0x9d, 0xce, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x73, 0xb9, 0xdc,
            0x3b, 0x9d, 0xce, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0x73, 0xb9, 0xdc, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0x80, 0x00, 0x00, 0x00, 0x00, 0xfb, 0x9d, 0xce, 0xff, 0xe3, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc7, 0xff, 0x73, 0xb9, 0xdf,
            0xfb, 0x9d, 0xce, 0xff, 0xc7, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xe3, 0xff, 0x73, 0xb9, 0xdf, 0xfb, 0x9d, 0xce, 0xff, 0x8f, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf1, 0xff, 0x73, 0xb9, 0xdf,
            0xf8, 0x00, 0x00, 0xff, 0x1f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xf8, 0xff, 0x00, 0x00, 0x1f, 0xff, 0x9d, 0xcf, 0xfe, 0x3f, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfc, 0x7f, 0xf3, 0xb9, 0xff,
            0xff, 0x9d, 0xcf, 0xfc, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xfe, 0x3f, 0xf3, 0xb9, 0xff, 0xff, 0x9d, 0xcf, 0xf8, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x1f, 0xf3, 0xb9, 0xff,
            0x00, 0x00, 0x00, 0x01, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc0, 0x00, 0x00, 0x00,
            0x3f, 0x9d, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xf3, 0xb9, 0xfc, 0x3f, 0x9d, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf3, 0xb9, 0xfc,
            0x3f, 0x9d, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xf3, 0xb9, 0xfc, 0x38, 0x01, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf3, 0x80, 0x1c,
            0x3b, 0x9f, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xf3, 0xf9, 0xdc, 0x3b, 0x9f, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf3, 0xf9, 0xdc,
            0x3b, 0x9f, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xf3, 0xf9, 0xdc, 0x3b, 0x9f, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf3, 0xf9, 0xdc,
            0x3b, 0x9f, 0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xf3, 0xf9, 0xdc, 0x3b, 0x9f, 0x8f, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf1, 0xf9, 0xdc,
            0x3b, 0x9f, 0x1f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xf8, 0xf9, 0xdc, 0x3b, 0x9e, 0x3f, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfc, 0x79, 0xdc,
            0x3b, 0x9c, 0x7f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xfe, 0x39, 0xdc, 0x3b, 0x98, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x19, 0xdc,
            0x3b, 0x91, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x89, 0xdc, 0x3b, 0x83, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xc1, 0xdc,
            0x3b, 0x87, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xe1, 0xdc, 0x3b, 0x8f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf1, 0xdc,
            0x3b, 0x9f, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xf9, 0xdc, 0x3b, 0xbf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
            0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xfd, 0xdc
        ]);
    */
});

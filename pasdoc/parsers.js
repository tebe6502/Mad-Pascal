const _ = require('lodash');

const setBodyValue = (body, key, val) => {
    key = _.trim(key, '@');
    val = _.trim(val.replace(/<([^>]*)>/g, (r, r1) =>
        `<a href='${_.includes(r1, '@') ? 'mailto:' + r1 : r1}'>${r1}</a>`));
    val = val.replace(/\n/g, "<br>");
    if (_.has(body, key)) {
        if (_.isArray(body[key])) {
            body[key].push(val);
        } else {
            body[key] = [body[key], val];
        }
    } else {
        body[key] = val;
    }
};

const parseBodyLines = lines => {
    const body = {};
    let startLine = 0;
    let key = '';
    let val = '';
    _.forEach(lines, (line, idx) => {
        if (_.startsWith(line, '@')) {
            if (startLine > 0) {
                setBodyValue(body, key, val + _.join(_.slice(lines, startLine, idx), ' '));
                startLine = 0;
            }
            const a = _.split(_.trim(line, ':'), ':');
            key = a[0];
            val = '';
            if (a.length > 2) {
                val = _.join(_.tail(a), ':');
            }
            if (a.length == 2) {
                val = a[1];
            }
            startLine = idx + 1;
        }
        if (_.trim(line) === '') {
            lines[idx] = "\n";
        }
    });
    if (startLine > 0) {
        setBodyValue(body, key, val + _.join(_.slice(lines, startLine), ' '));
    }
    return body;
};

const getCommentBlocks = lines => {
    const blocks = [];
    let startLine = 0;
    _.forEach(lines, (line, idx) => {
        if (_.startsWith(_.trim(line), '(*')) {
            startLine = idx;
        }
        if (_.startsWith(_.trim(line), '*)') && startLine > 0) {
            const bodyLines = _.map(_.slice(lines, startLine + 1, idx), l=>_.trim(l, "\n\r\t *"));
            blocks.push({
                head: _.trim(_.replace(lines[startLine - 1],/  /g,' '), " \r\n\t;"),
                firstLine: startLine,
                lastLine: idx,
                body: parseBodyLines(bodyLines)
            });
        }
    });
    return blocks;
};

const getVariables = lines => {
    const blocks = [];
    let startLine = 0;
    _.forEach(lines, (line, idx) => {
        if (_.includes(_.trim(line), '(* @var')) {
            startLine = idx;
        }
        if (_.includes(_.trim(line), "*)") && startLine > 0) {
            const bodyLines = _.join(_.map(_.slice(lines, startLine, idx + 1), l=>_.trim(l, "\n\r \t")), '\n');
            const elems = _.split(bodyLines, "(* @var");
            const elems2 = _.split(elems[0], ':');
            if (_.startsWith(_.trim(elems2[0]), 'var')) {
                elems2[0] = _.trim(elems2[0]).substr(4);
            }
            const elems3 = _.split(elems[1], '*)');
            startLine = 0;
            blocks.push({
                name: _.trim(elems2[0]),
                type: _.trim(elems2[1], " ;\t"),
                desc: _.trim(elems3[0])
            });
        }
    });
    return blocks;
};

const getConsts = lines => {
    const consts = [];
    const addConst = l => {
        if (l.indexOf('@nodoc') === -1) {
            const elems = _.split(_.trim(l), "=");
            const vals = _.split(elems[1], /\/\/|\{/);
            if (_.trim(elems[0])) {
                consts.push({
                    name: _.trim(elems[0]),
                    value: _.trim(vals[0], "; \t"),
                    desc: vals[1] ? _.trim(vals[1]," \t\n\r}") : ''
                });
            }
        }
    };
    let inBlock = false;
    _.forEach(lines, (line, idx) => {
        if (_.trim(line) !== '') {
            if (_.startsWith(_.trim(line), 'const')) {
                addConst(line.substr(5));
                inBlock = true;
            } else {
                if (_.some(['var','begin','type','interface','implementation','procedure','function','asm'], w => _.startsWith(_.trim(line), w))) {
                    inBlock = false;
                }
                const strippedLine = _.trim(line).replace( /^\/\/*/, '' ).replace(/\{*\}/, '');
                if (inBlock && line.indexOf('=') != -1) {
                    addConst(line);
                }
            }
        }
    });
    return consts;
};

const connectInterface = (interface, aname) => {
    for (let i in interface) {
        if (interface[i].name.toUpperCase() === aname) {
            interface[i].anchor = aname;
            return aname;
        }
    }
    return false;
};

const getTypes = (commentBlocks, lines, interface) => {
    const types = _.filter(commentBlocks, b => _.startsWith(b.head.toLowerCase(), 'type'));
    _.forEach(types, t => {
        const head = _.trim(t.head).substr(4);
        const elems = _.split(head, '=');
        t.name = _.trim(elems[0]);
        t.type = _.trim(_.join(_.tail(elems),'='));
        if (_.startsWith(t.type,'(')) {
            t.type = t.type
                .replace(/, | ,/g, ',')
                .replace(/,/g, ',<br>&nbsp;&nbsp;')
                .replace('(', '(<br>&nbsp;&nbsp;')
                .replace(')', '<br>)');
        }
        t.desc = t.body.description;
        t.record = [];
        if (t.type.toLowerCase() === 'record') {
            let idx = t.lastLine + 1;
            while (!_.startsWith(_.trim(lines[idx]).toLowerCase(), 'end;')) {
                if (lines[idx].indexOf(':') !== -1) {
                    const elem2 = _.split(lines[idx], ':');
                    const elem3 = _.split(elem2[1], /\/\/|\{/);
                    t.record.push({
                        name: _.trim(elem2[0]+':'),
                        type: _.trim(elem3[0]),
                        desc: _.trim(elem3[1]," \t\n\r}"),
                    });
                }
                idx++;
            }
        }
        if (t.type.toLowerCase() === 'object') {
            let idx = t.lastLine + 1;
            while (!_.startsWith(_.trim(lines[idx]).toLowerCase(), 'end;')) {
                if (_.startsWith(_.trim(lines[idx]).toLowerCase(), 'procedure') || _.startsWith(_.trim(lines[idx]).toLowerCase(), 'function')) {
                    const namecom = _.join(_.tail(_.split(lines[idx], ' ')),' ');
                    const names = _.split(namecom, /\/\/|\{/);
                    const aname = `${t.name.toUpperCase()}.${_.trim(names[0].split( / |\(|:|;/ )[0]).toUpperCase()}`;
                    const anchor = connectInterface(interface, aname);
                    const sname = _.replace(names[0], / |\t/g, '');
                    t.record.push({
                        anchor: anchor,
                        name: _.split(lines[idx], ' ')[0],
                        type: names[0],
                        desc: _.trim(names[1]," \t\n\r}")
                    });
                } else {
                    if (lines[idx].indexOf(':') !== -1) {
                        const elem2 = _.split(lines[idx], ':');
                        const elem3 = _.split(elem2[1], /\/\/|\{/);
                        t.record.push({
                            name: _.trim(elem2[0]+':'),
                            type: _.trim(elem3[0]),
                            desc: _.trim(elem3[1]," \t\n\r}")
                        });
                    }
                }
                idx++;
            }
        }
    });
    return types;
};

const getAbsolutes = lines => {
    const absolutes = [];
    let inBlock = false;
    _.forEach(lines, (line, idx) => {
        if (_.trim(line) !== '' && line.indexOf('@nodoc') === -1) {
            if (_.startsWith(_.trim(line), 'var')) {
                inBlock = true;
            } else {
                if (_.some(['const','begin','type','interface','implementation','procedure','function','asm'], w => _.startsWith(_.trim(line), w))) {
                    inBlock = false;
                }
            }
            if (inBlock && (line.toLowerCase().indexOf(' absolute ') !== -1)) {
                let aline = _.trim(line);
                if (_.startsWith(aline.toLowerCase(), 'var')) {
                    aline = aline.substr(4);
                }
                const elems = _.split(_.trim(aline), ":");
                elems[1] = _.join(_.tail(elems), ':');
                const elems2 = _.split(elems[1], ' absolute ');
                const elems3 = _.split(elems2[1], /\/\/|\{/);
                absolutes.push({
                    name: _.trim(elems[0]),
                    type: _.trim(elems2[0]),
                    addr: _.trim(elems3[0], "; \t"),
                    desc: elems3[1] ? _.trim(elems3[1], " \t\n\r};") : ''
                });
            }
        }
    });
    return absolutes;
};

const getInterface = (commentBlocks, lines) => _.filter(commentBlocks, b => {
    if (_.startsWith(_.trim(b.head.toLowerCase()), 'procedure') || _.startsWith(_.trim(b.head.toLowerCase()), 'function')) {
        b.name = _.trim(b.head.split(' ')[1].split('(')[0].split(':')[0],'; ');
        return true;
    } else return false;
});

const parsePas = (contents) => {
    const dataDefaults = {main: {head: 'Undocumented Library', body: {}}};
    const lines = _.split(contents, "\n");
    const commentBlocks = getCommentBlocks(lines);
    const consts = getConsts(lines);
    const regs = getAbsolutes(lines);
    const vars = getVariables(lines);
    const interface = getInterface(commentBlocks, lines);
    const types = getTypes(commentBlocks, lines, interface);
    return _.defaults({}, {
        main: _.first(_.filter(commentBlocks, b => _.startsWith(b.head.toLowerCase(), 'unit'))),
        types,
        interface,
        consts,
        regs,
        vars,
    }, dataDefaults);
};

module.exports = {
    parsePas
};


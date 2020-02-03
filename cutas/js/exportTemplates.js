//  #size#
//  #max#

const exportTemplates = [
    {
        name:'Mad-Pascal array',
        block: {
            prefix: "var data: array [0..#max#] of byte = (\n", postfix: ");"
        },
        line: {
            numbers: false, prefix: '    ', postfix: ",\n", lastpostfix: "\n"
        },
        byte: {
            hex: true, separator: ', ',
            prefix: '$', postfix: ''
        }
    },

    {
        name:'Action! array',
        block: {
            prefix: "BYTE ARRAY DATA=[\n", postfix: "]"
        },
        line: {
            numbers: false, prefix: '  ', postfix: "\n"
        },
        byte: {
            hex: true, separator: ' ',
            prefix: '$', postfix: ''
        }
    },

    {
        name:'C array',
        block: {
            prefix: "unsigned char data[#size#] = {\n", postfix: "};"
        },
        line: {
            numbers: false, prefix: '    ', postfix: ",\n", lastpostfix: "\n"
        },
        byte: {
            hex: true, separator: ', ',
            prefix: '0x', postfix: ''
        }
    },

    {
        name:'BASIC data',
        block: {
            prefix: "", postfix: ""
        },
        line: {
            numbers: { start: 10000, step: 10}, prefix: 'DATA ', postfix: "\n"
        },
        byte: {
            hex: false, separator: ',',
            prefix: '', postfix: ''
        }
    },

    {
        name:'MADS .array',
        block: {
            prefix: '.array DATA [#size#] .byte\n', postfix: '.enda'
        },
        line: {
            numbers: false,
            prefix: '  ', postfix: '\n'
        },
        byte: {
            hex: true, separator: ', ',
            prefix: '$', postfix: ''
        }
    }, 
    
    {
        name:'Assembler DAT',
        block: {
            prefix: 'data_label\n', postfix: ''
        },
        line: {
            numbers: false,
            prefix: '  dat ', postfix: '\n'
        },
        byte: {
            hex: true, separator: ', ',
            prefix: '$', postfix: ''
        }
    },    

    {
        name:'Raw hex data CSV',
        block: {
            prefix: '', postfix: ''
        },
        line: {
            numbers: false,
            prefix: '', postfix: '\n'
        },
        byte: {
            hex: true, separator: ',',
            prefix: '', postfix: ''
        }
    },
    

    
]

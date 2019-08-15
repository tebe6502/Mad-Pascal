# REQUIREMENTS

Parser uses nodejs 8 or above. To start using parser, clone this repo, enter 'pasdoc' directory and launch
```
git clone https://gitlab.com/bocianu/pasdoc.git
cd pasdoc
npm i
```

# USAGE:
```
$ node pasdoc.js path_to_units
$ node pasdoc.js --help
```

### Options

```
  -h, --help                      Print this usage guide.
  -d, --dirpath path              Path to unit source files
  -o, --outpath path              Path to output html documents
  -t, --template template_file    Change default unit template.
  -i, --itemplate template_file   Change default index template.
  -n, --noindex                   Do not parse index file
  -s, --sortInterface             Sort Interface alphabeticaly
  -l, --language string           Change template language (default en)
```

### Examples
```
$ node pasdoc.js ../blibs -o ../blibs/doc
$ node pasdoc.js . -l pl -s
$ node pasdoc.js ~/my_pascal_libs -t ~/templates/unit.temp -n
```

# MANUAL

This tool parses Pascal comments into html file, creating 'kind of' automatic documentation.
Comments must be provided in dedicated way, to be correctly parsed. 

Below you will find some rules to follow. 

## General unit information:

To describe the *unit*, add similar block of comment right below your *unit* definition:
```
unit unit_name;
(*
* @type: unit
* @author: John Doe <jd@mail.com>
* @name: My example unit.
* @version: 1.0.0
*
* @description: 
* This unit is created for some unknown purposes.
* This description is longer than one line, but every parameter can be that long.
*
* To break line in documentation, just leave one empty comment line.
*)
```

Set of mandatory fields depends on used template. Default template displays author, name and description fields,
but if you want to provide more information, feel free to add new fields. Then you can access them in template 
using main.body object.

You can male links "clickable" in your comments, by closing then in chevrons, like &lt;www.google.com&gt;.

## Describing procedures and functions:

```
function nameOfSumingFunction(val1, val2: byte):byte;
(*
* @description:
* This function adds two bytes returning resulting value as an byte. 
* It just exists for documentation purposes, and it's description 
* is long enough to be separated into two lines. 
*  
* @param: val1 - first value to be sumed by my function
* @param: val2 - second value to be sumed by my function
* 
* @returns: (byte) - sum of val1 and val2 returned from my function 
*)
```

Procedures are using the same convention, but they do not return any value.

## Documenting types

```
type Days = (monday,tuesday,wednesday,thursday,friday,saturday,sunday);
(*
* @description: Enum type used to store days of week names.
*)

type TPoint = record 
(*
* @description: 
* Record type used to store coordinates of point. Descrption of it's 
* properties are just inline comments, and they are also parsed.
*)
    x: byte; // x coordinate
    y: byte; // y coordinate
end;
```

You can also document Object types in very similar way:
```
type OBJ = Object
(* 
* @description: 
* Some object for doing stuff.
*)
    mem: pointer; // memory address of something
    size: word;   // size of same thing
    procedure Init(a: byte);  // Initializes object
    procedure DoStuff;        // Does important stuff
end;
```

All methods can be documented like any other interface, but 
every procedure or function documented, will get linked to 
type dofinition. 

```
procedure OBJ.Init(a: byte); 
(*
*	@description:  Initializes object with mysterious byte value
* 
*	@param: a - mysterious byte to initialize object
* 
*)
```


## Documenting constants

```
const 
    SCREEN_WIDTH = 40;   // width of a screen
    SCREEN_HEIGHT = 24;  // height of a screen
    SIZE = SCREEN_WIDTH * SCREEN_HEIGHT // @nodoc 
```

All constants are automaticaly parsed into documentation, using
inline comments as description, unless it's comment contains '@nodoc'.
Those constants are omitted.

## Documenting absolute variables

```
var 
    PMG_pcolr0: byte absolute $D012; // Player 0 color
    PMG_pcolr1: byte absolute $D013; // Player 1 color
    frameClock: byte absolute 20     // frame counter - @nodoc
```

All absolute variables are documented by default, unless '@nodoc'
appears in inline comment of this variable.

## Documenting global variables

```
var 
    PMG_base: pointer;      (* @var contains base address *)
    PMG_size: word;         (* @var contains memory size used by PMG *)
```

To document any global variable, just add comment starting with @var,
and description should follow.


# TEMPLATES:

You can freely modify existing templates, to adapt them to fulfill your needs. 
[Lodash](https://lodash.com/docs/4.17.10#template) is used as an templating engine.

An object passed to unit template has following structure:
```
{
    main: {
        head: 'unit definition line',
        body: {
            // all parameters defined below unit declaration starting with @
            // like name, description, author, version...
        }
    },
    types: [ // array of all described types
        {
            name: 'name of type',
            type: 'type of type',
            desc: 'content of @description',
            record: [  // array of record properies (only for record types) 
                {
                    name: 'name of property',
                    type: 'type of property',
                    desc: 'description of property'
                },
                ...
            ]
        },
        ... 
    ]
    interface: [  // array of all described procedures and functions
        {
            head: 'procedure or function declaration line',
            name: 'name of procedure or function',
            body: {
                description: 'procedure description',
                params: [],  // array of params
                returns: []  // array of returned values
                // and any other defined properties starting with @
            }
        },
        ...
    ]
    consts: [  // array of constants
        {
            name: 'name of constant',
            value: 'value of constant',
            desc: 'description of constant'
        },
        ...
    ],
    regs: [  // array of absolute variables
        {
            name: 'name of variable',
            type: 'value of variable',
            addr: 'address of variable',
            desc: 'description of variable'
        },
        ...
    ],
    vars: [  // array of global variables
        {
            name: 'name of variable',
            type: 'value of variable',
            desc: 'description of variable'
        },
        ...
    ],
    lang: {
        // dictionary object containing fixed texts (header, footer...) in selected language
    }
}
```

An object passed to index template has following structure:
```
{
    indexData: [  // list of documents properties
        {
            head: 'unit definition line',
            body: {
                // all parameters defined below unit declaration starting with @
                // like name, description, author, version...
            },
            filename: 'name of html document'
        },
        ...
    ],
    lang: {
        // dictionary object containing fixed texts (header, footer...) in selected language 
    }
}
```

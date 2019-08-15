const fs = require('fs');
const _ = require('lodash');
const commandLineArgs = require('command-line-args');
const commandLineUsage = require('command-line-usage')
const parsePas = require('./parsers.js').parsePas;
const {helpSections, optionDefinitions} = require('./options.js');
const usage = commandLineUsage(helpSections);

// parse options
let options = {};
try {
    options = commandLineArgs(optionDefinitions);
} catch(err) {
    console.error(err.toString());
    console.log(usage);
    process.exit(2);
}

// print usage
if (!options.dirpath || options.help) {
    console.log(usage);
    process.exit(0);
}

// options validation
_.forEach([options.template, options.itemplate], fn => {
    if (!fs.existsSync(fn)) {
        console.log(`INVALID OPTIONS: Template file does not exist: '${fn}'`);
        process.exit(1);
    };
});

_.forEach([options.dirpath, options.outpath], fn => {
    if (!fs.existsSync(fn)) {
        console.log(`INVALID OPTIONS: Invalid path: '${fn}'`);
        process.exit(1);
    };
});

// init templates
const templateUnit = fs.readFileSync(`${options.template}`).toString();
const templateIndex = fs.readFileSync(`${options.itemplate}`).toString();
const unitProcessor = _.template(templateUnit);
const indexProcessor = _.template(templateIndex);
const indexData = [];

// init lang
const langs = require('./langs.json');
const lang = langs[options.language] ? langs[options.language] : langs['en'];

// get files
const files = _.filter(fs.readdirSync(options.dirpath), f=>_.endsWith(f.toLowerCase(), '.pas'));
if (files.length === 0) {
    console.log(`*** No '*.pas' files found in specified path: ${options.dirpath}`);
    process.exit(0);
} else {
    console.log(`*** Found ${files.length} file${files.length > 1 ? 's' : ''}.`);
}

// parse unit files
_.forEach(files, file => {
    console.log(`*** Parsing file: ${file}`);
    const pasContents = fs.readFileSync(`${options.dirpath}/${file}`).toString();
    const data = parsePas(pasContents);
    data.lang = lang;
    if (options.sortInterface) {
		data.interface = _.sortBy(data.interface, e => e.name.toUpperCase());
	}
    const documentation = unitProcessor(data);
    const docfilename = _.replace(file, '.pas', '.html')
    data.main.filename = docfilename;
    indexData.push(data.main);
    fs.writeFileSync(`${options.outpath}/${docfilename}`, documentation);
    fs.copyFileSync('./templates/pasdoc.css', `${options.outpath}/pasdoc.css`);
});

// parse index
if (!options.noindex) {
    console.log(`*** Parsing index file.`);
    const indexDoc = indexProcessor({indexData, lang});
    fs.writeFileSync(`${options.outpath}/index.html`, indexDoc);
}

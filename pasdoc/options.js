const sections = [
  {
    header: 'PasDoc',
    content: 'Generates html documentation from comments in pascal units.'
  },
  {
    header: 'Synopsis',
    content: [
      '$ node pasdoc.js {underline path_to_units}',
      '$ node pasdoc.js {bold --help}'
    ]
  },
  {
    header: 'Options',
    optionList: [
      {
        name: 'help', alias: 'h',
        description: 'Print this usage guide.'
      },
      {
        name: 'dirpath', alias: 'd',
        typeLabel: '{underline path}',
        description: 'Path to unit source files'
      },
      {
        name: 'outpath', alias: 'o',
        typeLabel: '{underline path}',
        description: 'Path to output html documents'
      },
      {
        name: 'template', alias: 't',
        typeLabel: '{underline template_file}',
        description: 'Change default unit template.'
      },
      {
        name: 'itemplate', alias: 'i',
        typeLabel: '{underline template_file}',
        description: 'Change default index template.'
      },
      {
        name: 'noindex', alias: 'n',
        description: 'Do not parse index file'
      },
      {
        name: 'sortInterface', alias: 's',
        description: 'Sort Interface alphabeticaly'
      },
      {
        name: 'language', alias: 'l',
        typeLabel: '{underline string}',
        description: 'Change template language (default en)'
      }
    ]
  },
  {
    header: 'Examples',
    content: [
      '$ node pasdoc.js ../blibs -o ../blibs/doc',
      '$ node pasdoc.js . -l pl',
      '$ node pasdoc.js ~/my_pascal_libs -t ~/templates/unit.temp -n'
    ]
  }
]

const optionDefinitions = [
    {name: 'dirpath', alias: 'd', defaultOption: true, defaultValue: undefined},
    {name: 'outpath', alias: 'o', defaultValue: '.'},
    {name: 'language', alias: 'l', defaultValue: 'en'},
    {name: 'template', alias: 't', defaultValue: 'templates/pascal_unit.thtml'},
    {name: 'noindex', alias: 'n', type: Boolean, defaultValue: false},
    {name: 'itemplate', alias: 'i', defaultValue: 'templates/index.thtml'},
    {name: 'sortInterface', alias: 's', type: Boolean, defaultValue: false},
    {name: 'help', alias: 'h', type: Boolean, defaultValue: false}
];

module.exports = {
    helpSections: sections, optionDefinitions
};

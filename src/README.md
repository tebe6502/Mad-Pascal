

# pas2js

[pas2js](https://wiki.freepascal.org/pas2js) is an open source Pascal to JavaScript transpiler. It parses Object Pascal and emits JavaScript. The JavaScript is currently of level ECMAScript 5 and should run in any browser or in Node.js (target "nodejs").

The current version of the transpiler comes with the following limitations

- The types "Int64" and "Single" are not directly supported.
  The reason is that JavaScript uses "double" and "BitInt" natively as representations for numbers. With the "double" datatype one a 53-bit mantissa is available.
- The start value of enums is always "0" and values for enums cannot be explicitly specified in the delcaration.

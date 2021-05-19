if target in [t_c64, t_c4p] then
  DefineIdent(1, 'EOL',      CONSTANT, CHARTOK, 0, 0, $0000000D)
else
  DefineIdent(1, 'EOL',      CONSTANT, CHARTOK, 0, 0, $0000009B);

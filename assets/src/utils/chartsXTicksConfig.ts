export function getXTicksConfig(): (string | number | null)[][] {
  return [
  // tick incr  default        year                        month   day                    hour   min            sec   mode 
  [3600,        "{HH}",        "\n{D}/{M}/{YY}",           null,   "\n{D}/{M}",           null,  null,          null, 1],
  [60,          "{HH}:{mm}",   "\n{D}/{M}/{YY}",           null,   "\n{D}/{M}",           null,  null,          null, 1],
  [1,           ":{ss}",       "\n{D}/{M}/{YY} {HH}:{mm}", null,   "\n{D}/{M} {HH}:{mm}", null,  "\n{HH}:{mm}", null, 1],
  [0.001,       ":{ss}.{fff}", "\n{D}/{M}/{YY} {HH}:{mm}", null,   "\n{D}/{M} {HH}:{mm}", null,  "\n{HH}:{mm}", null, 1],
  ]
};
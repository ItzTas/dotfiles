import { pathToFileURL } from "node:url";

const targets = process.argv.slice(2);
if (targets.length === 0) {
  console.error("usage: node ~/.claude/scripts/ts-suggestions.mjs <file.ts> [...]");
  process.exit(2);
}

const tsUrl = pathToFileURL(
  `${process.cwd()}/node_modules/typescript/lib/typescript.js`,
).href;
const { default: ts } = await import(tsUrl).catch(() => {
  console.error(
    `typescript not found in ${process.cwd()}/node_modules — run from the project root`,
  );
  process.exit(2);
});

const files = targets.map((f) => ts.sys.resolvePath(f));
const configPath = ts.findConfigFile(
  process.cwd(),
  ts.sys.fileExists,
  "tsconfig.json",
);
const config = ts.parseJsonConfigFileContent(
  ts.readConfigFile(configPath, ts.sys.readFile).config,
  ts.sys,
  process.cwd(),
);

const rootNames = [...new Set(config.fileNames.concat(files))];
const service = ts.createLanguageService({
  getScriptFileNames: () => rootNames,
  getScriptVersion: () => "1",
  getScriptSnapshot: (f) => {
    const text = ts.sys.readFile(f);
    return text === undefined ? undefined : ts.ScriptSnapshot.fromString(text);
  },
  getCurrentDirectory: () => process.cwd(),
  getCompilationSettings: () => config.options,
  getDefaultLibFileName: (o) => ts.getDefaultLibFilePath(o),
  fileExists: ts.sys.fileExists,
  readFile: ts.sys.readFile,
  readDirectory: ts.sys.readDirectory,
});

let found = 0;
for (const f of files) {
  for (const d of service.getSuggestionDiagnostics(f)) {
    const pos = d.file.getLineAndCharacterOfPosition(d.start);
    const message = ts.flattenDiagnosticMessageText(d.messageText, " ");
    console.log(
      `${f}:${pos.line + 1}:${pos.character + 1} (${d.code}) ${message}`,
    );
    found++;
  }
}
process.exit(found > 0 ? 1 : 0);

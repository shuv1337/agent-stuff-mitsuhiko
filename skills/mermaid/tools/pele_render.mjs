// Render a Mermaid file to SVG on stdout with Pele. Usage: node pele_render.mjs <pele.js> <input.mmd>
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';

const [peleJs, input] = process.argv.slice(2);
if (!peleJs || !input) {
    process.stderr.write('usage: node pele_render.mjs <pele.js> <input.mmd>\n');
    process.exit(2);
}
const { render } = await import(pathToFileURL(peleJs).href);
try {
    process.stdout.write(render(readFileSync(input, 'utf8')).svg);
} catch (err) {
    process.stderr.write(`pele: ${err && err.message ? err.message : err}\n`);
    process.exit(1);
}

import { readFileSync, readdirSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const boostConfig = JSON.parse(
  readFileSync(join(__dirname, 'mcpee.json'), 'utf-8')
);

function parseFrontmatter(content) {
  const match = content.match(/^---\r?\n([\s\S]*?)\r?\n---/);
  if (!match) return {};

  const yaml = match[1];
  const frontmatter = {};

  yaml.split(/\r?\n/).forEach(line => {
    const colonIndex = line.indexOf(':');
    if (colonIndex > -1) {
      const key = line.substring(0, colonIndex).trim();
      const value = line.substring(colonIndex + 1).trim().replace(/^['"]|['"]$/g, '');
      frontmatter[key] = value;
    }
  });

  return frontmatter;
}

function loadInstructions() {
  const instructionsDir = join(__dirname, 'instructions');
  const instructionFiles = readdirSync(instructionsDir)
    .filter(f => f.endsWith('.instructions.md'))
    .sort();

  const instructions = {};

  instructionFiles.forEach(file => {
    const filePath = join(instructionsDir, file);
    const content = readFileSync(filePath, 'utf-8');
    const frontmatter = parseFrontmatter(content);

    instructions[file] = {
      path: `instructions/${file}`,
      description: frontmatter.description || '',
      applyTo: frontmatter.applyTo || '*'
    };
  });

  return instructions;
}

export default {
  ...boostConfig,
  instructions: loadInstructions(),
  __boostPackage: true
};

const fs = require('fs');
const path = require('path');

const baseDir = path.join(__dirname, 'admin-panel/src/app/(admin)');

function walk(dir) {
    let results = [];
    const list = fs.readdirSync(dir);
    list.forEach(function(file) {
        file = path.join(dir, file);
        const stat = fs.statSync(file);
        if (stat && stat.isDirectory()) { 
            results = results.concat(walk(file));
        } else { 
            results.push(file);
        }
    });
    return results;
}

const allFiles = walk(baseDir).filter(f => f.endsWith('.ts') || f.endsWith('.tsx'));

for (const file of allFiles) {
    let content = fs.readFileSync(file, 'utf8');
    let changed = false;

    if (content.includes('process.env.NEXT_PUBLIC_SOCIETY_ID')) {
        // Remove the top-level const SOCIETY_ID = process.env...
        content = content.replace(/const\s+SOCIETY_ID\s*=\s*process\.env\.NEXT_PUBLIC_SOCIETY_ID(\s*\|\|\s*'[^']*')?;/g, '');
        
        // Ensure getSocietyId is imported
        if (!content.includes('getSocietyId')) {
            // Find the last import
            const lastImportIndex = content.lastIndexOf('import ');
            if (lastImportIndex !== -1) {
                const endOfLastImport = content.indexOf('\n', lastImportIndex);
                content = content.slice(0, endOfLastImport + 1) + 
                          "import { getSocietyId } from '@/utils/supabase/auth';\n" + 
                          content.slice(endOfLastImport + 1);
            } else {
                content = "import { getSocietyId } from '@/utils/supabase/auth';\n" + content;
            }
        }
        
        // Find every exported async function and inject const SOCIETY_ID = await getSocietyId(); if needed
        // For page.tsx files (default export)
        if (content.includes('export default async function')) {
            content = content.replace(/(export default async function[^{]+\{)/g, '$1\n  const SOCIETY_ID = await getSocietyId();');
        }
        
        // For actions.ts files (export async function)
        // Only inject if the function body uses SOCIETY_ID
        const funcRegex = /export\s+async\s+function\s+(\w+)\s*\([^)]*\)\s*\{/g;
        let match;
        const replacements = [];
        while ((match = funcRegex.exec(content)) !== null) {
            // Find the matching closing brace to know the function body bounds
            let openBraces = 1;
            let i = match.index + match[0].length;
            while (i < content.length && openBraces > 0) {
                if (content[i] === '{') openBraces++;
                if (content[i] === '}') openBraces--;
                i++;
            }
            const body = content.substring(match.index, i);
            if (body.includes('SOCIETY_ID')) {
                // Needs SOCIETY_ID injection
                replacements.push({
                    start: match.index + match[0].length,
                    text: '\n  const SOCIETY_ID = await getSocietyId();'
                });
            }
        }
        
        // Apply replacements from back to front
        for (let j = replacements.length - 1; j >= 0; j--) {
            content = content.slice(0, replacements[j].start) + replacements[j].text + content.slice(replacements[j].start);
        }
        
        fs.writeFileSync(file, content, 'utf8');
        changed = true;
        console.log('Refactored:', file);
    }
}
console.log('Done');

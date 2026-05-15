const fs = require('fs');

const text = fs.readFileSync('/tmp/eas_build_log_node.txt', 'utf8');
const lines = text.split('\n');

for (const line of lines) {
    if (!line.trim()) continue;
    try {
        const obj = JSON.parse(line);
        // level 40 is WARN, 50 is ERROR, 60 is FATAL
        if (obj.level >= 40 || obj.msg?.toLowerCase().includes('error') || obj.msg?.toLowerCase().includes('failed') || obj.msg?.toLowerCase().includes('exception')) {
            console.log(`[${obj.phase || 'UNKNOWN'}] ${obj.msg}`);
        }
    } catch (e) {
        // ignore parse errors
    }
}

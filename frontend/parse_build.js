const { execSync } = require('child_process');
const https = require('https');

async function run() {
  try {
    const jsonStr = execSync('eas build:view c8acf2b9-1731-4bce-be56-42585b2451c6 --json').toString();
    const data = JSON.parse(jsonStr);
    const logUrl = data.logFiles[0];
    
    // fetch the log using Node's fetch which supports brotli seamlessly on newer nodes
    const response = await fetch(logUrl);
    const text = await response.text();
    
    // Write to a file
    require('fs').writeFileSync('/tmp/eas_build_log_node.txt', text);
    console.log('Log fetched successfully. Finding error:');
    
    const lines = text.split('\n');
    let errorFound = false;
    for (let i = 0; i < lines.length; i++) {
        if (lines[i].toLowerCase().includes('failed') || lines[i].toLowerCase().includes('error')) {
            const start = Math.max(0, i - 5);
            const end = Math.min(lines.length, i + 10);
            console.log(lines.slice(start, end).join('\n'));
            errorFound = true;
            break;
        }
    }
  } catch (e) {
    console.error(e);
  }
}
run();

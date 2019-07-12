#!/usr/bin/env node

const { status, error } = require('child_process')
    .spawnSync(`${__dirname}/mono.sh`, process.argv.slice(2), {
        stdio: 'inherit',
        shell: true,
        env: {
            ...process.env,
            MONO_DIRNAME: __dirname,
        },
    })

if (error) {
    console.error(error)
}
process.exit(status === null ? 1 : status)

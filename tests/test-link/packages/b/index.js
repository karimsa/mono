require('@a/a')

try {
    require('c')
    throw new Error(`Succesfully required c - should not be possible`)
} catch (err) { }

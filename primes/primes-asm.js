var prime = require("./primes.asm.js");
console.time('prime');
var result = prime._computePrimesAsm();
console.timeEnd('prime');
console.log(result);

var prime = require("./primes.js");
console.time('prime');
var result = prime();
console.timeEnd('prime');
console.log(result);

const computePrime = () => {
	var lastPrime = -1;
	for (let i = 2; i < 80000; i+=1) {
		let isPrime = true;
		for (let j = i-1; j >= 2; j-=1) {
			if (i % j == 0) {
				isPrime = false;
				break;
			}
		}
		if (isPrime) {
			lastPrime = i;
		}
	}
	return lastPrime;
}
module.exports = computePrime;

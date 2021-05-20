// Extended Euclid GCD
// Returns [GCD, s, t] st.
// GCD = s * r0 + t * r1
//
// If GCD == 1 then r0 * s === 1 mod r1
// (multiplicitive inverse mod r1).

function egcd(r0, r1) {
    let s0 = 1n;
    let t0 = 0n;
    let s1 = 0n;
    let t1 = 1n;

    while (r1 !== 0n) {
        let q = r0 / r1;
        [r0, r1] = [r1, r0 - q * r1];
        [s0, s1] = [s1, s0 - q * s1];
        [t0, t1] = [t1, t0 - q * t1];
    }
    return [r0, s0, t0];
}

function modPow(n, exp, m) {
    let prod = 1n;

    while (exp !== 0n) {
        if (exp & 1n) {
            prod = (prod * n) % m;
        }
        n = (n * n) % m;
        exp = exp >> 1n;
    }
    return prod;
}

// Prime modulus
let p = 999983n;

// Random key
let k = 12345n;
console.log(egcd(k, p - 1n));
// Inverse mod totient(p) (p - 1)
let j = egcd(k, p - 1n)[1];
console.log(k, j, (k * j) % (p - 1n));

// Encrypt by m^k mod p
let m = 123456n;
let c = modPow(m, k, p);
console.log(c);

// Decrypt by c^j mod p
let m2 = modPow(c, j, p);
console.log(m2);
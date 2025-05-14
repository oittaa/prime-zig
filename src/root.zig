const std = @import("std");
const isMillerRabinProbablePrime = @import("miller_rabin.zig").isMillerRabinProbablePrime;
const isExtraStrongLucasProbablePrime = @import("lucas.zig").isExtraStrongLucasProbablePrime;
const random = std.crypto.random;
const testing = std.testing;

const DS = struct {
    limit: u128,
    bases: []const u128,
};

const deterministic_solutions = [_]DS{
    DS{ .limit = 341531, .bases = &[_]u128{9345883071009581737} },
    DS{ .limit = 1050535501, .bases = &[_]u128{ 336781006125, 9639812373923155 } },
    DS{ .limit = 350269456337, .bases = &[_]u128{ 4230279247111683200, 14694767155120705706, 16641139526367750375 } },
    DS{ .limit = 55245642489451, .bases = &[_]u128{ 2, 141889084524735, 1199124725622454117, 11096072698276303650 } },
    DS{ .limit = 7999252175582851, .bases = &[_]u128{ 2, 4130806001517, 149795463772692060, 186635894390467037, 3967304179347715805 } },
    DS{ .limit = 585226005592931977, .bases = &[_]u128{ 2, 123635709730000, 9233062284813009, 43835965440333360, 761179012939631437, 1263739024124850375 } },
    DS{ .limit = 18446744073709551616, .bases = &[_]u128{ 2, 325, 9375, 28178, 450775, 9780504, 1795265022 } },
    // https://ui.adsabs.harvard.edu/abs/2015arXiv150900864S
    DS{ .limit = 318_665_857_834_031_151_167_461, .bases = &[_]u128{ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37 } },
    DS{ .limit = 3_317_044_064_679_887_385_961_981, .bases = &[_]u128{ 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41 } },
};

// https://en.wikipedia.org/wiki/Baillie-PSW_primality_test
fn isBailliePswProbablePrime(n: anytype) bool {
    if (n < 1 << 128)
        return isMillerRabinProbablePrime(n, &.{2}) and isExtraStrongLucasProbablePrime(n);
    const random_base = random.intRangeAtMost(u128, 3, (1 << 128) - 1);
    return isMillerRabinProbablePrime(n, &.{ 2, random_base }) and isExtraStrongLucasProbablePrime(n);
}

/// Test if n is a prime number (true) or not (false). For n ~2^81 the
/// answer is definitive; larger n values have a small probability of actually
/// being pseudoprimes.
///
/// For small numbers, a set of deterministic Miller-Rabin tests are performed
/// with bases that are known to have no counterexamples in their range.
/// Finally if the number is larger than ~2^81, a strong BPSW test is
/// performed. While this is a probable prime test and it is believed that
/// counterexamples exist, currently there are no known counterexamples.
pub fn isPrime(n: anytype) bool {
    if (n == 2 or n == 3 or n == 5)
        return true;
    if (n < 2 or n & 1 == 0 or (n % 3) == 0 or (n % 5) == 0)
        return false;
    if (n < 49)
        return true;
    if ((n % 7) == 0 or (n % 11) == 0 or (n % 13) == 0 or (n % 17) == 0 or (n % 19) == 0 or (n % 23) == 0 or (n % 29) == 0 or (n % 31) == 0 or (n % 37) == 0 or (n % 41) == 0 or (n % 43) == 0 or (n % 47) == 0)
        return false;
    if (n < 2809)
        return true;

    for (deterministic_solutions) |item| {
        if (n < item.limit) return isMillerRabinProbablePrime(n, item.bases);
    }
    return isBailliePswProbablePrime(n);
}

/// Returns a prime. bits is the desired bit length of the prime.
pub fn generate(comptime bits: u16) std.meta.Int(.unsigned, bits) {
    const UnsignedT = std.meta.Int(.unsigned, bits);
    std.debug.assert(bits > 1);
    if (bits == 2)
        return random.intRangeAtMost(UnsignedT, 2, 3);
    while (true) {
        const value = random.intRangeAtMost(UnsignedT, 1 << (bits - 1), (1 << bits) - 1) | 1;
        if (isPrime(value)) return value;
    }
}

// Returns a "safe" prime. If the number generated is n, then check that
// (n-1)/2 is also prime. bits is the desired length of the prime.
pub fn generateSafe(comptime bits: u16) std.meta.Int(.unsigned, bits) {
    std.debug.assert(bits > 2);
    while (true) {
        const value = generate(bits);
        if (isPrime(value / 2)) return value;
    }
}

test "Known Primes" {
    try testing.expect(isPrime(@as(u8, 47)));
    try testing.expect(isPrime(@as(u32, 32_424_781)));
    try testing.expect(isPrime(@as(u32, 2_147_483_647)));
    try testing.expect(isPrime(@as(u192, 4547337172376300111955330758342147474062293202868155909489)));
    try testing.expect(isPrime(@as(u697, 0x1f55332c3a48b910f9942f6c914e58bef37a47ee45cb164a5b6b8d1006bf59a059c21449939ebebfdf517d2e1dbac88010d7b1f141e997bd6801ddaec9d05910f4f2de2b2c4d714e2c14a72fc7f17aa428d59c531627f09)));
}

test "Not Primes" {
    try testing.expect(!isPrime(@as(u8, 0)));
    try testing.expect(!isPrime(@as(u8, 1)));
    try testing.expect(!isPrime(@as(u32, 341_531)));
    try testing.expect(!isPrime(@as(u32, 32_424_581)));
    try testing.expect(!isPrime(@as(u32, 1_050_535_501)));
    try testing.expect(!isPrime(@as(u64, 350_269_456_337)));
    try testing.expect(!isPrime(@as(u64, 55_245_642_489_451)));
    try testing.expect(!isPrime(@as(u64, 7_999_252_175_582_851)));
    try testing.expect(!isPrime(@as(u64, 585_226_005_592_931_977)));
    try testing.expect(!isPrime(@as(u192, 4547337172376300111955330758342147474062293202868155909393)));
}

test "Baillie-PSW primality test" {
    try testing.expect(!isBailliePswProbablePrime(@as(u8, 0)));
    try testing.expect(!isBailliePswProbablePrime(@as(u8, 1)));
    try testing.expect(isBailliePswProbablePrime(@as(u8, 2)));
    try testing.expect(isBailliePswProbablePrime(@as(u8, 3)));
    try testing.expect(isBailliePswProbablePrime(@as(u8, 47)));
}

test {
    _ = @import("test.zig");
}

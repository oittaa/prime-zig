const std = @import("std");
const tools = @import("tools.zig");
const math = std.math;
const testing = std.testing;

// Extra Strong Lucas compositeness test.

// Returns false if n is definitely composite, and true if n is a "extra
// strong" Lucas probable prime.

// The parameters are selected using P = 3, Q = 1, then incrementing P until
// (D|n) == -1. The test itself is as defined in Grantham 2000, from the
// Mo and Jones preprint. The parameter selection and test are the same as
// used in OEIS A217719, Perl's Math::Prime::Util, and the Lucas pseudoprime
// page on Wikipedia.

// It is 20-50% faster than the strong test. Because of the different
// parameters selected, there is no relationship between the strong Lucas
// pseudoprimes and extra strong Lucas pseudoprimes. In particular, one is not
// a subset of the other.
pub fn isExtraStrongLucasProbablePrime(n: anytype) bool {
    if (n == 2) return true;
    if (n < 2 or n & 1 == 0 or tools.isPerfectSquare(n))
        return false;

    const T = @TypeOf(n);
    const T_2 = std.meta.Int(.unsigned, @typeInfo(T).int.bits * 2);

    const P = extraStrongLucasParams(n);
    if (P == 0)
        return false;

    // remove powers of 2 from n+1 (= k * 2**s)
    var k = n + 1;
    var s: u16 = 0;
    while (k & 1 == 0) {
        k >>= 1;
        s += 1;
    }

    const U, var V: T_2 = extraStrongLucasSequence(n, P, k);

    if (U == 0 and (V == 2 or V == n - 2))
        return true;
    for (1..s) |_| {
        if (V == 0)
            return true;
        V *= V;
        if (V < 2) V += n;
        V = @mod(V - 2, n);
    }
    return false;
}

// Calculates the "extra strong" parameter P for n.
fn extraStrongLucasParams(n: anytype) @TypeOf(n) {
    var P: @TypeOf(n) = 3;

    while (true) {
        const D = P * P - 4;
        const j = tools.jacobiSymbol(D, n);
        if (j == 0) {
            const g = math.gcd(D, n);
            if (g != 1 and g != n) return 0;
        }
        if (j == -1)
            break;
        P += 1;
    }
    return P;
}

// Return the modular Lucas sequence (U_k, V_k).
// Given a Lucas sequence defined by P, Q, returns the kth values for U and V,
// all modulo n. This is intended for use with possibly very large values of n
// and k, where the combinatorial functions would be completely unusable.
fn extraStrongLucasSequence(n: anytype, P: anytype, k: anytype) struct { @TypeOf(n), @TypeOf(n) } {
    const T = @TypeOf(n, k);
    // TODO: exact bit_count for T_2
    const T_2 = std.meta.Int(.unsigned, @typeInfo(T).int.bits * 5 / 2);
    const D = P * P - 4;
    std.debug.assert(n > 1);
    std.debug.assert(k >= 0);
    std.debug.assert(D != 0);

    if (k == 0) return .{ 0, 2 };
    var U: T_2 = 1;
    var V: T_2 = P;
    var b: u16 = @intCast(math.log2(k) + 1);

    while (b > 1) {
        U = @mod(U * V, n);
        V *= V;
        if (V < 2) V += n;
        V = @mod(V - 2, n);
        b -= 1;
        if (k >> @intCast(b - 1) & 1 != 0) {
            const U_old = U;
            U = U * P + V;
            V = V * P + U_old * D;
            if (U & 1 != 0)
                U += n;
            if (V & 1 != 0)
                V += n;
            U >>= 1;
            V >>= 1;
        }
    }
    return .{ @intCast(@mod(U, n)), @intCast(@mod(V, n)) };
}

test "Extra strong Lucas Probable Prime small numbers" {
    try testing.expect(isExtraStrongLucasProbablePrime(@as(u8, 2)));
    try testing.expect(isExtraStrongLucasProbablePrime(@as(u8, 3)));
    try testing.expect(!isExtraStrongLucasProbablePrime(@as(u8, 4)));
    try testing.expect(isExtraStrongLucasProbablePrime(@as(u8, 5)));
    try testing.expect(!isExtraStrongLucasProbablePrime(@as(u8, 9)));
    try testing.expect(!isExtraStrongLucasProbablePrime(@as(u8, 1)));
    try testing.expect(!isExtraStrongLucasProbablePrime(@as(u8, 15)));
    try testing.expect(!isExtraStrongLucasProbablePrime(@as(u8, 255)));
    try testing.expect(isExtraStrongLucasProbablePrime(@as(u16, 17)));
}

test "Known extra strong Lucas pseudoprimes" {
    // https://oeis.org/A217719
    try testing.expect(isExtraStrongLucasProbablePrime(@as(u16, 989)));
    try testing.expect(isExtraStrongLucasProbablePrime(@as(u16, 3239)));
    try testing.expect(isExtraStrongLucasProbablePrime(@as(u16, 5777)));
    try testing.expect(isExtraStrongLucasProbablePrime(@as(u32, 429479)));
    try testing.expect(isExtraStrongLucasProbablePrime(@as(u32, 635627)));
}

test "Large composite" {
    const num1: u257 = 0x10000000000000000000000000000000000000000000000000000000000000001;
    try testing.expect(!isExtraStrongLucasProbablePrime(num1));
    const num2: u256 = ((1 << 128) - 159) * ((1 << 128) - 173);
    try testing.expect(!isExtraStrongLucasProbablePrime(num2));
    const num3: u512 = ((1 << 256) - 189) * ((1 << 256) - 357);
    try testing.expect(!isExtraStrongLucasProbablePrime(num3));
}

test "Lucas extra strong params" {
    try testing.expectEqual(3, extraStrongLucasParams(3));
    try testing.expectEqual(4, extraStrongLucasParams(5));
    try testing.expectEqual(3, extraStrongLucasParams(7));
    try testing.expectEqual(0, extraStrongLucasParams(9));
    try testing.expectEqual(5, extraStrongLucasParams(11));
    try testing.expectEqual(6, extraStrongLucasParams(59));
    try testing.expectEqual(11, extraStrongLucasParams(479));
}

// https://oeis.org/A001906
// https://oeis.org/A005248
test "Lucas sequence" {
    //const num: u6644 = math.pow(u6644, 10, 2000) + 4561;
    const num: u128 = 4561;
    try testing.expectEqual(.{ 0, 2 }, extraStrongLucasSequence(num, 3, 0));
    try testing.expectEqual(.{ 55, 123 }, extraStrongLucasSequence(num, 3, @as(u8, 5)));
}

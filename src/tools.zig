const std = @import("std");
const math = std.math;
const testing = std.testing;

/// Modular exponentiation
pub fn modPow(x: anytype, y: anytype, z: anytype) @TypeOf(z) {
    std.debug.assert(y >= 0);
    std.debug.assert(z != 0);
    if (z == 1) return 0;
    if (y == 0) return 1;
    if (x == 0) return 0;
    if (x == 1) return 1;
    const T = @TypeOf(z);
    const T_2 = std.meta.Int(@typeInfo(T).int.signedness, @typeInfo(T).int.bits * 2);
    var res: T_2 = 1;
    var base: T_2 = @intCast(@mod(x, z));
    var exp = y;
    while (exp > 0) : (exp >>= 1) {
        if (0 != exp & 1) {
            res = @mod(res * base, z);
        }
        base = @mod(base * base, z);
    }
    return @intCast(res);
}

// Function to check if a large unsigned integer is a perfect square.
pub fn isPerfectSquare(n: anytype) bool {
    // Handle trivial cases
    if (n < 0) return false;
    if (n < 2) return true;

    var rem: u8 = @truncate(n);
    switch (rem) {
        0, 1, 4, 9, 16, 17, 25, 33, 36, 41, 49, 57, 64, 65, 68, 73, 81, 89, 97, 100, 105, 113, 121, 129, 132, 137, 144, 145, 153, 161, 164, 169, 177, 185, 193, 196, 201, 209, 217, 225, 228, 233, 241, 249 => {}, // Possible square endings
        else => return false, // Not possible
    }
    rem = @intCast(n % 9);
    switch (rem) {
        0, 1, 4, 7 => {},
        else => return false,
    }
    rem = @intCast(n % 5);
    switch (rem) {
        0, 1, 4 => {},
        else => return false,
    }
    rem = @intCast(n % 7);
    switch (rem) {
        0, 1, 2, 4 => {},
        else => return false,
    }
    rem = @intCast(n % 13);
    switch (rem) {
        0, 1, 3, 4, 9, 10, 12 => {},
        else => return false,
    }
    rem = @intCast(n % 17);
    switch (rem) {
        0, 1, 2, 4, 8, 9, 13, 15, 16 => {},
        else => return false,
    }
    rem = @intCast(n % 97);
    switch (rem) {
        0, 1, 2, 3, 4, 6, 8, 9, 11, 12, 16, 18, 22, 24, 25, 27, 31, 32, 33, 35, 36, 43, 44, 47, 48, 49, 50, 53, 54, 61, 62, 64, 65, 66, 70, 72, 73, 75, 79, 81, 85, 86, 88, 89, 91, 93, 94, 95, 96 => {},
        else => return false,
    }

    const n_sqrt: @TypeOf(n) = math.sqrt(n);
    return (n_sqrt * n_sqrt == n);
}

// Returns the Jacobi symbol (k / n).
// https://en.wikipedia.org/wiki/Jacobi_symbol
pub fn jacobiSymbol(k: anytype, n: anytype) i8 {
    // n must be positive and odd
    std.debug.assert(n > 0);
    std.debug.assert(n & 1 == 1);
    var k_var = @mod(k, n);
    if (k_var == 0) return @intFromBool(n == 1);
    if (n == 1 or k_var == 1) return 1;
    var n_var = n;
    var result: i8 = 1;
    while (k_var != 0) {
        while (k_var & 1 == 0) {
            k_var >>= 1;
            const n_var_mod_8: u3 = @truncate(n_var);
            if (n_var_mod_8 == 3 or n_var_mod_8 == 5) result = -result;
        }
        const temp = k_var;
        k_var = n_var;
        n_var = temp;
        if (k_var & 3 == 3 and n_var & 3 == 3)
            result = -result;
        k_var %= n_var;
    }
    if (n_var == 1)
        return result;
    return 0;
}

test "powMod" {
    try testing.expectEqual(445, modPow(@as(u8, 4), @as(u8, 13), @as(u16, 497)));
    try testing.expectEqual(66, modPow(@as(u8, 241), @as(u8, 251), @as(u8, 239)));
    try testing.expectEqual(141, modPow(@as(u32, 32_424_781), @as(u16, 257), @as(u8, 251)));
    try testing.expectEqual(115792089237316195423570985008687907853269984665640564039457584007913043546497, modPow(@as(u257, (1 << 256) + 1), @as(u16, 4097), @as(u257, (1 << 256) + 3)));
    try testing.expectEqual(-52, modPow(@as(i8, 4), @as(u8, 13), @as(i16, -497)));
    try testing.expectEqual(5, modPow(@as(i8, -14), @as(u8, 5), @as(i8, 17)));
    try testing.expectEqual(-12, modPow(@as(i8, -14), @as(u8, 5), @as(i8, -17)));
}

test "powMod special cases" {
    try testing.expectEqual(0, modPow(@as(u8, 7), @as(u8, 0), @as(u2, 1)));
    try testing.expectEqual(1, modPow(@as(u8, 7), @as(u8, 0), @as(u2, 2)));
    try testing.expectEqual(0, modPow(@as(u8, 0), @as(u8, 13), @as(u16, 497)));
    try testing.expectEqual(1, modPow(@as(u8, 1), @as(u8, 10), @as(u8, 7)));
}

test "isPerfetSquare" {
    try testing.expect(isPerfectSquare(@as(u8, 0)));
    try testing.expect(isPerfectSquare(@as(u8, 1)));
    try testing.expect(!isPerfectSquare(@as(u8, 2)));
    try testing.expect(!isPerfectSquare(@as(u8, 3)));
    try testing.expect(isPerfectSquare(@as(u8, 4)));
    try testing.expect(!isPerfectSquare(@as(u8, 5)));
    try testing.expect(isPerfectSquare(@as(u8, 9)));
    try testing.expect(isPerfectSquare(@as(u20, 994009)));
    try testing.expect(isPerfectSquare(@as(u129, 340282366920938463463374607431768211456)));
    try testing.expect(isPerfectSquare(@as(u256, 115792089237316195423570985008687907852589419931798687112530834793049593217025)));
}

test "perfect squares from the first 100k integers" {
    const max = 100_000;
    var i: u32 = 0;
    while (i < max) : (i += 1) {
        const naive_solution: bool = math.pow(u32, math.sqrt(i), 2) == i;
        try testing.expectEqual(naive_solution, isPerfectSquare(i));
    }
}

test "Jacobi symbol" {
    try testing.expectEqual(-1, jacobiSymbol(45, @as(u8, 77)));
    try testing.expectEqual(1, jacobiSymbol(60, @as(u8, 121)));
    try testing.expectEqual(1, jacobiSymbol(0, @as(u8, 1)));
    try testing.expectEqual(0, jacobiSymbol(0, @as(u8, 3)));
    try testing.expectEqual(1, jacobiSymbol(1, @as(u8, 3)));
    try testing.expectEqual(-1, jacobiSymbol(2, @as(u8, 5)));
    try testing.expectEqual(0, jacobiSymbol(3, @as(u8, 9)));
    try testing.expectEqual(1, jacobiSymbol(7, @as(u8, 9)));
    try testing.expectEqual(1, jacobiSymbol(601, @as(u16, 69)));
}

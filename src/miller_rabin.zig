const std = @import("std");
const tools = @import("tools.zig");
const modPow = tools.modPow;
const testing = std.testing;

pub fn isMillerRabinProbablePrime(n: anytype, bases: []const u128) bool {
    const T = @TypeOf(n);
    if (n == 2) return true;
    if (n < 2 or n & 1 == 0) return false;
    var d: T = n >> 1;
    var s: u16 = 1;
    while (d & 1 == 0) {
        d >>= 1;
        s += 1;
    }
    for (bases) |b| {
        const a = @mod(b, n);
        if (a != 0 and !witness(a, d, n, s)) return false;
    }
    return true;
}

fn witness(a: anytype, d: anytype, n: anytype, s: u16) bool {
    var x: @TypeOf(a, d, n) = modPow(a, d, n);
    if (x == 1 or x == n - 1) return true;
    var idx: u16 = 1;
    while (idx < s) : (idx += 1) {
        x = modPow(x, @as(u2, 2), n);
        if (x == 1) return false;
        if (x == n - 1) return true;
    }
    return false;
}

test "Small known numbers" {
    const bases = [_]u128{2};
    try testing.expect(isMillerRabinProbablePrime(@as(u16, 2), &bases));
    try testing.expect(isMillerRabinProbablePrime(@as(u16, 3), &bases));
    try testing.expect(!isMillerRabinProbablePrime(@as(u16, 9), &bases));
    try testing.expect(!isMillerRabinProbablePrime(@as(u16, 1), &bases));
}

test "Carmichael numbers" {
    const bases = [_]u128{2};
    try testing.expect(!isMillerRabinProbablePrime(@as(u16, 561), &bases));
    try testing.expect(!isMillerRabinProbablePrime(@as(u16, 8911), &bases));
}

test "Large composites" {
    const bases = [_]u128{2};
    try testing.expect(isMillerRabinProbablePrime(@as(u257, 0x10000000000000000000000000000000000000000000000000000000000000001), &bases));
}

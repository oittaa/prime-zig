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
//
// A significant fraction of non-squares can be quickly identified by checking
// whether the input is a quadratic residue modulo small integers.
//
// The function first tests the input mod 256, which means just examining the
// low byte. Only 44 different values occur for squares mod 256, so 82.8% of
// inputs can be immediately identified as non-squares.
//
// Similar tests are done mod 9, 5, 7, 13, 17, 97, 241, 257, and 673, for a
// total 99.93%.
//
// These moduli are chosen because they’re factors of 2^48-1, and such a
// remainder can be quickly taken just using additions.
pub fn isPerfectSquare(n: anytype) bool {
    // Handle trivial cases
    if (n < 0) return false;
    if (n < 2) return true;

    var rem8: u8 = @truncate(n);
    switch (rem8) {
        0, 1, 4, 9, 16, 17, 25, 33, 36, 41, 49, 57, 64, 65, 68, 73, 81, 89, 97, 100, 105, 113, 121, 129, 132, 137, 144, 145, 153, 161, 164, 169, 177, 185, 193, 196, 201, 209, 217, 225, 228, 233, 241, 249 => {}, // Possible square endings
        else => return false, // Not possible
    }

    const k_bitsize: u8 = 48;
    const modulus = (1 << k_bitsize) - 1;
    var current_val = n;
    while (current_val > modulus) {
        const high_part = current_val >> k_bitsize;
        const low_part = current_val & modulus;
        current_val = high_part + low_part;
    }
    if (current_val == modulus) current_val = 0;
    const n_remainder: u64 = @intCast(current_val);

    rem8 = @intCast(n_remainder % 9);
    switch (rem8) {
        0, 1, 4, 7 => {},
        else => return false,
    }
    rem8 = @intCast(n_remainder % 5);
    switch (rem8) {
        0, 1, 4 => {},
        else => return false,
    }
    rem8 = @intCast(n_remainder % 7);
    switch (rem8) {
        0, 1, 2, 4 => {},
        else => return false,
    }
    rem8 = @intCast(n_remainder % 13);
    switch (rem8) {
        0, 1, 3, 4, 9, 10, 12 => {},
        else => return false,
    }
    rem8 = @intCast(n_remainder % 17);
    switch (rem8) {
        0, 1, 2, 4, 8, 9, 13, 15, 16 => {},
        else => return false,
    }
    rem8 = @intCast(n_remainder % 97);
    switch (rem8) {
        0, 1, 2, 3, 4, 6, 8, 9, 11, 12, 16, 18, 22, 24, 25, 27, 31, 32, 33, 35, 36, 43, 44, 47, 48, 49, 50, 53, 54, 61, 62, 64, 65, 66, 70, 72, 73, 75, 79, 81, 85, 86, 88, 89, 91, 93, 94, 95, 96 => {},
        else => return false,
    }
    rem8 = @intCast(n_remainder % 241);
    switch (rem8) {
        0, 1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 15, 16, 18, 20, 24, 25, 27, 29, 30, 32, 36, 40, 41, 45, 47, 48, 49, 50, 53, 54, 58, 59, 60, 61, 64, 67, 72, 75, 77, 79, 80, 81, 82, 83, 87, 90, 91, 94, 96, 97, 98, 100, 106, 107, 108, 113, 116, 118, 119, 120, 121, 122, 123, 125, 128, 133, 134, 135, 141, 143, 144, 145, 147, 150, 151, 154, 158, 159, 160, 161, 162, 164, 166, 169, 174, 177, 180, 181, 182, 183, 187, 188, 191, 192, 193, 194, 196, 200, 201, 205, 209, 211, 212, 214, 216, 217, 221, 223, 225, 226, 229, 231, 232, 233, 235, 236, 237, 238, 239, 240 => {},
        else => return false,
    }
    var rem16: u16 = @intCast(n_remainder % 257);
    switch (rem16) {
        0, 1, 2, 4, 8, 9, 11, 13, 15, 16, 17, 18, 21, 22, 23, 25, 26, 29, 30, 31, 32, 34, 35, 36, 42, 44, 46, 49, 50, 52, 57, 58, 59, 60, 61, 62, 64, 67, 68, 70, 72, 73, 79, 81, 84, 88, 89, 92, 95, 98, 99, 100, 104, 111, 113, 114, 116, 117, 118, 120, 121, 122, 123, 124, 128, 129, 133, 134, 135, 136, 137, 139, 140, 141, 143, 144, 146, 153, 157, 158, 159, 162, 165, 168, 169, 173, 176, 178, 184, 185, 187, 189, 190, 193, 195, 196, 197, 198, 199, 200, 205, 207, 208, 211, 213, 215, 221, 222, 223, 225, 226, 227, 228, 231, 232, 234, 235, 236, 239, 240, 241, 242, 244, 246, 248, 249, 253, 255, 256 => {},
        else => return false,
    }
    rem16 = @intCast(n_remainder % 673);
    switch (rem16) {
        0, 1, 2, 3, 4, 6, 7, 8, 9, 12, 13, 14, 16, 18, 21, 23, 24, 25, 26, 27, 28, 29, 32, 36, 37, 39, 42, 46, 48, 49, 50, 52, 53, 54, 55, 56, 58, 63, 64, 69, 72, 73, 74, 75, 78, 81, 83, 84, 85, 87, 89, 91, 92, 95, 96, 97, 98, 100, 103, 104, 106, 108, 110, 111, 112, 116, 117, 121, 126, 127, 128, 138, 139, 144, 146, 147, 148, 150, 151, 155, 156, 159, 161, 162, 163, 165, 166, 168, 169, 170, 174, 175, 178, 182, 184, 187, 189, 190, 191, 192, 194, 196, 200, 203, 205, 206, 207, 208, 209, 212, 215, 216, 219, 220, 222, 223, 224, 225, 227, 229, 232, 233, 234, 235, 241, 242, 243, 249, 252, 254, 255, 256, 257, 259, 261, 263, 267, 273, 276, 278, 281, 285, 288, 289, 291, 292, 293, 294, 295, 296, 299, 300, 302, 305, 309, 310, 312, 317, 318, 322, 323, 324, 325, 326, 330, 332, 333, 335, 336, 337, 338, 340, 341, 343, 347, 348, 349, 350, 351, 355, 356, 361, 363, 364, 368, 371, 373, 374, 377, 378, 379, 380, 381, 382, 384, 385, 388, 392, 395, 397, 400, 406, 410, 412, 414, 416, 417, 418, 419, 421, 424, 430, 431, 432, 438, 439, 440, 441, 444, 446, 448, 449, 450, 451, 453, 454, 457, 458, 461, 464, 465, 466, 467, 468, 470, 473, 477, 479, 481, 482, 483, 484, 486, 489, 491, 495, 498, 499, 503, 504, 505, 507, 508, 510, 511, 512, 514, 517, 518, 522, 523, 525, 526, 527, 529, 534, 535, 545, 546, 547, 552, 556, 557, 561, 562, 563, 565, 567, 569, 570, 573, 575, 576, 577, 578, 581, 582, 584, 586, 588, 589, 590, 592, 595, 598, 599, 600, 601, 604, 609, 610, 615, 617, 618, 619, 620, 621, 623, 624, 625, 627, 631, 634, 636, 637, 641, 644, 645, 646, 647, 648, 649, 650, 652, 655, 657, 659, 660, 661, 664, 665, 666, 667, 669, 670, 671, 672 => {},
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

const std = @import("std");
const random = std.crypto.random;
const tools = @import("tools.zig");
const prime = @import("root.zig");

pub fn main() !void {
    try benchmrk(16, 1_000_000, false);
    try benchmrk(64, 1_000_000, false);
    try benchmrk(128, 1_000_000, false);
    std.debug.print("Example 128-bit prime: {}\n", .{prime.generate(128)});
    std.debug.print("Example 128-bit safe prime: {}\n", .{prime.generateSafe(128)});
}

fn isSquareNaive(n: anytype) bool {
    const i: @TypeOf(n) = std.math.sqrt(n);
    return i * i == n;
}

fn benchmrk(comptime bits: u16, numbers: u64, print: bool) !void {
    const UnsignedT = std.meta.Int(.unsigned, bits);
    const stderr = std.io.getStdErr().writer();
    const stdout = std.io.getStdOut().writer();
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() == .leak) std.fmt.format(stderr, "WARNING: memory leak!\n", .{}) catch unreachable;
    const allocator = gpa.allocator();

    var print_buffer = try allocator.alloc(UnsignedT, numbers);
    defer allocator.free(print_buffer);

    var i: u64 = 0;
    while (i < numbers) : (i += 1) {
        const value = random.intRangeAtMost(UnsignedT, 1 << (bits - 1), (1 << bits) - 1);
        print_buffer[i] = value;
    }

    var results1 = try allocator.alloc(bool, numbers);
    defer allocator.free(results1);
    i = 0;
    var timer = try std.time.Timer.start();
    while (i < numbers) : (i += 1) {
        results1[i] = isSquareNaive(print_buffer[i]);
    }
    const duration1 = timer.read();

    var results2 = try allocator.alloc(bool, numbers);
    defer allocator.free(results2);
    i = 0;
    timer = try std.time.Timer.start();
    while (i < numbers) : (i += 1) {
        results2[i] = tools.isPerfectSquare(print_buffer[i]);
    }
    const duration2 = timer.read();

    i = 0;
    while (i < numbers) : (i += 1) {
        if (results1[i] != results2[i]) {
            try std.fmt.format(stderr, "Mismatch at index {d}: {d} {}\n", .{ i, print_buffer[i], results1[i] });
            return error.Mismatch;
        }
    }

    if (print) {
        for (print_buffer, results1) |cur_number, cur_result| {
            try std.fmt.format(stdout, "{} {}\n", .{ cur_number, cur_result });
        }
    } else {
        const duration_per_number1 = @as(u64, @intFromFloat(@as(f64, @floatFromInt(duration1)) / @as(f64, @floatFromInt(numbers))));
        const duration_per_number2 = @as(u64, @intFromFloat(@as(f64, @floatFromInt(duration2)) / @as(f64, @floatFromInt(numbers))));
        const speedup = @as(f64, @floatFromInt(duration1)) / @as(f64, @floatFromInt(duration2));
        try std.fmt.format(stdout, "Naive square test: {d} {d}-bit numbers in {} = {}/number\n", .{ numbers, bits, std.fmt.fmtDuration(duration1), std.fmt.fmtDuration(duration_per_number1) });
        try std.fmt.format(stdout, "GMP-style square test: {d} {d}-bit numbers in {} = {}/number\n", .{ numbers, bits, std.fmt.fmtDuration(duration2), std.fmt.fmtDuration(duration_per_number2) });
        try std.fmt.format(stdout, "Speedup: {d:.2}x\n", .{speedup});
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

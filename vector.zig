const std = @import("std");

fn chunk(comptime T: type, start: T) @Vector(4, T) {
    const Vec = @Vector(4, T);

    const ln_640320 = std.math.log(T, std.math.e, 640320.0);

    const sign_vec: Vec = blk: {
        var values: [4]T = undefined;
        for (&values, 0..) |*v, i| {
            const kk = start + @as(T, @floatFromInt(i)) + 1;
            v.* = if ((@as(u64, @intFromFloat(kk)) & 1) == 0) -1.0 else 1.0;
        }
        break :blk @as(Vec, values);
    };

    var result: Vec = undefined;

    for (0..4) |i| {
        const ki = start + @as(T, @floatFromInt(i));
        const log_6k_fact = std.math.lgamma(T, (6.0 * ki) + 1.0);
        const log_3k_fact = std.math.lgamma(T, (3.0 * ki) + 1.0);
        const log_k_fact = std.math.lgamma(T, ki + 1.0);
        const log_pow = (3.0 * ki) * ln_640320;

        const top = log_6k_fact + std.math.log(T, std.math.e, 545140134.0 * ki + 13591409.0);
        const bottom = log_3k_fact + 3.0 * log_k_fact + log_pow;
        const log_term = top - bottom;

        result[i] = sign_vec[i] * @exp(log_term);
    }

    return result;
}

pub fn chudnovsky(comptime T: type, n: T) T {
    var sum: @Vector(4, T) = @splat(0.0);

    var i: f64 = 0;
    while (i < n) : (i += 4) {
        const term = chunk(T, i);
        sum += term;
    }

    const total = @reduce(.Add, sum);
    return 426880.0 * @sqrt(10005.0) / total;
}

test {
    try std.testing.expectEqual(3.14159265358979e0, chudnovsky(f64, 2));
}

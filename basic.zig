const std = @import("std");

fn binarySplit(comptime T: type, a: T, b: T) @Vector(3, T) {
    if (b == (a + 1)) {
        const p: T = -(6*a - 1) * (2*a - 1) * (6*a - 5);
        const q: T = 10939058860032000 * std.math.pow(T, a, 3);
        const r: T = p * (545140134*a + 13591409);
        return .{ p, q, r };
    }

    const m: T = (a + b) / 2;
    const am = binarySplit(T, a, m);
    const mb = binarySplit(T, m, b);

    const p: T = am[0] * mb[0];
    const q: T = am[1] * mb[1];
    const r: T = mb[1] * am[2] + am[0] * mb[2];

    return .{ p, q, r };
}

pub fn chudnovsky(comptime T: type, n: T) T {
    const s = binarySplit(T, 1, n);
    return (426880 * @sqrt(@as(T, 10005)) * s[1]) / (13591409 * s[1] + s[2]);
}

test {
    try std.testing.expectEqual(3.1415926535897936e0, chudnovsky(f64, 2));
}

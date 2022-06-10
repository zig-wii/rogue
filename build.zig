const std = @import("std");
const zogc = @import("vendor/zogc/build.zig");

pub fn build(builder: *std.build.Builder) !void {
    var obj = try zogc.target_wii(builder, .{ .name = "main", .textures = "src/textures" });
    obj.addPackagePath("zogc", "vendor/zogc/src/main.zig");
}

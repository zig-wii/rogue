const std = @import("std");
const zogc = @import("vendor/zogc/build.zig");

pub fn build(builder: *std.build.Builder) !void {
    try ensure_packages(builder.allocator, "vendor");
    var obj = try zogc.target_wii(builder, .{ .name = "main" });
    obj.addPackagePath("zogc", "./vendor/zogc/src/main.zig");
}

// Ensures packages in folder are installed with git submodule
fn ensure_packages(allocator: std.mem.Allocator, path: []const u8) !void {
    const dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        const target = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ path, entry.name });
        var child = std.ChildProcess.init(&.{ "git", "submodule", "update", "--init", "--recursive", target }, allocator);
        child.cwd = std.fs.path.dirname(@src().file) orelse ".";
        child.stderr = std.io.getStdErr();
        child.stdout = std.io.getStdOut();
        _ = try child.spawnAndWait();
    }
}

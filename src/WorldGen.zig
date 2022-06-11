const WorldGen = @This();
const std = @import("std");
const ArrayList = std.ArrayList;
const Block = @import("Block.zig");
const main = @import("main.zig");
const Rng = std.rand.DefaultPrng;

rng: std.rand.Xoshiro256,

pub fn init() WorldGen {
    return .{ .rng = Rng.init(0) };
}

pub fn generate(self: *WorldGen, state: *main.State) !void {
    try self.base_grass(&state.blocks);
}

fn base_grass(self: *WorldGen, blocks: *ArrayList(Block)) !void {
    var height: f32 = 3;
    const min: usize = 5;
    const max: usize = 10;
    const smooth: usize = 3;

    // Loop from left to right
    var i: f32 = 0;
    var count: usize = 0;
    while (i < main.screen_width / 32 * 3) : (i += 1) {
        if (count < smooth) count += 1;
        if (count == smooth) {
            const chance = self.rng.random().intRangeAtMost(u8, 0, 10);
            if (chance > 8 or chance < 2) count = 0;
            if (chance > 8 and height < min) height += 1;
            if (chance < 2 and height > max) height -= 1;
        }

        // Create grass block
        try blocks.append(Block.init(-main.screen_width + i * 32, main.screen_height - (height * 32), .grass));

        // Loop from grass block and downwards and create dirt block
        var j: f32 = height - 1;
        while (j > 0) : (j -= 1) {
            try blocks.append(Block.init(-main.screen_width + i * 32, main.screen_height - (j * 32), .dirt));
        }
    }
}

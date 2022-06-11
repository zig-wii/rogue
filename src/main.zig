// std
const std = @import("std");
const ArrayList = std.ArrayList;

// ogc
const ogc = @import("ogc");
const Pad = ogc.Pad;
const Video = ogc.Video;
const Rectangle = ogc.Rectangle;
const utils = ogc.utils;

// Objects
const Camera = @import("Camera.zig");
const Player = @import("Player.zig");
const Slime = @import("Slime.zig");
const Block = @import("Block.zig");
const WorldGen = @import("WorldGen.zig");
const Mushroom = @import("Mushroom.zig");

// Global sprites
pub const Sprite = enum {
    player_idle,
    player_dash,
    player_jump,
    player_fall,
    player_dead,
    player_attack,
    player_sword,
    player_hurt,
    slime_idle,
    slime_jump,
    slime_fall,
    slime_hurt,
    mushroom,
    glider,
    glider_low,
    grass,
    dirt,
    brick,
    brick_altered,
    block,
    heart,

    pub fn draw(self: Sprite, box: Rectangle) void {
        const coords: [4]f32 = switch (self) {
            //                 x  y  w   h
            .player_idle => .{ 0, 0, 32, 32 },
            .player_dash => .{ 32, 0, 32, 32 },
            .player_jump => .{ 0, 32, 32, 32 },
            .player_fall => .{ 32, 32, 32, 32 },
            .player_dead => .{ 32, 64, 32, 32 },
            .player_attack => .{ 32, 64, 32, 32 },
            .player_hurt => .{ 0, 64, 32, 32 },
            .player_sword => .{ 64, 0, 32, 96 },
            .slime_idle => .{ 96, 0, 32, 32 },
            .slime_jump => .{ 128, 0, 32, 32 },
            .slime_fall => .{ 96, 32, 32, 32 },
            .slime_hurt => .{ 128, 32, 32, 32 },
            .mushroom => .{ 96, 128, 32, 32 },
            .glider => .{ 160, 96, 32, 32 },
            .glider_low => .{ 160, 128, 32, 32 },
            .grass => .{ 192, 96, 32, 32 },
            .dirt => .{ 224, 96, 32, 32 },
            .brick => .{ 0, 160, 32, 32 },
            .brick_altered => .{ 32, 160, 32, 32 },
            .block => .{ 64, 160, 32, 32 },
            .heart => .{ 128, 96, 32, 32 },
        };
        utils.sprite(box, coords, .{ 256, 256 });
    }
};

// Global state
pub const State = struct {
    players: [4]?Player = .{null} ** 4,
    blocks: ArrayList(Block),
    slime: Slime,
    camera: Camera,
};

// Constants
pub var screen_width: f32 = undefined;
pub var screen_height: f32 = undefined;

pub fn run(video: *Video) !void {
    // Texture
    Video.load_tpl("../../../src/textures/atlas.tpl");
    screen_width = @intToFloat(f32, video.width);
    screen_height = @intToFloat(f32, video.height);

    // State
    var state = State{
        .slime = Slime.init(200, 200),
        .blocks = ArrayList(Block).init(std.heap.c_allocator),
        .camera = Camera.init(),
    };

    // Generate world
    var world_gen = WorldGen.init();
    try world_gen.generate(&state);

    while (true) {
        // Handle new players
        for (Pad.update()) |controller, i| {
            if (controller and state.players[i] == null) state.players[i] = Player.init(128, 32, i);
        }

        video.start();

        // Camera
        for (state.players) |object| if (object) |player| {
            state.camera.follow(player.x, player.y);
            video.camera(state.camera.x, state.camera.y);
        };

        // Other
        for (state.blocks.items) |*block| block.drawSprite();
        state.slime.run(&state);
        for (state.players) |*object| if (object.*) |*player| player.run(&state);

        // Temporary death handling for slime
        if (state.slime.isDead or state.slime.y > screen_height) state.slime = Slime.init(200, 200);

        // Square
        const box = Rectangle.init(50, 50, 50, 100);
        utils.rectangle(box, 0xFF00FFFF);
        utils.border(box, 0xFFFFFFFF, 5);

        video.finish();
    }
}

export fn main(_: c_int, _: [*]const [*:0]const u8) void {
    ogc.start(run);
}

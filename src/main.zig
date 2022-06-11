// std
const std = @import("std");
const ArrayList = std.ArrayList;

// zogc
const zogc = @import("zogc");
const Pad = zogc.Pad;
const Video = zogc.Video;
const Rectangle = zogc.Rectangle;
const utils = zogc.utils;

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
pub const screen_width: f32 = 640;
pub const screen_height: f32 = 480;

pub fn run(video: *Video) !void {
    // Texture
    Video.load_tpl("../../../src/textures/atlas.tpl");

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

        video.finish();
    }
}

export fn main(_: c_int, _: [*]const [*:0]const u8) void {
    Pad.init();
    var video = Video.init();
    run(&video) catch |err| @panic(@errorName(err));
}

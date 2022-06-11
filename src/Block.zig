const Block = @This();
const Sprite = @import("main.zig").Sprite;

// ogc
const ogc = @import("ogc");
const Rectangle = ogc.Rectangle;
const utils = ogc.utils;

x: f32,
y: f32,
sprite: Sprite,
width: f32 = 32,
height: f32 = 32,

pub fn init(x: f32, y: f32, sprite: Sprite) Block {
    return .{ .x = x, .y = y, .sprite = sprite };
}

pub fn drawSprite(self: *Block) void {
    var area = Rectangle.init(self.x, self.y, self.width, self.height);
    self.sprite.draw(area);
}

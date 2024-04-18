const std = @import ("std");
const toolbox = @import ("toolbox");

const isSubmodule = toolbox.isSubmodule;
const builtin = @import ("builtin");
fn writeZon (builder: *std.Build, name: [] const u8) !void
{
  var buffer = std.ArrayList (u8).init (builder.allocator);
  const writer = buffer.writer ();

  try writer.print (".{c}\n", .{ '{', });
  try writer.print (".name = \"{s}\",\n", .{ name, });
  try writer.print (".version = \"1.0.0\",\n", .{});
  try writer.print (".minimum_zig_version = \"{}.{}.0\",\n",
    .{ builtin.zig_version.major, builtin.zig_version.minor, });

  try writer.print (".paths = .{c}\n", .{ '{', });

  var build_dir = try builder.build_root.handle.openDir (".",
    .{ .iterate = true, });
  defer build_dir.close ();

  var it = build_dir.iterate ();
  while (try it.next ()) |*entry|
  {
    if (!std.mem.startsWith (u8, entry.name, ".") and
      !std.mem.eql (u8, entry.name, "zig-cache") and
      !std.mem.eql (u8, entry.name, "zig-out") and
      !try isSubmodule (builder, entry.name))
        try writer.print ("\"{s}\",\n", .{ entry.name, });
  }

  try writer.print ("{c},\n", .{ '}', });

  //try writer.print (".dependencies = .{c}\n", .{ '{', });

  //try writer.print ("{c},\n", .{ '}', });

  try writer.print ("{c}\n", .{ '}', });

  try buffer.append (0);
  const source = buffer.items [0 .. buffer.items.len - 1 :0];

  const validated = try std.zig.Ast.parse (builder.allocator, source, .zon);
  const formatted = try validated.render (builder.allocator);

  std.debug.print ("{s}\n", .{formatted});
  //try builder.build_root.handle.deleteFile ("build.zig.zon");
  //try builder.build_root.handle.writeFile ("build.zig.zon", formatted);

  std.process.exit (0);
}

fn update (builder: *std.Build, vulkan_path: [] const u8) !void
{
  const tmp_path =
    try builder.build_root.join (builder.allocator, &.{ "tmp", });
  const include_path =
    try std.fs.path.join (builder.allocator, &.{ tmp_path, "include", });

  std.fs.deleteTreeAbsolute (vulkan_path) catch |err|
  {
    switch (err)
    {
      error.FileNotFound => {},
      else => return err,
    }
  };

  try toolbox.clone (builder,
    "https://github.com/KhronosGroup/Vulkan-Headers.git",
    "vulkan", tmp_path);

  var include_dir = try std.fs.openDirAbsolute (include_path,
    .{ .iterate = true, });
  defer include_dir.close ();

  var walker = try include_dir.walk (builder.allocator);
  defer walker.deinit ();

  try toolbox.make (vulkan_path);

  while (try walker.next ()) |*entry|
  {
    const dest = try std.fs.path.join (builder.allocator,
      &.{ vulkan_path, entry.path, });
    switch (entry.kind)
    {
      .file => try toolbox.copy (try std.fs.path.join (builder.allocator,
        &.{ include_path, entry.path, }), dest),
      .directory => try toolbox.make (dest),
      else => return error.UnexpectedEntryKind,
    }
  }

  try std.fs.deleteTreeAbsolute (tmp_path);
}

pub fn build (builder: *std.Build) !void
{
  const target = builder.standardTargetOptions (.{});
  const optimize = builder.standardOptimizeOption (.{});

  const vulkan_path =
    try builder.build_root.join (builder.allocator, &.{ "vulkan", });

  if (builder.option (bool, "zon", "Update build.zig.zon") orelse false)
    try writeZon (builder, "vulkan.zig");
  if (builder.option (bool, "update", "Update binding") orelse false)
    try update (builder, vulkan_path);

  const lib = builder.addStaticLibrary (.{
    .name = "vulkan",
    .root_source_file = builder.addWriteFiles ().add ("empty.c", ""),
    .target = target,
    .optimize = optimize,
  });

  var vulkan_dir =
    try std.fs.openDirAbsolute (vulkan_path, .{ .iterate = true, });
  defer vulkan_dir.close ();

  var it = vulkan_dir.iterate ();
  while (try it.next ()) |*entry|
  {
    if (entry.kind == .directory)
    {
      toolbox.addHeader (lib, try std.fs.path.join (builder.allocator,
        &.{ vulkan_path, entry.name, }), entry.name, &.{ ".h", ".hpp", });
    }
  }

  builder.installArtifact (lib);
}

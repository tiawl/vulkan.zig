const std = @import ("std");
const toolbox = @import ("toolbox");
const pkg = .{ .name = "vulkan.zig", .version = "1.3.277", };

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
    "https://github.com/KhronosGroup/Vulkan-Headers.git", "v" ++ pkg.version,
    tmp_path);

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

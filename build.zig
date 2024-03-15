const std = @import ("std");
const toolbox = @import ("toolbox").toolbox;
//const toolbox = @import ("toolbox/toolbox.zig");
const pkg = .{ .name = "vulkan.zig", .version = "1.3.277", };

fn update (builder: *std.Build) !void
{
  const vulkan_path = try builder.build_root.join (builder.allocator, &.{ "vulkan", });

  std.fs.deleteTreeAbsolute (vulkan_path) catch |err|
  {
    switch (err)
    {
      error.FileNotFound => {},
      else => return err,
    }
  };

  try toolbox.exec (builder, .{ .argv = &[_][] const u8 { "git", "clone", "https://github.com/KhronosGroup/Vulkan-Headers.git", vulkan_path, }, });
  try toolbox.exec (builder, .{ .argv = &[_][] const u8 { "git", "-C", vulkan_path, "checkout", "v" ++ pkg.version, }, });

  var vulkan = try std.fs.openDirAbsolute (vulkan_path, .{ .iterate = true, });
  defer vulkan.close ();

  var it = vulkan.iterate ();
  while (try it.next ()) |*entry|
  {
    if (!std.mem.eql (u8, entry.name, "include"))
      try std.fs.deleteTreeAbsolute (try std.fs.path.join (builder.allocator, &.{ vulkan_path, entry.name, }));
  }
}

pub fn build (builder: *std.Build) !void
{
  const target = builder.standardTargetOptions (.{});
  const optimize = builder.standardOptimizeOption (.{});

  if (builder.option (bool, "update", "Update binding") orelse false) try update (builder);

  const lib = builder.addStaticLibrary (.{
    .name = "vulkan",
    .root_source_file = builder.addWriteFiles ().add ("empty.c", ""),
    .target = target,
    .optimize = optimize,
  });

  const include_path = try builder.build_root.join (builder.allocator, &.{ "vulkan", "include", });
  var include = try std.fs.openDirAbsolute (include_path, .{ .iterate = true, });
  defer include.close ();

  var it = include.iterate ();
  while (try it.next ()) |*entry|
  {
    if (entry.kind == .directory)
    {
      std.debug.print ("[vulkan headers dir] {s}\n", .{ try builder.build_root.join (builder.allocator, &.{ "vulkan", "include", entry.name, }), });
      lib.installHeadersDirectory (try std.fs.path.join (builder.allocator, &.{ "vulkan", "include", entry.name, }), entry.name);
    }
  }

  builder.installArtifact (lib);
}

const std = @import ("std");
const pkg = .{ .name = "vulkan.zig", .version = "1.3.277", };

fn exec (builder: *std.Build, argv: [] const [] const u8) !void
{
  var stdout = std.ArrayList (u8).init (builder.allocator);
  var stderr = std.ArrayList (u8).init (builder.allocator);
  errdefer { stdout.deinit (); stderr.deinit (); }

  std.debug.print ("\x1b[35m[{s}]\x1b[0m\n", .{ try std.mem.join (builder.allocator, " ", argv), });

  var child = std.ChildProcess.init (argv, builder.allocator);

  child.stdin_behavior = .Ignore;
  child.stdout_behavior = .Pipe;
  child.stderr_behavior = .Pipe;

  try child.spawn ();
  try child.collectOutput (&stdout, &stderr, 1000);

  const term = try child.wait ();

  if (stdout.items.len > 0) std.debug.print ("{s}", .{ stdout.items, });
  if (stderr.items.len > 0 and !std.meta.eql (term, std.ChildProcess.Term { .Exited = 0, })) std.debug.print ("\x1b[31m{s}\x1b[0m", .{ stderr.items, });
  try std.testing.expectEqual (term, std.ChildProcess.Term { .Exited = 0, });
}

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

  try exec (builder, &[_][] const u8 { "git", "clone", "https://github.com/KhronosGroup/Vulkan-Headers.git", vulkan_path, });
  try exec (builder, &[_][] const u8 { "git", "-C", vulkan_path, "checkout", "v" ++ pkg.version, });

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

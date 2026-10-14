const std = @import("std");
const build_zig_zon = @import("build.zig.zon");
const toolbox = @import("toolbox");
const VerboseBuilder = toolbox.VerboseBuilder;

fn updateFn(pkg_builder: *VerboseBuilder) !void {
    try pkg_builder.remove(&.{"vulkan"});
    try pkg_builder.make(&.{"vulkan"});

    const vulkan_headers_dep = pkg_builder.verboseDependency("Vulkan-Headers", pkg_builder.getOptimize(), pkg_builder.getTarget());
    var vulkan_headers_builder = VerboseBuilder.initFromDependency(vulkan_headers_dep);

    while (try vulkan_headers_builder.walk(&.{"include"})) |entry| {
        switch (entry.kind) {
            .file => {
                if (toolbox.isCOrCppFile(entry.basename)) {
                    try pkg_builder.copy(&.{ "vulkan", entry.path }, &vulkan_headers_builder, &.{ "include", entry.path });
                }
            },
            .directory => try pkg_builder.make(&.{ "vulkan", entry.path }),
            else => return error.UnexpectedEntryKind,
        }
    }

    try pkg_builder.make(&.{ "vulkan", "registry" });
    try pkg_builder.copy(&.{ "vulkan", "registry", "vk.xml" }, &vulkan_headers_builder, &.{ "registry", "vk.xml" });
}

fn buildFn(pkg_builder: *VerboseBuilder) !void {
    const lib = pkg_builder.addLibrary("vulkan", pkg_builder.getOptimize(), pkg_builder.getTarget());

    while (try pkg_builder.walk(&.{"vulkan"})) |*entry| {
        if (toolbox.isCHeader(entry.basename)) pkg_builder.installHeader(lib, &.{ "vulkan", entry.path }, &.{entry.path});
    }

    pkg_builder.addInclude(lib, &.{"vulkan"});
    pkg_builder.installArtifact(lib);
}

pub fn build(builder: *std.Build) !void {
    var pkg_builder = try VerboseBuilder.init(builder, @tagName(build_zig_zon.name), buildFn, updateFn);

    try pkg_builder.fetch(@TypeOf(build_zig_zon.dependencies), build_zig_zon.dependencies, pkg_builder.ptrCwd());
    try pkg_builder.update();
    try pkg_builder.build();
}

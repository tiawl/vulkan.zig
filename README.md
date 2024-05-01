# vulkan.zig

This is a fork of [hexops/vulkan-headers](https://github.com/hexops/vulkan-headers) which is itself a fork of [KhronosGroup/Vulkan-Headers](https://github.com/KhronosGroup/Vulkan-Headers).

## Why this forkception ?

The intention under this fork is the same as hexops had when they forked [KhronosGroup/Vulkan-Headers](https://github.com/KhronosGroup/Vulkan-Headers): package the headers for @ziglang. So:
* Unnecessary files have been deleted,
* The build system has been replaced with `build.zig`.
However this repository has subtle differences for maintainability tasks:
* No shell scripting,
* A cron runs every day to check [KhronosGroup/Vulkan-Headers](https://github.com/KhronosGroup/Vulkan-Headers). Then it updates this repository if a new release is available.

You can find the repository version used here:
* [KhronosGroup/Vulkan-Headers](https://github.com/tiawl/vulkan.zig/blob/trunk/.versions/vulkan)

## CICD reminder

These repositories are automatically updated when a new release is available:
* [tiawl/glfw.zig](https://github.com/tiawl/glfw.zig)

This repository is automatically updated when a new release is available from these repositories:
* [KhronosGroup/Vulkan-Headers](https://github.com/KhronosGroup/Vulkan-Headers)
* [tiawl/toolbox](https://github.com/tiawl/toolbox)
* [tiawl/spaceporn-dep-action-bot](https://github.com/tiawl/spaceporn-dep-action-bot)
* [tiawl/spaceporn-dep-action-ci](https://github.com/tiawl/spaceporn-dep-action-ci)
* [tiawl/spaceporn-dep-action-cd-ping](https://github.com/tiawl/spaceporn-dep-action-cd-ping)
* [tiawl/spaceporn-dep-action-cd-pong](https://github.com/tiawl/spaceporn-dep-action-cd-pong)

## `zig build` options

These additional options have been implemented for maintainability tasks:
```
  -Dfetch   Update .versions folder and build.zig.zon then stop execution
  -Dupdate  Update binding
```

## License

The unprotected parts of this repository are under MIT License. For everything else, see with their respective owners.

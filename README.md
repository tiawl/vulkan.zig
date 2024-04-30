# vulkan.zig

This is a fork of [hexops/vulkan-headers](https://github.com/hexops/vulkan-headers) which is itself a fork of [KhronosGroup/Vulkan-Headers](https://github.com/KhronosGroup/Vulkan-Headers).

## Why this forkception ?

The intention under this fork is the same as hexops had when they forked [KhronosGroup/Vulkan-Headers](https://github.com/KhronosGroup/Vulkan-Headers): package the headers for Zig. So:
* unnecessary files have been deleted,
* the build system has been replaced with `build.zig`.
with these subtle differences for maintainability tasks:
* no shell scripting,
* a cron is triggered every day to check [KhronosGroup/Vulkan-Headers](https://github.com/KhronosGroup/Vulkan-Headers) and to update this repository if a new release is available.

## CICD reminder

These repositories are automatically updated when a new release is available:
* [tiawl/glfw.zig](https://github.com/tiawl/glfw.zig)

This repository is automatically updated when a new release is available from those repositories:
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

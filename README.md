# vulkan.zig

This is a fork of [hexops/vulkan-headers][1] which is itself a fork of [KhronosGroup/Vulkan-Headers][2].

## Why this forkception ?

The intention under this fork is the same as [hexops][10] had when they forked [KhronosGroup/Vulkan-Headers][2]: package the headers for [Zig][3]. So:
* Unnecessary files have been deleted,
* The build system has been replaced with `build.zig`.

However this repository has subtle differences for maintainability tasks:
* No shell scripting,
* A cron runs every day to check [KhronosGroup/Vulkan-Headers][2]. Then it updates this repository if a new release is available.

## How to use it

The current usage of this repository is centered around [tiawl/glfw.zig][3] compilation. But you could use it for your own projects. Headers are here and there are no planned evolution to modify them. See [tiawl/glfw.zig][3] to see how you can use it.

## Dependencies

The [Zig][3] part of this package is relying on the latest [Zig][3] release (0.13.0) and will only be updated for the next one (so for the 0.14.0).

Here the repositories' version used by this fork:
* [KhronosGroup/Vulkan-Headers](https://github.com/tiawl/vulkan.zig/blob/trunk/.references/vulkan)

## CICD reminder

These repositories are automatically updated when a new release is available:
* [tiawl/glfw.zig][4]

This repository is automatically updated when a new release is available from these repositories:
* [KhronosGroup/Vulkan-Headers][2]
* [tiawl/toolbox][5]
* [tiawl/spaceporn-action-bot][6]
* [tiawl/spaceporn-action-ci][7]
* [tiawl/spaceporn-action-cd-ping][8]
* [tiawl/spaceporn-action-cd-pong][9]

## `zig build` options

These additional options have been implemented for maintainability tasks:
```
  -Dfetch   Update .references folder and build.zig.zon then stop execution
  -Dupdate  Update binding
```

## License

This repository is not subject to a unique License:

The parts of this repository originated from this repository are dedicated to the public domain. See the LICENSE file for more details.

**For other parts, it is subject to the License restrictions their respective owners choosed. By design, the public domain code is incompatible with the License notion. In this case, the License prevails. So if you have any doubt about a file property, open an issue.**

[1]:https://github.com/hexops/vulkan-headers
[2]:https://github.com/KhronosGroup/Vulkan-Headers
[3]:https://github.com/ziglang/zig
[4]:https://github.com/tiawl/glfw.zig
[5]:https://github.com/tiawl/toolbox
[6]:https://github.com/tiawl/spaceporn-action-bot
[7]:https://github.com/tiawl/spaceporn-action-ci
[8]:https://github.com/tiawl/spaceporn-action-cd-ping
[9]:https://github.com/tiawl/spaceporn-action-cd-pong
[10]:https://github.com/hexops

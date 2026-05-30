local plugins = require("functions.plugins")

if not plugins.ensure_plugin("darkwindow") then return end

hl.config({
    plugin = {
        darkwindow = {
            -- -- To modify the uniforms of an already existing shader, create a new shader and set the uniforms you want
            -- ["shader[tintRed]"] = {
            --     from = "tint",
            --     args = "tintColor=[1 0 0] tintStrength=0.1",
            -- },
            --
            -- -- Use a custom shader from a file
            -- ["shader[cool]"] = {
            --     path = "/path/to/shader.glsl",
            --     args = "wow=[1.0 0 0]",
            --     introduces_transparency = true,
            -- },
        },
    },
})

hl.config({
    decoration = {
        rounding = 7,
        blur = {
            enabled = false,
            size = 15,
            passes = 2,
        },


        shadow = {
            enabled = true,
            range = 15,
            render_power = 1,
            color = 0x50000000,
            color_inactive = 0x50000000,
            -- scale = 1,
        },
    },
})


hl.config({
    dwindle = {
        preserve_split = true,
    },
})

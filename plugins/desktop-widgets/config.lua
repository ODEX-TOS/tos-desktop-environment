local widgets = {}

widgets[1] = {
    x = 0.77,
    y = 0.05,
    width = 0.2,
    height = 0.4,
    type = "radial",
    resource = "CPU",
    title = "CPU Widget"
}

widgets[2] = {
    x = 0.77,
    y = 0.50,
    width = 0.2,
    height = 0.4,
    type = "radial",
    resource = "RAM",
    title = "RAM Widget"
}

widgets[3] = {
    x = 0.54,
    y = 0.05,
    width = 0.2,
    height = 0.4,
    type = "chart",
    resource = "CPU",
    title = "CPU Chart"
}

widgets[4] = {
    x = 0.54,
    y = 0.50,
    width = 0.2,
    height = 0.4,
    type = "chart",
    resource = "RAM",
    title = "RAM Chart"
}

return widgets

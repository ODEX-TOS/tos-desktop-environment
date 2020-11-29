local magic = require("tde.lib-tde.imagemagic")

-- TODO: design tests to make sure our api calls to imagemagic work

function test_imagemagic_api()
    assert(type(magic.scale) == "function")
end

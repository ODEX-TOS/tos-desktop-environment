local magic = require("tde.lib-tde.imagemagic")

-- TODO: design tests to make sure our api calls to imagemagic work

function test_imagemagic_api()
    assert(type(magic.scale) == "function")
    assert(type(magic.grayscale) == "function")
    assert(type(magic.transparent) == "function")
    assert(type(magic.compress) == "function")
    assert(type(magic.convert) == "function")
end

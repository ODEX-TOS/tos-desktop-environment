return {
    get_configuration_dir = function()
        return os.getenv("PWD") .. "/tde"
    end
}

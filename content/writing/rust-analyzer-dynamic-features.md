+++
title = "Dynamiclly set Cargo features in Neovim"
description = "How to update Cargo features used by rust-analyzer in neovim"
weight = 0
date = 2025-09-12

[extra]

[taxonomies]
tags = ["vim", "rust"]
+++
## Rust analyzer
[Rust analyzer](https://rust-analyzer.github.io/) is a [language server](https://microsoft.github.io/language-server-protocol/) which provides editor support for [the Rust programming language](https://www.rust-lang.org/).
[Neovim](https://neovim.io/) has built-in language server protocol support.

[Cargo](https://doc.rust-lang.org/cargo/) supports feature flags, which enable conditional configuration.
However, any blocks which are not compiled for a given feature do not benefit from rust-analyzer language server support.

While it is possible to enable features at startup in Neovim configuration, an ideal solution would be to define a user command, say `:FtSet`, which would set the feature list to the provided arguments.
For example, to set features `a` and `b` we would like to run `:FtSet a b`.

If you just want the function, you can find it [here](#function-definitions).
If you are also interested in some Neovim LSP implementation details, read on!

### Required setup
To set up rust-analyzer, it is convenient to use the [`neovim/nvim-lspconfig`](https://github.com/neovim/nvim-lspconfig) package, which you can install by following the instructions in the repository.
You also must have the rust-analyzer binary available on your `PATH` or you can provide a custom binary during configuration (as detailed [here](https://github.com/neovim/nvim-lspconfig?tab=readme-ov-file#quickstart)).

### Basic feature configuration
When enabling rust-analyzer with `vim.lsp.enable('rust_analyzer')`, it is possible to configure rust-analyzer to enable (or disable) features:
```lua
vim.lsp.config('rust_analyzer', {
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        features = {}
      },
    },
  }
})
```
However, assuming you have set this up in global configuration like `init.lua`, it is rather inconvenient to change the features which are enabled while editing a file.

## Dynamic feature flags
Instead, we want to implement a function to set feature flags dynamically at runtime.

### Modifying the existing configuration
In order to update rust-analyzer, we first need to access the existing configuration so that we can modify it without altering other settings.
The built-in way to access running language servers is with the [`vim.lsp.get_clients`](https://neovim.io/doc/user/lsp.html#vim.lsp.get_clients%28%29) function.
This function accepts an optional dictionary which can be used to filter the clients which are returned.
In our case, we would use `vim.lsp.get_clients({ name = "rust_analyzer" })`.

Since this could match multiple clients, this returns an [array](https://www.lua.org/pil/11.1.html).
To access the running client, we can index into the array (by default, lua arrays start at `1`).

To view the configuration of the currently running rust-analyzer server, we would therefore run
```vim
:lua= vim.lsp.get_clients({ name = "rust_analyzer" })[1].config
```
In order to update the configuration, we just need to modify the configuration, and then send the updated configuration to rust-analyzer.
For example, to set features `a` and `b`, we can do something like:
```lua
local rustAnalyzerSettings = vim.lsp.get_clients({ name = "rust_analyzer" })[1].config.settings
-- if rust-analyzer is not running at all, this will be `nil`
if rustAnalyzerSettings ~= nil then
  rustAnalyzerSettings["rust-analyzer"].cargo.features = { 'a', 'b' }
  -- ??
end
```
The structure of the `rustAnalyzerSettings` object is the same as the object which we initially configured using `vim.lsp.config`.

### Propogating the feature flags to rust-analyzer
Now, the local `rustAnalyzerSettings` object contains a copy of the configuration, with the `cargo.features` value updated.
However, in order for our configuration update to take place, we must propagate the settings to the (currently running) rust-analyzer instance.

The language server protocol has a specific notification type called [`workspace/didChangeConfiguration`](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#workspace_didChangeConfiguration).
This is a notification that is sent by the client to the server.
Neovim allows you to send these notifications in lua code with [`vim.lsp.buf_notify`](https://neovim.io/doc/user/lsp.html#vim.lsp.buf_notify%28%29).

In principle, the following should work:
```lua
let client = vim.lsp.get_clients({ name = "rust_analyzer" })[1]
if client ~= nil then
  local rustAnalyzerSettings = client.config.settings
  rustAnalyzerSettings["rust-analyzer"].cargo.features = { 'a', 'b' }
  client.notify('workspace/didChangeConfiguration', { settings = rustAnalyzerSettings })
end
```
However, at the time of writing this article, I was unable to make this work.
It seems that rust-analyzer and Neovim do not support dynamic updates of `workspace/didChangeConfiguration`.
A hint that this is the case can see this by looking at the 'capabilities' section of rust-analyzer:
```vim
:lua= vim.lsp.get_clients({ name = "rust_analyzer" })[1].capabilities.workspace.didChangeConfiguration
```
We can see here that the `dynamicRegistration` option is `false`.
As far as I can tell, rust-analyzer by default only requests configuration on startup from Neovim.

### Workaround: restart rust-analyzer on feature change
A somewhat unsatisfying but functional workaround is simply to restart rust-analyzer.
```lua
local rustAnalyzerSettings = vim.lsp.get_clients({ name = "rust_analyzer" })[1].config.settings
if rustAnalyzerSettings ~= nil then
  rustAnalyzerSettings["rust-analyzer"].cargo.features = { 'a', 'b' }
  -- restart rust-analyzer with new settings
  vim.lsp.enable('rust_analyzer', false)
  vim.lsp.config('rust_analyzer', { settings = rustAnalyzerSettings })
  vim.lsp.enable('rust_analyzer')
end
```
All that remains is to wrap this in a user command.
```lua
vim.api.nvim_create_user_command(
  'FtSet',
  function(opts)
    local rustAnalyzerSettings = vim.lsp.get_clients({ name = "rust_analyzer" })[1].config.settings
    if rustAnalyzerSettings ~= nil then
      rustAnalyzerSettings["rust-analyzer"].cargo.features = opts.fargs
      vim.lsp.enable('rust_analyzer', false)
      vim.lsp.config('rust_analyzer', { settings = rustAnalyzerSettings })
      vim.lsp.enable('rust_analyzer')
    end
  end,
  { desc = 'Set rust-analyzer features', nargs = '*' }
)
```
Here, `opts.fargs` is an array of all of the arguments passed to the command `:FtSet`.
We explicitly set `nargs = '*'` to set an arbitrary number of features simultaneously.
You can read more about `nvim_create_user_command` in the [docs](https://neovim.io/doc/user/api.html#nvim_create_user_command%28%29).

## Function definitions
Here are a few examples demonstrating some operations.
A few things that would be great to fix:

1. The operations do not de-duplicate the feature list.
2. The implementation is quite repetitive.
3. The arguments should suggest completions from a list of features read from `Cargo.toml`.
4. You should put these function definitions somewhere that is only enabled when rust-analyzer attaches to the Neovim instance.

### Set features
```lua
vim.api.nvim_create_user_command(
  'FtSet',
  function(opts)
    local rustAnalyzerSettings = vim.lsp.get_clients({ name = "rust_analyzer" })[1].config.settings
    if rustAnalyzerSettings ~= nil then
      rustAnalyzerSettings["rust-analyzer"].cargo.features = opts.fargs
      vim.lsp.enable('rust_analyzer', false)
      vim.lsp.config('rust_analyzer', { settings = rustAnalyzerSettings })
      vim.lsp.enable('rust_analyzer')
    end
  end,
  { desc = 'Set rust-analyzer features to the provided list', nargs = '*' }
)
```

### Set all features (`--all-features`)
```lua
vim.api.nvim_create_user_command(
  'FtSetAll',
  function(opts)
    local rustAnalyzerSettings = vim.lsp.get_clients({ name = "rust_analyzer" })[1].config.settings
    if rustAnalyzerSettings ~= nil then
      rustAnalyzerSettings["rust-analyzer"].cargo.features = "all"
      vim.lsp.enable('rust_analyzer', false)
      vim.lsp.config('rust_analyzer', { settings = rustAnalyzerSettings })
      vim.lsp.enable('rust_analyzer')
    end
  end,
  { desc = 'Set all rust-analyzer features', nargs = '*' }
)
```

### List enabled features
```lua
vim.api.nvim_create_user_command(
  'FtList',
  function(opts)
    local rustAnalyzerSettings = vim.lsp.get_clients({ name = "rust_analyzer" })[1].config.settings
    if rustAnalyzerSettings == 'all' then
      print("all features enabled")
    elseif rustAnalyzerSettings ~= nil then
      print('['..table.concat(rustAnalyzerSettings["rust-analyzer"].cargo.features, ', ')..']')
    end
  end,
  { desc = "List rust-analyzer active features.", nargs = 0 }
)
```
